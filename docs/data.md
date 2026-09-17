# 🐺 Shared data — the LXRCore catalog

Everything a character can own, ride, drive, shoot or work for is data in
`shared/*.lua`, built through `shared/catalog.lua` and validated offline
(`lua tests/run.lua`) and at boot (`Config.Catalog.validateOnBoot`).

| File | Table | Records | Definer |
|---|---|---|---|
| `shared/catalog.lua` | `LXRShared.States`, `Towns`, `Rarities`, `Animations`, `Props`, `ItemCategories` | world + vocabulary | — |
| `shared/items.lua` | `LXRShared.Items`, `StarterKits`, `StarterItems` | 579 items, 8 kits | `Catalog.Item / Food / Drink / Medical` |
| `shared/weapons.lua` | `LXRShared.Weapons` (by hash), `WeaponsByName`, `Ammo`, `AmmoClasses`, `WeaponCategories`, `WeaponComponents` | 61 weapons, 33 ammo | `W()` |
| `shared/horses.lua` | `LXRShared.HorseBreeds`, `Horses` (by model), `HorseClasses`, `HorseTiers` | 26 breeds, 120 coats | `breed() / coat()` |
| `shared/vehicles.lua` | `LXRShared.Vehicles` (= `Wagons`), `VehicleCategories` | 60 | `V()` |
| `shared/jobs.lua` | `LXRShared.Jobs`, `JobTypes`, `JobCategories` | 55 | `J()` |
| `shared/gangs.lua` | `LXRShared.Gangs`, `GangTypes`, `GangTemplate` | 18 | `G()` |

## Item record

```lua
{
  name, label, weight (g), type ('item'|'weapon'), image, unique, useable, shouldClose, description,
  category, rarity, stack, value ($1899), sellable, tradable, droppable, legal, era, tags = {...},
  effects = { hunger, thirst, health, stamina, stress, cleanliness, drunk, warmth, core_health, core_stamina,
              gold_core_health, gold_core_stamina, horse_* },
  use     = { time, anim, prop, consume, whileDead, whileCuffed, cooldown, xp = { skill, amount } },
  decay   = { hours, into } | nil,      -- `decay = false` in opts disables the category default
  quality = true,                        -- graded goods keep info.quality (1..3) / info.durability
  requires = { tool, job, skill = { name, level }, license },
}
```

Category profiles (`LXRShared.ItemCategories[cat].defaults`) fill in what a
record does not state, so `F('apple', 'Apple', 120, { hunger = 8 })` already
eats with the right animation, stacks to 10 and spoils. Opts always win.

## Lookups

```lua
LXRShared.ItemsByCategory('herb')          LXRShared.ItemsWithTag('horse_treat')     LXRShared.ItemValue('pelt_deer', quality)
LXRShared.GetWeapon(hashOrName)            LXRShared.WeaponsInCategory('revolver')   LXRShared.WeaponAcceptsAmmo(weapon, ammo)
LXRShared.GetHorse(modelOrHash)            LXRShared.HorsesForTown('valentine')      LXRShared.HorsesOfBreed('arabian')
LXRShared.GetVehicle(modelOrHash)          LXRShared.WagonsForShop('wagon', jobName)
LXRShared.JobsOfType('leo')                LXRShared.JobsInTown('rhodes')            LXRShared.JobHasPerm(PlayerData.job, 'armory')
LXRShared.GangHasPerm(PlayerData.gang, 'invite')   LXRShared.GangsAreRivals(a, b)   LXRShared.GangsInRegion('lemoyne')
LXRShared.Catalog.Validate()  --> { 'problem', ... }
```

## Rules the validator enforces

* item key == `name`, lowercase; known category, rarity, animation, prop;
* `decay.into`, `requires.tool` exist; weapon items have a weapon record and vice-versa;
* every ammo item a weapon lists exists; every ammo class has an item;
* jobs: grade `'0'` exists, keys are numeric strings, payments are numbers, town/type known;
* gangs: grade `'0'` exists, rivals/allies exist; horses: breed known, price numeric; wagons: category known;
* starter kits reference existing items.

## Status

Record shapes and lookups are covered by `tests/test_shared.lua`. Model and
animation names are RDR2 build 1491 names taken from documentation, **NOT
TESTED** in-game for the coats and components added beyond the common set.
