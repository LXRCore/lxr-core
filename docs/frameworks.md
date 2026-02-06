# 🐺 LXR Core - Frameworks & Compatibility

```
██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**Multi-Framework Adapter & Compatibility Layer**

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🔄 MULTI-FRAMEWORK SUPPORT
## ═══════════════════════════════════════════════════════════════════════════════

LXR Core includes a **unified framework adapter** (`shared/framework.lua`) that provides a consistent API across multiple RedM frameworks. This allows resources built for one framework to work with others seamlessly.

### Supported Frameworks

| Framework | Status | Priority | Compatibility |
|-----------|--------|----------|---------------|
| **LXR-Core** | ✅ Native | Primary | 100% |
| **RSG-Core** | ✅ Compatible | Primary | 95% |
| **VORP Core** | ✅ Compatible | Supported | 90% |
| **RedEM:RP** | ✅ Compatible | Optional | 85% |
| **QBR-Core** | ✅ Compatible | Optional | 85% |
| **QR-Core** | ✅ Compatible | Optional | 85% |
| **Standalone** | ✅ Fallback | Fallback | 50% |

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🎯 AUTO-DETECTION
## ═══════════════════════════════════════════════════════════════════════════════

The framework adapter automatically detects which framework is running:

```lua
-- Automatic detection at startup
LXRFramework.ActiveFramework      -- Returns: 'lxr-core', 'rsg-core', 'vorp_core', etc.

-- Check what was detected
LXRFramework.DetectedFrameworks   -- Table of all detected frameworks
```

### Detection Priority

1. **LXR-Core** - Always preferred if present
2. **RSG-Core** - Checked second
3. **VORP Core** - Checked third
4. **RedEM:RP** - Optional detection
5. **QBR-Core** - Optional detection
6. **QR-Core** - Optional detection
7. **Standalone** - Fallback if none found

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📚 UNIFIED ADAPTER API
## ═══════════════════════════════════════════════════════════════════════════════

### Server-Side Functions

#### Notify
```lua
LXRFramework.Notify(source, type, message, duration)

-- Examples:
LXRFramework.Notify(source, 'success', 'Action completed!', 5000)
LXRFramework.Notify(source, 'error', 'Something went wrong!', 3000)
LXRFramework.Notify(source, 'info', 'Information message', 4000)
```

#### Player Data
```lua
LXRFramework.GetPlayerData(source)
LXRFramework.GetJob(source)
LXRFramework.GetGang(source)
LXRFramework.IsPlayerLoaded(source)
LXRFramework.GetIdentifier(source, 'license')

-- Examples:
local playerData = LXRFramework.GetPlayerData(source)
local job = LXRFramework.GetJob(source)  -- Returns: {name = 'police', grade = 2}
local isLoaded = LXRFramework.IsPlayerLoaded(source)  -- Returns: true/false
```

#### Money Operations
```lua
LXRFramework.AddMoney(source, account, amount, reason)
LXRFramework.RemoveMoney(source, account, amount, reason)
LXRFramework.GetMoney(source, account)

-- Examples:
LXRFramework.AddMoney(source, 'cash', 100, 'Job payment')
LXRFramework.RemoveMoney(source, 'bank', 50, 'Purchase item')
local cashAmount = LXRFramework.GetMoney(source, 'cash')
```

#### Item Operations
```lua
LXRFramework.AddItem(source, item, amount, metadata, reason)
LXRFramework.RemoveItem(source, item, amount, reason)
LXRFramework.HasItem(source, item, amount)
LXRFramework.GetItemCount(source, item)

-- Examples:
LXRFramework.AddItem(source, 'bread', 5, {freshness = 100}, 'Shop purchase')
LXRFramework.RemoveItem(source, 'water', 1, 'Consumed')
local hasBread = LXRFramework.HasItem(source, 'bread', 3)  -- true if has 3+
local count = LXRFramework.GetItemCount(source, 'bread')  -- Returns: number
```

### Client-Side Functions

#### Notify (Client)
```lua
LXRFramework.Notify(type, message, duration)

-- Examples:
LXRFramework.Notify('success', 'Item added to inventory!', 5000)
LXRFramework.Notify('error', 'You don\'t have enough money!', 3000)
```

#### Player Data (Client)
```lua
LXRFramework.GetPlayerData()
LXRFramework.GetJob()
LXRFramework.HasItem(item, amount)

-- Examples:
local playerData = LXRFramework.GetPlayerData()
local job = LXRFramework.GetJob()
local hasBread = LXRFramework.HasItem('bread', 1)
```

#### Progress Bar (Client)
```lua
LXRFramework.ProgressBar(label, duration, useWhileDead, canCancel, disableControls)

-- Example:
LXRFramework.ProgressBar('Cooking...', 5000, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = false,
    disableCombat = true
})
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🗺️ FRAMEWORK MAPPINGS
## ═══════════════════════════════════════════════════════════════════════════════

### LXR-Core (Native)

```lua
-- Direct calls - no translation needed
LXRCore.Functions.GetPlayer(source)
Player.Functions.AddMoney(account, amount, reason)
Player.Functions.AddItem(item, amount, slot, metadata, reason)
```

### RSG-Core

```lua
-- Adapter translates to:
exports['rsg-core']:GetPlayer(source)
Player.Functions.AddMoney(account, amount, reason)
exports['rsg-inventory']:AddItem(source, item, amount, slot, metadata, reason)
```

### VORP Core

```lua
-- Adapter translates to:
exports.vorp_core:getUser(source)
Character.addCurrency(0, amount)  -- 0 = cash, 1 = gold
exports.vorp_inventory:addItem(source, item, amount, metadata)
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🛠️ USING THE ADAPTER IN YOUR RESOURCES
## ═══════════════════════════════════════════════════════════════════════════════

### Step 1: Add Shared Script

In your resource's `fxmanifest.lua`:

```lua
shared_scripts {
    '@lxr-core/shared/framework.lua',  -- Add this line
    -- your other shared scripts
}
```

### Step 2: Use Unified API

Replace framework-specific calls with unified calls:

**Before (Framework-Specific):**
```lua
-- LXR-Core specific
local Player = LXRCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 100)

-- VORP specific
local User = exports.vorp_core:getUser(source)
local Character = User.getUsedCharacter
Character.addCurrency(0, 100)
```

**After (Unified):**
```lua
-- Works with ALL frameworks!
LXRFramework.AddMoney(source, 'cash', 100, 'Reward')
```

### Step 3: Enjoy Cross-Framework Compatibility

Your resource now works with:
- LXR-Core
- RSG-Core
- VORP Core
- RedEM:RP
- QBR-Core
- QR-Core
- Standalone

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📋 COMPLETE API REFERENCE
## ═══════════════════════════════════════════════════════════════════════════════

See [Events Documentation](./events.md) for complete API reference with examples.

---

**🐺 wolves.land - The Land of Wolves**  
*ისტორია ცოცხლდება აქ! (History Lives Here!)*

© 2026 iBoss21 / The Lux Empire | All Rights Reserved
