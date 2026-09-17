--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Player & Character Lifecycle

    Three things are kept distinct here:
      • platform player   — the connected RedM client (source, identifiers)
      • player session    — the runtime object in LXRCore.Players[source]
      • persistent character — a row in `players`, keyed by citizenid

    Login / Logout / Save / Delete are serialised per source so character
    switching, double-clicks in the multicharacter UI and disconnects during a
    save cannot corrupt state. Saves are dirty-tracked and batched.

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXRCore.Player = LXRCore.Player or {}
local PlayerAPI = LXRCore.Player
local Accounts, Roles, Inventory = LXRCore.Accounts, LXRCore.Roles, LXRCore.Inventory

local loading = {}          -- source → true while Login is in progress
local characterTables = {}  -- extra tables registered by resources for deletion
local syncPending = {}      -- source → true while a debounced PlayerData push is scheduled
local saveInProgress = {}   -- citizenid → true while a DB write is in flight

local SAVE_SQL = [[INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata, weight, slots, outlawstatus)
VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata, :weight, :slots, :outlawstatus)
ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang,
position = :position, metadata = :metadata, weight = :weight, slots = :slots, outlawstatus = :outlawstatus]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🆔 IDENTIFIERS & ID GENERATION
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRCore.Functions.GetIdentifier(source, idtype)
    source = LXRCore.ToSource(source)
    if not source then return nil end
    return GetPlayerIdentifierByType(source, idtype or 'license')
end

---Collect the identifiers we care about once per session.
local function collectIdentifiers(source)
    return {
        license = GetPlayerIdentifierByType(source, 'license'),
        license2 = GetPlayerIdentifierByType(source, 'license2'),
        steam = GetPlayerIdentifierByType(source, 'steam'),
        discord = GetPlayerIdentifierByType(source, 'discord'),
        fivem = GetPlayerIdentifierByType(source, 'fivem'),
        ip = GetPlayerIdentifierByType(source, 'ip'),
    }
end

---Unique citizen id (3 letters + 5 digits, verified against the database, bounded retries).
function PlayerAPI.CreateCitizenId()
    for _ = 1, 25 do
        local id = (LXRShared.RandomStr(3) .. LXRShared.RandomInt(5)):upper()
        local exists = LXRCore.DB.Scalar('SELECT EXISTS(SELECT 1 FROM players WHERE citizenid = ?) AS uniqueCheck', { id })
        if tonumber(exists) == 0 then return id end
    end
    -- astronomically unlikely; fall back to a longer id that cannot collide in practice
    return (LXRShared.RandomStr(4) .. LXRShared.RandomInt(8)):upper()
end

function LXRCore.Functions.CreateAccountNumber()
    return ('US0%d%s%s%s'):format(math.random(1, 9), 'LXR', LXRShared.RandomInt(8), LXRShared.RandomInt(2))
end

function PlayerAPI.CreateFingerId()
    return LXRShared.RandomStr(2) .. LXRShared.RandomInt(3) .. LXRShared.RandomStr(1) .. LXRShared.RandomInt(2) .. LXRShared.RandomStr(3) .. LXRShared.RandomInt(4)
end

function PlayerAPI.CreateWalletId()
    return 'LXR-' .. LXRShared.RandomInt(8)
end

function PlayerAPI.ValidateCitizenId(citizenid)
    return type(citizenid) == 'string' and #citizenid >= 6 and #citizenid <= 50 and citizenid:match('^[%w%-_]+$') ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧾 ROW ↔ PLAYERDATA
-- ═══════════════════════════════════════════════════════════════════════════════

local function decodeRow(row)
    row.money = LXRShared.JsonDecode(row.money, {})
    row.job = LXRShared.JsonDecode(row.job, {})
    row.gang = LXRShared.JsonDecode(row.gang, {})
    row.position = LXRShared.JsonDecode(row.position, nil)
    row.metadata = LXRShared.JsonDecode(row.metadata, {})
    row.charinfo = LXRShared.JsonDecode(row.charinfo, {})
    row.inventory = nil -- loaded by the inventory provider
    return row
end

