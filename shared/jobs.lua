--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Jobs
     ═══════════════════════════════════════════════════════════════════════════
     Shape (RSG/QBR compatible, consumed by every job resource):
       name        = { label, type, defaultDuty, offDutyPay,
                       grades = { ['0'] = { name, payment, isboss } } }
     Grades are string keys ('0', '1', …). The framework never hard-codes a job
     name; resources check `job.type` (leo, medical, …) or `job.name`.
     Add jobs here or at runtime: LXRCore.Functions.AddJob(name, data)
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}
LXRShared.ForceJobDefaultDutyAtLogin = true -- true: duty state reset to defaultDuty on login; false: keep saved duty

LXRShared.Jobs = {
    unemployed = {
        name = 'unemployed', label = 'Civilian', type = 'none', defaultDuty = true, offDutyPay = false,
        grades = { ['0'] = { name = 'Freelancer', payment = 3 } },
    },
    vallaw = {
        name = 'vallaw', label = 'Valentine Law Enforcement', type = 'leo', defaultDuty = false, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', payment = 50, isboss = true },
        },
    },
    rholaw = {
        name = 'rholaw', label = 'Rhodes Law Enforcement', type = 'leo', defaultDuty = false, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', payment = 50, isboss = true },
        },
    },
    blklaw = {
        name = 'blklaw', label = 'Blackwater Law Enforcement', type = 'leo', defaultDuty = false, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Marshal', payment = 50, isboss = true },
        },
    },
    stdlaw = {
        name = 'stdlaw', label = 'Saint Denis Police', type = 'leo', defaultDuty = false, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Officer', payment = 25 },
            ['2'] = { name = 'Chief', payment = 50, isboss = true },
        },
    },
    medic = {
        name = 'medic', label = 'Doctor', type = 'medical', defaultDuty = false, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 10 },
            ['1'] = { name = 'Doctor', payment = 25 },
            ['2'] = { name = 'Head Doctor', payment = 50, isboss = true },
        },
    },
    rancher = {
        name = 'rancher', label = 'Rancher', type = 'civ', defaultDuty = true, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Ranch Hand', payment = 8 },
            ['1'] = { name = 'Foreman', payment = 15 },
            ['2'] = { name = 'Ranch Owner', payment = 25, isboss = true },
        },
    },
    blacksmith = {
        name = 'blacksmith', label = 'Blacksmith', type = 'civ', defaultDuty = true, offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 8 },
            ['1'] = { name = 'Smith', payment = 15 },
            ['2'] = { name = 'Master Smith', payment = 25, isboss = true },
        },
    },
}
