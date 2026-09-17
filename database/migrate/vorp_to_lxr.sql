-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCore — Migration: VORP database → LXRCore
-- ═══════════════════════════════════════════════════════════════════════════════
-- Converts VORP `characters` rows into LXRCore `players` rows. VORP keys players
-- by steam identifier and has no Rockstar license, so the `license` column is
-- filled with the steam id; LXRCore re-links each character to the real license
-- on the player's first login (Config.Database.relinkImportedRows = true).
--
-- Mapping (verified against VORPCORE/VORP_txAdmin MariaDB.sql):
--   characters.charidentifier → players.citizenid  ('VORP' + zero-padded id)
--   characters.identifier     → players.license    (steam:…, relinked later)
--   money / gold / rol        → money JSON {cash, gold, bloodmoney}
--   firstname / lastname / gender / age → charinfo JSON
--   job / jobgrade / joblabel → job JSON (grade name resolved at login from LXRShared.Jobs)
--   coords {x,y,z,heading}    → position JSON {x,y,z,w}
--   healthouter / isdead      → metadata JSON
--   inventory JSON            → NOT converted (VORP stores items in character_inventories);
--                               see docs/migration.md for the item pass
-- Run on a BACKUP. Idempotent: existing citizenids are skipped (INSERT IGNORE).
-- © 2026 iBoss21 / LXRCore — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════

-- 0. Pre-flight (read-only)
SELECT COUNT(*) AS vorp_characters, COUNT(DISTINCT identifier) AS vorp_users FROM characters;

-- 1. Target tables (same definitions as database/schema.sql)
CREATE TABLE IF NOT EXISTS `players` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `cid` INT(11) DEFAULT NULL,
  `license` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `outlawstatus` INT(11) NOT NULL DEFAULT 0,
  `money` TEXT NOT NULL,
  `charinfo` TEXT DEFAULT NULL,
  `job` TEXT NOT NULL,
  `gang` TEXT DEFAULT NULL,
  `position` TEXT NOT NULL,
  `metadata` TEXT NOT NULL,
  `inventory` LONGTEXT DEFAULT NULL,
  `weight` INT(11) NOT NULL DEFAULT 120000,
  `slots` INT(11) NOT NULL DEFAULT 41,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`), KEY `id` (`id`), KEY `license` (`license`), KEY `last_updated` (`last_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Characters
INSERT IGNORE INTO `players` (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata, inventory, weight, slots)
SELECT
  CONCAT('VORP', LPAD(c.charidentifier, 6, '0')),
  ROW_NUMBER() OVER (PARTITION BY c.identifier ORDER BY c.charidentifier),
  c.identifier,
  COALESCE(NULLIF(c.steamname, ''), CONCAT(c.firstname, ' ', c.lastname)),
  JSON_OBJECT('cash', ROUND(COALESCE(c.money, 0), 2), 'gold', FLOOR(COALESCE(c.gold, 0)), 'bloodmoney', ROUND(COALESCE(c.rol, 0), 2), 'bank', 0),
  JSON_OBJECT('firstname', c.firstname, 'lastname', c.lastname, 'gender', IF(LOWER(c.gender) = 'female', 1, 0),
              'birthdate', CAST(c.age AS CHAR), 'nationality', 'USA'),
  JSON_OBJECT('name', COALESCE(NULLIF(c.job, ''), 'unemployed'), 'label', COALESCE(c.joblabel, 'Civilian'),
              'onduty', TRUE, 'grade', JSON_OBJECT('level', COALESCE(c.jobgrade, 0))),
  JSON_OBJECT('name', 'none', 'grade', JSON_OBJECT('level', 0)),
  CASE WHEN JSON_VALID(c.coords) AND JSON_EXTRACT(c.coords, '$.x') IS NOT NULL
       THEN JSON_OBJECT('x', JSON_EXTRACT(c.coords, '$.x'), 'y', JSON_EXTRACT(c.coords, '$.y'), 'z', JSON_EXTRACT(c.coords, '$.z'),
                        'w', COALESCE(JSON_EXTRACT(c.coords, '$.heading'), 0))
       ELSE JSON_OBJECT('x', -1035.71, 'y', -2731.87, 'z', 12.86, 'w', 0) END,
  JSON_OBJECT('health', COALESCE(c.healthouter, 600), 'isdead', COALESCE(c.isdead, 0) = 1,
              'xp', JSON_OBJECT('main', COALESCE(c.xp, 0)), 'vorp', JSON_OBJECT('charidentifier', c.charidentifier, 'group', c.group, 'skin', c.skinPlayer, 'comps', c.compPlayer)),
  '[]',
  120000,
  GREATEST(10, FLOOR(COALESCE(c.slots, 35)))
FROM characters c;

-- 3. Bans (VORP stores bans on users)
CREATE TABLE IF NOT EXISTS `bans` (
  `id` INT(11) NOT NULL AUTO_INCREMENT, `name` VARCHAR(50) DEFAULT NULL, `license` VARCHAR(50) DEFAULT NULL,
  `discord` VARCHAR(50) DEFAULT NULL, `ip` VARCHAR(50) DEFAULT NULL, `reason` TEXT DEFAULT NULL, `expire` INT(11) DEFAULT NULL,
  `bannedby` VARCHAR(255) NOT NULL DEFAULT 'LXRCore', `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), KEY `license` (`license`), KEY `discord` (`discord`), KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `bans` (name, license, reason, expire, bannedby)
SELECT u.identifier, u.identifier, 'Imported from VORP', IF(COALESCE(u.banneduntil, 0) > 0, u.banneduntil, 2147483647), 'VORP import'
FROM users u WHERE u.banned = 1;

-- 4. Post-check
SELECT COUNT(*) AS imported_players FROM players WHERE citizenid LIKE 'VORP%';