---Normalise raw data (from DB or a new character) into a full PlayerData table.
---@param source integer|nil  nil = offline
---@param PlayerData table
function PlayerAPI.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = not source

    if source then
        PlayerData.source = source
        PlayerData.identifiers = collectIdentifiers(source)
        PlayerData.license = PlayerData.license or PlayerData.identifiers.license
        PlayerData.name = GetPlayerName(source)
    end

    PlayerData.citizenid = PlayerData.citizenid or PlayerAPI.CreateCitizenId()
    PlayerData.job = Roles.ValidateJob(PlayerData.job)
    PlayerData.gang = Roles.ValidateGang(PlayerData.gang)

    LXRShared.ApplyDefaults(PlayerData, Config.Player.defaults)
    PlayerData.charinfo.account = PlayerData.charinfo.account or LXRCore.Functions.CreateAccountNumber()
    PlayerData.money = Accounts.EnsureAccounts(PlayerData.money)

    local md = PlayerData.metadata
    md.bloodtype = md.bloodtype or Config.Player.bloodTypes[math.random(1, #Config.Player.bloodTypes)]
    md.fingerprint = md.fingerprint or PlayerAPI.CreateFingerId()
    md.walletid = md.walletid or PlayerAPI.CreateWalletId()
    md.xp = type(md.xp) == 'table' and md.xp or {}
    md.levels = type(md.levels) == 'table' and md.levels or {}
    for _, skill in ipairs(Config.Player.skills or {}) do
        md.xp[skill] = tonumber(md.xp[skill]) or 0
        md.levels[skill] = tonumber(md.levels[skill]) or 0
    end

    PlayerData.position = PlayerData.position or Config.General.defaultSpawn
    PlayerData.weight = tonumber(PlayerData.weight) or Config.Player.maxWeight
    PlayerData.slots = tonumber(PlayerData.slots) or Config.Player.maxSlots
    PlayerData.outlawstatus = tonumber(PlayerData.outlawstatus) or 0
    PlayerData.items = PlayerData.items or {}
    PlayerData.optin = PlayerData.optin ~= false

    if not Offline then
        PlayerData.items = Inventory.Load(source, PlayerData.citizenid)
    end

    return PlayerAPI.CreatePlayer(PlayerData, Offline)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔐 LOGIN / LOGOUT
-- ═══════════════════════════════════════════════════════════════════════════════

---@param source integer
---@param citizenid string|false|nil  existing character, or falsy for a new one
---@param newData table|nil            { cid, charinfo = {...} } for new characters
---@return boolean
function PlayerAPI.Login(source, citizenid, newData)
    source = LXRCore.ToSource(source)
    if not source then
        LXRCore.ShowError(LXRCore.ResourceName, 'Player.Login: no source given')
        return false
    end
    if not LXRCore.DB.Ready then
        LXRCore.Log.warn('player', 'login refused: database not ready', { source = source })
        return false
    end
    if loading[source] then
        LXRCore.Log.warn('player', 'login ignored: already loading', { source = source })
        return false
    end
    loading[source] = true
    local started = GetGameTimer()

    local ok, result = pcall(function()
        -- character switch: unload the current one first (saves synchronously)
        if LXRCore.Players[source] then
            PlayerAPI.Logout(source, true)
        end

        local license = GetPlayerIdentifierByType(source, 'license')
        if not license then return false end

        local PlayerData
        if citizenid then
            if not PlayerAPI.ValidateCitizenId(citizenid) then
                LXRCore.Log.exploit(source, 'login with malformed citizenid', { citizenid = tostring(citizenid) })
                if Config.Security.kickOnExploit then DropPlayer(source, Lang:t('error.exploit_dropped')) end
                return false
            end
            local row = LXRCore.DB.Single('SELECT * FROM players WHERE citizenid = ?', { citizenid })
            -- One-time re-link for rows imported from VORP (keyed by steam identifier).
            if row and row.license ~= license and Config.Database.relinkImportedRows then
                local steam = GetPlayerIdentifierByType(source, 'steam')
                if steam and row.license == steam then
                    LXRCore.DB.Update('UPDATE players SET license = ? WHERE citizenid = ? AND license = ?', { license, citizenid, steam })
                    LXRCore.Log.info('player', 'relinked imported character to license', { citizenid = citizenid, from = steam })
                    row.license = license
                end
            end
            if not row or row.license ~= license then
                LXRCore.Log.exploit(source, 'login with a character that is not theirs', { citizenid = citizenid })
                if Config.Security.kickOnExploit then DropPlayer(source, Lang:t('error.exploit_dropped')) end
                return false
            end
            if LXRCore.PlayersByCitizenId[citizenid] then
                LXRCore.Log.warn('player', 'login refused: character already in use', { source = source, citizenid = citizenid })
                return false
            end
            PlayerData = decodeRow(row)
        else
            PlayerData = type(newData) == 'table' and newData or {}
            PlayerData.license = license
            if newData and newData.charinfo then
                -- new character payload from multicharacter: only accept known keys
                local ci = {}
                for _, k in ipairs({ 'firstname', 'lastname', 'birthdate', 'gender', 'nationality' }) do
                    if newData.charinfo[k] ~= nil then ci[k] = newData.charinfo[k] end
                end
                PlayerData.charinfo = ci
            end
        end

        local player = PlayerAPI.CheckPlayerData(source, PlayerData)
        return player ~= nil
    end)

    loading[source] = nil
    if not ok then
        LXRCore.Log.error('player', 'login failed', { source = source, error = tostring(result) })
        return false
    end
    if result then
        LXRCore.Metrics.Time('player.login', GetGameTimer() - started)
    end
    return result == true
end

---Unload the current character. `switching` = true skips the drop-side cleanup.
function PlayerAPI.Logout(source, switching)
    source = LXRCore.ToSource(source)
    local player = source and LXRCore.Players[source]
    if not player then return false end

    LXRCore.Emit('lxr:player:unloaded', { legacy = 'LXRCore:Server:OnPlayerUnload', rsg = 'RSGCore:Server:OnPlayerUnload' }, source)
    LXRCore.EmitClient(source, 'lxr:client:unloaded', { legacy = 'LXRCore:Client:OnPlayerUnload', rsg = 'RSGCore:Client:OnPlayerUnload' })

    PlayerAPI.Save(source, true)

    LXRCore.Players[source] = nil
    LXRCore.PlayersByCitizenId[player.PlayerData.citizenid] = nil
    LXRCore.PlayersByLicense[player.PlayerData.license] = nil
    syncPending[source] = nil

    local state = Player(source).state
    state:set('isLoggedIn', false, true)
    state:set('citizenid', nil, true)
    state:set('job', nil, true)
    if not switching then LXRCore.Callback.CleanupSource(source) end
    LXRCore.Log.info('player', 'character unloaded', { source = source, citizenid = player.PlayerData.citizenid })
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧍 PLAYER OBJECT
-- ═══════════════════════════════════════════════════════════════════════════════

function PlayerAPI.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.PlayerData = PlayerData
    self.Functions = {}
    self.Offline = Offline == true
    self._dirty = true

    local F = self.Functions
    local function src() return self.PlayerData.source end

    ---Push PlayerData to the client (debounced) and fire the server-side update event.
    function F.UpdatePlayerData()
        self._dirty = true
        if self.Offline then return end
        if Config.Money.EnableMoneyItems and Accounts.SyncMoneyItems then Accounts.SyncMoneyItems(self) end
        local s = src()
        if syncPending[s] then return end
        syncPending[s] = true
        SetTimeout(Config.Performance.playerDataSyncMs or 100, function()
            syncPending[s] = nil
            if LXRCore.Players[s] ~= self then return end
            LXRCore.Emit('lxr:player:updated', { legacy = 'LXRCore:Server:OnPlayerUpdated', rsg = 'RSGCore:Player:SetPlayerData' }, s, self.PlayerData)
            if Config.Compat.legacy.enabled then TriggerEvent('LXRCore:Player:SetPlayerData', self.PlayerData) end
            LXRCore.EmitClient(s, 'lxr:client:data', { legacy = 'LXRCore:Player:SetPlayerData', rsg = 'RSGCore:Player:SetPlayerData' }, self.PlayerData)
            LXRCore.Metrics.Inc('player.sync')
        end)
    end

    function F.SetPlayerData(key, val)
        if type(key) ~= 'string' then return false end
        self.PlayerData[key] = val
        F.UpdatePlayerData()
        return true
    end

    -- ── Jobs / gangs ───────────────────────────────────────────────────────────
    function F.SetJob(job, grade)
        local built, err = Roles.BuildJob(job, grade)
        if not built then return false, err end
        self.PlayerData.job = built
        self._dirty = true
        if not self.Offline then
            Player(src()).state:set('job', { name = built.name, grade = built.grade.level, onduty = built.onduty, type = built.type }, true)
            F.UpdatePlayerData()
            LXRCore.Emit('lxr:job:changed', { legacy = 'LXRCore:Server:OnJobUpdate', rsg = 'RSGCore:Server:OnJobUpdate' }, src(), built)
            LXRCore.EmitClient(src(), 'lxr:client:job', { legacy = 'LXRCore:Client:OnJobUpdate', rsg = 'RSGCore:Client:OnJobUpdate' }, built)
        end
        return true
    end

    function F.SetGang(gang, grade)
        local built, err = Roles.BuildGang(gang, grade)
        if not built then return false, err end
        self.PlayerData.gang = built
        self._dirty = true
        if not self.Offline then
            F.UpdatePlayerData()
            LXRCore.Emit('lxr:gang:changed', { legacy = 'LXRCore:Server:OnGangUpdate', rsg = 'RSGCore:Server:OnGangUpdate' }, src(), built)
            LXRCore.EmitClient(src(), 'lxr:client:gang', { legacy = 'LXRCore:Client:OnGangUpdate', rsg = 'RSGCore:Client:OnGangUpdate' }, built)
        end
        return true
    end

    function F.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = onDuty == true
        self._dirty = true
        if not self.Offline then
            local j = self.PlayerData.job
            Player(src()).state:set('job', { name = j.name, grade = j.grade.level, onduty = j.onduty, type = j.type }, true)
            LXRCore.Emit('lxr:duty:changed', { legacy = 'LXRCore:Server:SetDuty', rsg = 'RSGCore:Server:SetDuty' }, src(), j.onduty)
            LXRCore.Emit('lxr:job:changed', { legacy = 'LXRCore:Server:OnJobUpdate', rsg = 'RSGCore:Server:OnJobUpdate' }, src(), j)
            LXRCore.EmitClient(src(), 'lxr:client:duty', { legacy = 'LXRCore:Client:SetDuty', rsg = 'RSGCore:Client:SetDuty' }, j.onduty)
            LXRCore.EmitClient(src(), 'lxr:client:job', { legacy = 'LXRCore:Client:OnJobUpdate', rsg = 'RSGCore:Client:OnJobUpdate' }, j)
            F.UpdatePlayerData()
        end
        return true
    end

    -- ── Metadata ───────────────────────────────────────────────────────────────
    local function clampMeta(key, value)
        if key == 'hunger' or key == 'thirst' or key == 'cleanliness' or key == 'stress' then
            return LXRShared.Clamp(tonumber(value) or 0, 0, 100)
        end
        return value
    end

    function F.SetMetaData(meta, val)
        if type(meta) == 'table' then
            for k, v in pairs(meta) do
                if type(k) == 'string' then self.PlayerData.metadata[k] = clampMeta(k, v) end
            end
        elseif type(meta) == 'string' then
            self.PlayerData.metadata[meta] = clampMeta(meta, val)
        else
            return false
        end
        F.UpdatePlayerData()
        if not self.Offline then LXRCore.Emit('lxr:meta:changed', { legacy = 'LXRCore:Server:OnMetaDataUpdate' }, src(), meta, val) end
        return true
    end

    function F.GetMetaData(meta)
        if type(meta) ~= 'string' then return nil end
        return self.PlayerData.metadata[meta]
    end

    -- ── Reputation & skills ────────────────────────────────────────────────────
    function F.AddRep(rep, amount)
        if type(rep) ~= 'string' or not tonumber(amount) then return false end
        local r = self.PlayerData.metadata.rep
        r[rep] = (tonumber(r[rep]) or 0) + tonumber(amount)
        F.UpdatePlayerData()
        return true
    end

    function F.RemoveRep(rep, amount)
        if type(rep) ~= 'string' or not tonumber(amount) then return false end
        local r = self.PlayerData.metadata.rep
        r[rep] = math.max(0, (tonumber(r[rep]) or 0) - tonumber(amount))
        F.UpdatePlayerData()
        return true
    end

    function F.GetRep(rep)
        return tonumber(self.PlayerData.metadata.rep[rep]) or 0
    end

    local function recalcLevel(skill)
        local xp = tonumber(self.PlayerData.metadata.xp[skill]) or 0
        local level = math.min(Config.Player.maxLevel or 20, math.floor(xp / (Config.Player.xpPerLevel or 50)))
        self.PlayerData.metadata.levels[skill] = level
        return level
    end

    function F.AddXp(skill, amount)
        if type(skill) ~= 'string' or not tonumber(amount) or tonumber(amount) <= 0 then return false end
        local xp = self.PlayerData.metadata.xp
        xp[skill] = (tonumber(xp[skill]) or 0) + tonumber(amount)
        local level = recalcLevel(skill)
        F.UpdatePlayerData()
        if not self.Offline then LXRCore.EmitClient(src(), 'lxr:client:xp', { legacy = 'LXRCore:Client:OnXpChange' }, skill, xp[skill], level) end
        return true
    end

    function F.RemoveXp(skill, amount)
        if type(skill) ~= 'string' or not tonumber(amount) or tonumber(amount) <= 0 then return false end
        local xp = self.PlayerData.metadata.xp
        xp[skill] = math.max(0, (tonumber(xp[skill]) or 0) - tonumber(amount))
        local level = recalcLevel(skill)
        F.UpdatePlayerData()
        if not self.Offline then LXRCore.EmitClient(src(), 'lxr:client:xp', { legacy = 'LXRCore:Client:OnXpChange' }, skill, xp[skill], level) end
        return true
    end

    function F.GetXp(skill) return tonumber(self.PlayerData.metadata.xp[skill]) or 0 end
    function F.GetLevel(skill) return tonumber(self.PlayerData.metadata.levels[skill]) or 0 end
    F.AddJobReputation = function(amount) return F.AddRep(self.PlayerData.job.name, amount) end

    -- ── Money ──────────────────────────────────────────────────────────────────
    function F.AddMoney(account, amount, reason) return Accounts.Add(self, account, amount, reason) end
    function F.RemoveMoney(account, amount, reason) return Accounts.Remove(self, account, amount, reason) end
    function F.SetMoney(account, amount, reason) return Accounts.Set(self, account, amount, reason) end
    function F.GetMoney(account) return Accounts.Get(self, account) end
    function F.HasMoney(account, amount) return Accounts.Has(self, account, amount) end

    -- ── Items (provider-aware) ─────────────────────────────────────────────────
    function F.AddItem(item, amount, slot, info, reason)
        if self.Offline then return Inventory.CoreLogic.AddItem(self, item, amount, slot, info) end
        return Inventory.AddItem(src(), item, amount, slot, info, reason)
    end
    function F.RemoveItem(item, amount, slot, reason)
        if self.Offline then return Inventory.CoreLogic.RemoveItem(self, item, amount, slot) end
        return Inventory.RemoveItem(src(), item, amount, slot, reason)
    end
    function F.HasItem(items, amount) return Inventory.HasItem(src(), items, amount) end
    function F.GetItemByName(item) return Inventory.CoreLogic.GetItemByName(self.PlayerData.items, item) end
    function F.GetItemsByName(item) return Inventory.CoreLogic.GetItemsByName(self.PlayerData.items, item) end
    function F.GetItemBySlot(slot) return self.PlayerData.items[tonumber(slot)] end
    function F.SetInventory(items) return Inventory.SetInventory(src(), items) end
    function F.ClearInventory(filter) return Inventory.ClearInventory(src(), filter) end
    function F.UpdatePlayerItems(slot)
        if self.Offline then return end
        TriggerClientEvent('lxr-inventory:client:UpdateItems', src(), slot, self.PlayerData.items[slot])
    end

    -- ── Lifecycle ──────────────────────────────────────────────────────────────
    function F.Save()
        if self.Offline then return PlayerAPI.SaveOffline(self.PlayerData) end
        F.PersistStateBags()
        return PlayerAPI.Save(src())
    end

    function F.Logout()
        if self.Offline then return false end
        return PlayerAPI.Logout(src())
    end

    function F.AddMethod(name, handler) self.Functions[name] = handler end
    function F.AddField(name, data) self[name] = data end

    -- Status values (hunger/thirst/…) are mirrored to replicated state bags so HUDs
    -- and other resources can read them without asking the server.
    local STATE_KEYS = { 'hunger', 'thirst', 'cleanliness', 'stress', 'health' }
    function F.InitializeStateBags()
        if self.Offline then return end
        local state = Player(src()).state
        for _, k in ipairs(STATE_KEYS) do
            if self.PlayerData.metadata[k] ~= nil then state:set(k, self.PlayerData.metadata[k], true) end
        end
        local j = self.PlayerData.job
        state:set('isLoggedIn', true, true)
        state:set('citizenid', self.PlayerData.citizenid, true)
        state:set('job', { name = j.name, grade = j.grade.level, onduty = j.onduty, type = j.type }, true)
    end

    function F.PersistStateBags()
        if self.Offline then return end
        local state = Player(src()).state
        local md = {}
        for _, k in ipairs(STATE_KEYS) do
            if state[k] ~= nil then md[k] = state[k] end
        end
        if next(md) then
            for k, v in pairs(md) do self.PlayerData.metadata[k] = clampMeta(k, v) end
            self._dirty = true
        end
    end

    if self.Offline then
        return self
    end

    -- Online: register, replicate, announce.
    LXRCore.Players[self.PlayerData.source] = self
    LXRCore.PlayersByCitizenId[self.PlayerData.citizenid] = self
    LXRCore.PlayersByLicense[self.PlayerData.license] = self
    F.InitializeStateBags()
    PlayerAPI.Save(self.PlayerData.source) -- guarantees the row exists for new characters
    LXRCore.Emit('lxr:player:loaded', { legacy = 'LXRCore:Server:PlayerLoaded', rsg = 'RSGCore:Server:PlayerLoaded' }, self)
    F.UpdatePlayerData()
    LXRCore.Commands.Refresh(self.PlayerData.source)
    LXRCore.Metrics.Inc('player.loaded')
    LXRCore.Log.info('player', 'character loaded', { source = self.PlayerData.source, citizenid = self.PlayerData.citizenid, name = self.PlayerData.name })
    return self
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💾 SAVE
-- ═══════════════════════════════════════════════════════════════════════════════

local function buildSaveParams(pd, position)
    return {
        citizenid = pd.citizenid,
        cid = tonumber(pd.cid) or 1,
        license = pd.license,
        name = pd.name or 'unknown',
        money = json.encode(pd.money),
        charinfo = json.encode(pd.charinfo),
        job = json.encode(pd.job),
        gang = json.encode(pd.gang),
        position = json.encode(position),
        metadata = json.encode(pd.metadata),
        weight = tonumber(pd.weight) or Config.Player.maxWeight,
        slots = tonumber(pd.slots) or Config.Player.maxSlots,
        outlawstatus = tonumber(pd.outlawstatus) or 0,
    }
end

---Save an online player. `sync` = true waits for the write (logout / drop paths).
function PlayerAPI.Save(source, sync)
    source = LXRCore.ToSource(source)
    local player = source and LXRCore.Players[source]
    if not player then
        LXRCore.ShowError(LXRCore.ResourceName, 'Player.Save: no player for source ' .. tostring(source))
        return false
    end
    local pd = player.PlayerData
    local ped = GetPlayerPed(source)
    local position = pd.position
    if ped and ped > 0 then
        local c = GetEntityCoords(ped)
        position = { x = c.x, y = c.y, z = c.z, w = GetEntityHeading(ped) }
        pd.position = position
    end
    local params = buildSaveParams(pd, position)
    player._dirty = false
    saveInProgress[pd.citizenid] = true
    if sync then
        LXRCore.DB.Insert(SAVE_SQL, params)
        Inventory.Save(source, false)
        saveInProgress[pd.citizenid] = nil
    else
        MySQL.insert(SAVE_SQL, params, function() saveInProgress[pd.citizenid] = nil end)
        Inventory.Save(source, false)
    end
    LXRCore.Metrics.Inc('player.save')
    LXRCore.Log.debug('player', 'saved', { citizenid = pd.citizenid, sync = sync == true })
    return true
end

function PlayerAPI.SaveOffline(pd)
    if type(pd) ~= 'table' or not pd.citizenid then return false end
    LXRCore.DB.Insert(SAVE_SQL, buildSaveParams(pd, pd.position or Config.General.defaultSpawn))
    Inventory.Save(pd, true)
    LXRCore.Log.debug('player', 'offline saved', { citizenid = pd.citizenid })
    return true
end

---Periodic save: only dirty players, spread across small batches.
function PlayerAPI.SaveAll(force)
    local batch, count = 0, 0
    for source, player in pairs(LXRCore.Players) do
        if force or player._dirty then
            player.Functions.PersistStateBags()
            PlayerAPI.Save(source, false)
            count = count + 1
            batch = batch + 1
            if batch >= (Config.Performance.saveBatchSize or 25) then
                batch = 0
                Wait(Config.Performance.saveBatchDelayMs or 50)
            end
        end
    end
    if count > 0 then LXRCore.Log.debug('player', ('periodic save: %d players'):format(count)) end
    return count
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS (O(1) where possible)
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRCore.Functions.GetPlayer(source)
    if type(source) == 'number' then return LXRCore.Players[source] end
    local n = tonumber(source)
    if n then return LXRCore.Players[n] end
    if type(source) == 'string' then
        -- identifier lookup (license / steam / discord …)
        for _, player in pairs(LXRCore.Players) do
            local ids = player.PlayerData.identifiers or {}
            for _, id in pairs(ids) do
                if id == source then return player end
            end
        end
    end
    return nil
end

function LXRCore.Functions.GetPlayerByCitizenId(citizenid)
    return LXRCore.PlayersByCitizenId[citizenid]
end

function LXRCore.Functions.GetPlayerByLicense(license)
    return LXRCore.PlayersByLicense[license] or PlayerAPI.GetOfflinePlayerByLicense(license)
end

function LXRCore.Functions.GetPlayerByAccount(account)
    for _, player in pairs(LXRCore.Players) do
        if player.PlayerData.charinfo.account == account then return player end
    end
    return nil
end

function LXRCore.Functions.GetPlayerByCharInfo(property, value)
    for _, player in pairs(LXRCore.Players) do
        if player.PlayerData.charinfo[property] == value then return player end
    end
    return nil
end

function LXRCore.Functions.GetSource(identifier)
    local player = LXRCore.Functions.GetPlayer(identifier)
    return player and player.PlayerData.source or 0
end

function LXRCore.Functions.GetPlayers()
    local out = {}
    for source in pairs(LXRCore.Players) do out[#out + 1] = source end
    return out
end

function LXRCore.Functions.GetLXRPlayers() return LXRCore.Players end
LXRCore.Functions.GetRSGPlayers = LXRCore.Functions.GetLXRPlayers
LXRCore.Functions.GetQBPlayers = LXRCore.Functions.GetLXRPlayers

function LXRCore.Functions.GetPlayersOnDuty(job)
    local out, count = {}, 0
    for source, player in pairs(LXRCore.Players) do
        local j = player.PlayerData.job
        if j.name == job and j.onduty then
            out[#out + 1] = source
            count = count + 1
        end
    end
    return out, count
end

function LXRCore.Functions.GetDutyCount(job)
    local _, count = LXRCore.Functions.GetPlayersOnDuty(job)
    return count
end

function LXRCore.Functions.GetPlayersByJob(job)
    local out = {}
    for source, player in pairs(LXRCore.Players) do
        if player.PlayerData.job.name == job then out[#out + 1] = source end
    end
    return out
end

function PlayerAPI.GetOfflinePlayer(citizenid)
    if not PlayerAPI.ValidateCitizenId(citizenid) then return nil end
    local row = LXRCore.DB.Single('SELECT * FROM players WHERE citizenid = ?', { citizenid })
    if not row then return nil end
    local pd = decodeRow(row)
    local player = PlayerAPI.CheckPlayerData(nil, pd)
    player.PlayerData.items = Inventory.CoreLogic.Deserialize(LXRCore.DB.Scalar('SELECT inventory FROM players WHERE citizenid = ?', { citizenid }))
    return player
end
LXRCore.Functions.GetOfflinePlayerByCitizenId = PlayerAPI.GetOfflinePlayer

function PlayerAPI.GetOfflinePlayerByLicense(license)
    if type(license) ~= 'string' then return nil end
    local row = LXRCore.DB.Single('SELECT * FROM players WHERE license = ? ORDER BY last_updated DESC LIMIT 1', { license })
    if not row then return nil end
    return PlayerAPI.CheckPlayerData(nil, decodeRow(row))
end
PlayerAPI.GetPlayerByLicense = LXRCore.Functions.GetPlayerByLicense

---All characters for a license (multicharacter). Accepts a license string or a
---source (then imported VORP rows keyed by steam are included). Returns decoded rows.
function PlayerAPI.GetCharacters(licenseOrSource)
    local license, steam = licenseOrSource, nil
    local src = LXRCore.ToSource(licenseOrSource)
    if src then
        license = GetPlayerIdentifierByType(src, 'license')
        steam = Config.Database.relinkImportedRows and GetPlayerIdentifierByType(src, 'steam') or nil
    end
    if type(license) ~= 'string' then return {} end
    local rows = LXRCore.DB.Query('SELECT citizenid, cid, name, money, charinfo, job, gang, position, metadata, last_updated FROM players WHERE license = ? OR license = ? ORDER BY cid ASC', { license, steam or license }) or {}
    for _, row in ipairs(rows) do decodeRow(row) end
    return rows
end

function PlayerAPI.CountCharacters(license)
    return tonumber(LXRCore.DB.Scalar('SELECT COUNT(*) FROM players WHERE license = ?', { license })) or 0
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗑️ DELETE
-- ═══════════════════════════════════════════════════════════════════════════════

---Let resources add their own citizenid-keyed tables to the delete transaction.
function PlayerAPI.RegisterCharacterTable(tbl, column)
    if type(tbl) ~= 'string' or not tbl:match('^[%w_]+$') then return false end
    characterTables[#characterTables + 1] = { table = tbl, column = column or 'citizenid' }
    return true
end

local function deleteQueries(citizenid)
    local list = {}
    for _, tbl in ipairs(Config.Database.characterTables or {}) do
        if LXRCore.DB.TableExists(tbl) then list[#list + 1] = { table = tbl, column = 'citizenid' } end
    end
    for _, entry in ipairs(characterTables) do
        if LXRCore.DB.TableExists(entry.table) then list[#list + 1] = entry end
    end
    local queries = {}
    for i, entry in ipairs(list) do
        queries[i] = { query = ('DELETE FROM `%s` WHERE `%s` = ?'):format(entry.table, entry.column), values = { citizenid } }
    end
    return queries
end

---Delete one of the requesting player's own characters.
function PlayerAPI.DeleteCharacter(source, citizenid)
    source = LXRCore.ToSource(source)
    if not source or not PlayerAPI.ValidateCitizenId(citizenid) then return false end
    local license = GetPlayerIdentifierByType(source, 'license')
    local owner = LXRCore.DB.Scalar('SELECT license FROM players WHERE citizenid = ?', { citizenid })
    if not owner or owner ~= license then
        LXRCore.Log.exploit(source, 'delete of a character that is not theirs', { citizenid = citizenid })
        if Config.Security.kickOnExploit then DropPlayer(source, Lang:t('error.exploit_dropped')) end
        return false
    end
    if LXRCore.PlayersByCitizenId[citizenid] then
        PlayerAPI.Logout(LXRCore.PlayersByCitizenId[citizenid].PlayerData.source, true)
    end
    local ok = LXRCore.DB.Transaction(deleteQueries(citizenid))
    if ok then
        LXRCore.Emit('lxr:character:deleted', { legacy = 'LXRCore:Server:CharacterDeleted' }, source, citizenid)
        LXRCore.Log.info('player', 'character deleted', { source = source, citizenid = citizenid })
    end
    return ok
end

---Admin/console deletion of any character.
function PlayerAPI.ForceDeleteCharacter(citizenid)
    if not PlayerAPI.ValidateCitizenId(citizenid) then return false end
    local exists = LXRCore.DB.Scalar('SELECT license FROM players WHERE citizenid = ?', { citizenid })
    if not exists then return false end
    local online = LXRCore.PlayersByCitizenId[citizenid]
    if online then
        DropPlayer(online.PlayerData.source, 'An admin deleted the character you were playing')
    end
    local ok = LXRCore.DB.Transaction(deleteQueries(citizenid))
    if ok then
        LXRCore.Emit('lxr:character:deleted', { legacy = 'LXRCore:Server:CharacterDeleted' }, 0, citizenid)
        LXRCore.Log.warn('player', 'character force deleted', { citizenid = citizenid, by = LXRCore.Invoker() })
    end
    return ok
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔁 LOOPS — periodic save and paychecks (single server-side timers)
-- ═══════════════════════════════════════════════════════════════════════════════

function PlayerAPI.StartLoops()
    CreateThread(function()
        while true do
            Wait((Config.General.saveInterval or 5) * 60000)
            PlayerAPI.SaveAll(false)
        end
    end)

    if Config.General.paycheck and Config.General.paycheck.enabled then
        CreateThread(function()
            local cfg = Config.General.paycheck
            while true do
                Wait((cfg.intervalMin or 10) * 60000)
                for source, player in pairs(LXRCore.Players) do
                    local job = player.PlayerData.job
                    local def = LXRShared.Jobs[job.name]
                    local payment = tonumber(job.grade and job.grade.payment) or tonumber(job.payment) or 0
                    if def and payment > 0 and (def.offDutyPay or job.onduty) then
                        local paid = true
                        if cfg.fromSociety and GetResourceState(cfg.societyResource) == 'started' then
                            local okBal, balance = pcall(function() return exports[cfg.societyResource][cfg.societyExports.balance](nil, job.name) end)
                            if okBal and tonumber(balance) and balance > 0 then
                                if balance < payment then
                                    paid = false
                                    LXRCore.Notify(source, Lang:t('error.company_too_poor'), 'error')
                                else
                                    pcall(function() exports[cfg.societyResource][cfg.societyExports.remove](nil, job.name, payment, 'Employee paycheck') end)
                                end
                            end
                        end
                        if paid then
                            player.Functions.AddMoney(cfg.account or 'bank', payment, 'paycheck')
                            LXRCore.Notify(source, Lang:t('info.received_paycheck', { value = payment }), 'success')
                        end
                    end
                end
            end
        end)
    end
end

-- Legacy-friendly aliases
LXRCore.Player.Login = PlayerAPI.Login
LXRCore.Functions.Login = PlayerAPI.Login
LXRCore.Functions.Logout = PlayerAPI.Logout
LXRCore.Functions.GetCharacters = PlayerAPI.GetCharacters
