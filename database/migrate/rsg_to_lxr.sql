-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCore — Migration: RSG-Core database → LXRCore
-- ═══════════════════════════════════════════════════════════════════════════════
-- LXRCore keeps the RSG `players` / `bans` column shape, so an RSG database is
-- already usable. This script only:
--   1. adds the columns LXRCore relies on when they are missing
--   2. creates the LXRCore-only tables (ledger, migrations bookkeeping)
--   3. records the core migrations as applied so they are not re-run
-- Run inside a transaction on a BACKUP first. Nothing here deletes data.
-- Dry run: execute steps 0 and 1a only and inspect the counts.
-- © 2026 iBoss21 / LXRCore — All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════

-- 0. Pre-flight report (read-only)
SELECT COUNT(*) AS characters, COUNT(DISTINCT license) AS licenses FROM players;
SELECT COUNT(*) AS active_bans FROM bans WHERE expire > UNIX_TIMESTAMP();

-- 1a. Column report (read-only): every row below should show `present` = 1
SELECT 'weight' AS col, COUNT(*) AS present FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'weight'
UNION ALL SELECT 'slots', COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'slots'
UNION ALL SELECT 'outlawstatus', COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'outlawstatus';

-- 1b. Missing columns (MariaDB syntax; on MySQL 8 run each ALTER only when 1a reported 0)
ALTER TABLE `players` ADD COLUMN IF NOT EXISTS `weight` INT(11) NOT NULL DEFAULT 120000;
ALTER TABLE `players` ADD COLUMN IF NOT EXISTS `slots` INT(11) NOT NULL DEFAULT 41;
ALTER TABLE `players` ADD COLUMN IF NOT EXISTS `outlawstatus` INT(11) NOT NULL DEFAULT 0;
ALTER TABLE `players` ADD COLUMN IF NOT EXISTS `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `bans` ADD COLUMN IF NOT EXISTS `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 2. LXRCore tables
CREATE TABLE IF NOT EXISTS `lxr_migrations` (
  `name` VARCHAR(191) NOT NULL,
  `resource` VARCHAR(100) NOT NULL,
  `checksum` CHAR(8) NOT NULL,
  `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- 3. Mark the core migrations as applied (checksums are recomputed by the core on
--    first boot; a mismatch only logs a warning, it never re-runs a migration).
INSERT IGNORE INTO `lxr_migrations` (`name`, `resource`, `checksum`) VALUES
  ('core:0001_core_schema', 'lxr-core', 'imported'),
  ('core:0002_ledger', 'lxr-core', 'imported');

-- 4. Post-check (read-only)
SELECT name, applied_at FROM lxr_migrations;
