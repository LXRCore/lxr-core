-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCore — Full schema snapshot (generated from database/migrations/*.sql)
-- Use for manual installs; the core applies the same migrations automatically.
-- © 2026 iBoss21 / LXRCore — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCore — Migration 0002: money ledger
-- One row per account mutation (add / remove / set / transfer). Written in
-- batches by server/accounts.lua when Config.Money.Ledger.enabled is true.
-- © 2026 iBoss21 / LXRCore — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `lxr_ledger` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `account` VARCHAR(32) NOT NULL,
  `operation` VARCHAR(16) NOT NULL,
  `amount` DECIMAL(18,2) NOT NULL,
  `balance_after` DECIMAL(18,2) NOT NULL,
  `reason` VARCHAR(255) DEFAULT NULL,
  `resource` VARCHAR(100) DEFAULT NULL,
  `counterparty` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `citizenid_created` (`citizenid`, `created_at`),
  KEY `account` (`account`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
