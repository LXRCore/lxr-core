--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Gangs
     ═══════════════════════════════════════════════════════════════════════════
     Shape (RSG/QBR compatible):
       name = { label, grades = { ['0'] = { name, isboss } } }
     Add gangs here or at runtime: LXRCore.Functions.AddGang(name, data)
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

LXRShared.Gangs = {
    none = {
        name = 'none', label = 'No Gang',
        grades = { ['0'] = { name = 'Unaffiliated' } },
    },
    odriscoll = {
        name = 'odriscoll', label = "O'Driscoll Boys",
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Enforcer' },
            ['2'] = { name = 'Shot Caller' },
            ['3'] = { name = 'Boss', isboss = true },
        },
    },
    lemoyne = {
        name = 'lemoyne', label = 'Lemoyne Raiders',
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Enforcer' },
            ['2'] = { name = 'Shot Caller' },
            ['3'] = { name = 'Boss', isboss = true },
        },
    },
    delLobo = {
        name = 'delLobo', label = 'Del Lobo Gang',
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Enforcer' },
            ['2'] = { name = 'Shot Caller' },
            ['3'] = { name = 'Boss', isboss = true },
        },
    },
}
