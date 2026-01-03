-- LXRCore Tebex Integration Database Tables
-- Run this SQL after installing LXRCore
-- Made by iBoss • LXRCore - www.lxrcore.com

-- Create Tebex queue table for offline deliveries
CREATE TABLE IF NOT EXISTS `tebex_queue` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(100) NOT NULL COMMENT 'Player identifier (license/steam)',
    `packages` LONGTEXT NOT NULL COMMENT 'JSON array of packages',
    `transaction_id` VARCHAR(255) NOT NULL COMMENT 'Tebex transaction ID',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `delivered` TINYINT(1) NOT NULL DEFAULT 0,
    `delivered_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_uuid` (`uuid`),
    INDEX `idx_delivered` (`delivered`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Tebex transactions log table
CREATE TABLE IF NOT EXISTS `tebex_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `transaction_id` VARCHAR(255) NOT NULL COMMENT 'Tebex transaction ID',
    `player_id` INT(11) NULL DEFAULT NULL COMMENT 'Player source ID at time of purchase',
    `identifier` VARCHAR(100) NOT NULL COMMENT 'Player identifier',
    `player_name` VARCHAR(255) NOT NULL,
    `package_id` INT(11) NOT NULL,
    `package_name` VARCHAR(255) NOT NULL,
    `amount` DECIMAL(10,2) NOT NULL COMMENT 'Purchase amount in real money',
    `currency` VARCHAR(10) NOT NULL DEFAULT 'USD',
    `goldcurrency_amount` INT(11) NOT NULL DEFAULT 0 COMMENT 'Gold currency delivered',
    `tokens_amount` INT(11) NOT NULL DEFAULT 0 COMMENT 'Tokens delivered',
    `status` ENUM('completed', 'refunded', 'chargeback') NOT NULL DEFAULT 'completed',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_transaction` (`transaction_id`),
    INDEX `idx_identifier` (`identifier`),
    INDEX `idx_status` (`status`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add indexes for performance
ALTER TABLE `tebex_queue` ADD INDEX `idx_created_at` (`created_at`);
ALTER TABLE `tebex_transactions` ADD INDEX `idx_package_id` (`package_id`);

-- Create view for admin dashboard
CREATE OR REPLACE VIEW `tebex_summary` AS
SELECT 
    DATE(created_at) as purchase_date,
    COUNT(*) as total_transactions,
    SUM(amount) as total_revenue,
    SUM(goldcurrency_amount) as total_gold_given,
    SUM(tokens_amount) as total_tokens_given,
    COUNT(CASE WHEN status = 'refunded' THEN 1 END) as refund_count,
    COUNT(CASE WHEN status = 'chargeback' THEN 1 END) as chargeback_count
FROM `tebex_transactions`
GROUP BY DATE(created_at)
ORDER BY purchase_date DESC;

-- Insert example data (optional - remove in production)
-- INSERT INTO `tebex_transactions` VALUES 
-- (1, 'TEST_TRANS_001', 1, 'license:abc123', 'TestPlayer', 1001, 'Starter Pack', 4.99, 'USD', 100, 50, 'completed', NOW(), NOW());

COMMIT;
