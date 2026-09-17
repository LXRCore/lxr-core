-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCore — Migration 0001: core schema
-- Tables owned by lxr-core. The `players` table keeps the RSG / QBR column shape so
-- inventory, multicharacter and appearance resources from those ecosystems keep
-- working without changes. All JSON columns are validated by application code.
-- © 2026 iBoss21 / LXRCore — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════

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
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `license` (`license`),
  KEY `last_updated` (`last_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bans` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) DEFAULT NULL,
  `license` VARCHAR(50) DEFAULT NULL,
  `discord` VARCHAR(50) DEFAULT NULL,
  `ip` VARCHAR(50) DEFAULT NULL,
  `reason` TEXT DEFAULT NULL,
  `expire` INT(11) DEFAULT NULL,
  `bannedby` VARCHAR(255) NOT NULL DEFAULT 'LXRCore',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
