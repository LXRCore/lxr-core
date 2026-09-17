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
