-- ============================================
-- LXRCore v2.0.0 - Database Tables
-- Supreme Performance, Security & Logging
-- 
-- Made by iBoss • LXRCore - www.lxrcore.com
-- Launched on The Land of Wolves RP - www.wolves.land
-- ============================================

-- ============================================
-- LOGGING SYSTEM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  `category` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `data` longtext DEFAULT NULL,
  `source` varchar(50) DEFAULT NULL,
  `resource` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `category` (`category`),
  KEY `source` (`source`),
  KEY `datetime` (`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ANTI-CHEAT SYSTEM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `anticheat_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `violation_type` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `flags` int(11) DEFAULT 1,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `violation_type` (`violation_type`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- BAN SYSTEM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `expire` int(11) NOT NULL DEFAULT 2147483647,
  `bannedby` varchar(255) DEFAULT 'System',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `license` (`license`),
  KEY `expire` (`expire`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- DEBUG SYSTEM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `debug_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` varchar(50) NOT NULL,
  `level` varchar(20) NOT NULL,
  `message` text NOT NULL,
  `data` longtext DEFAULT NULL,
  `resource` varchar(100) DEFAULT NULL,
  `trace` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `level` (`level`),
  KEY `resource` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ANTI-DUPE SYSTEM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `antidupe_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `transaction_type` varchar(50) NOT NULL,
  `details` text DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `citizenid` (`citizenid`),
  KEY `flagged` (`flagged`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- PERFORMANCE MONITORING TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS `performance_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `metric_type` varchar(50) NOT NULL,
  `metric_value` float NOT NULL,
  `details` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `metric_type` (`metric_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- DATABASE QUERY CACHE
-- ============================================

CREATE TABLE IF NOT EXISTS `query_cache` (
  `cache_key` varchar(255) NOT NULL,
  `cache_value` longtext NOT NULL,
  `expires_at` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`cache_key`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- WEBHOOK QUEUE (Optional - for persistence)
-- ============================================

CREATE TABLE IF NOT EXISTS `webhook_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text NOT NULL,
  `payload` longtext NOT NULL,
  `retries` int(11) DEFAULT 0,
  `status` enum('pending','sent','failed') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- SECURITY AUDIT TRAIL
-- ============================================

CREATE TABLE IF NOT EXISTS `security_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `severity` enum('low','medium','high','critical') NOT NULL,
  `user_license` varchar(50) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `details` longtext DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `event_type` (`event_type`),
  KEY `severity` (`severity`),
  KEY `user_license` (`user_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- PLAYER SESSION TRACKING
-- ============================================

CREATE TABLE IF NOT EXISTS `player_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `license` varchar(50) NOT NULL,
  `session_start` datetime NOT NULL,
  `session_end` datetime DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT 0,
  `disconnect_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `session_start` (`session_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ECONOMY TRANSACTION LOG
-- ============================================

CREATE TABLE IF NOT EXISTS `economy_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `from_citizenid` varchar(50) DEFAULT NULL,
  `to_citizenid` varchar(50) DEFAULT NULL,
  `transaction_type` varchar(50) NOT NULL,
  `currency_type` varchar(50) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `balance_before` decimal(15,2) DEFAULT NULL,
  `balance_after` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `from_citizenid` (`from_citizenid`),
  KEY `to_citizenid` (`to_citizenid`),
  KEY `transaction_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- INVENTORY TRANSACTION LOG
-- ============================================

CREATE TABLE IF NOT EXISTS `inventory_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `transaction_type` enum('add','remove','use','trade','drop','pickup') NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `item_amount` int(11) NOT NULL,
  `item_info` longtext DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `citizenid` (`citizenid`),
  KEY `item_name` (`item_name`),
  KEY `transaction_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ADMIN ACTION LOG
-- ============================================

CREATE TABLE IF NOT EXISTS `admin_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `admin_license` varchar(50) NOT NULL,
  `admin_name` varchar(255) NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `target_license` varchar(50) DEFAULT NULL,
  `target_name` varchar(255) DEFAULT NULL,
  `command` varchar(255) DEFAULT NULL,
  `parameters` text DEFAULT NULL,
  `reason` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `admin_license` (`admin_license`),
  KEY `action_type` (`action_type`),
  KEY `target_license` (`target_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- INDEXES FOR BETTER PERFORMANCE
-- ============================================

-- Optimize log queries
ALTER TABLE `logs` 
  ADD INDEX `idx_category_timestamp` (`category`, `timestamp`),
  ADD INDEX `idx_source_timestamp` (`source`, `timestamp`);

-- Optimize anticheat queries
ALTER TABLE `anticheat_logs`
  ADD INDEX `idx_license_timestamp` (`license`, `timestamp`);

-- Optimize economy queries
ALTER TABLE `economy_transactions`
  ADD INDEX `idx_from_timestamp` (`from_citizenid`, `timestamp`),
  ADD INDEX `idx_to_timestamp` (`to_citizenid`, `timestamp`);

-- ============================================
-- CLEANUP PROCEDURES (Optional)
-- ============================================

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS `cleanup_old_logs`(IN days_to_keep INT)
BEGIN
    DECLARE cutoff_date DATETIME;
    SET cutoff_date = DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    -- Archive to backup table (optional)
    INSERT INTO logs_archive SELECT * FROM logs WHERE datetime < cutoff_date;
    
    -- Delete old logs
    DELETE FROM logs WHERE datetime < cutoff_date;
    DELETE FROM debug_logs WHERE timestamp < DATE_FORMAT(cutoff_date, '%Y-%m-%d %H:%i:%s');
    DELETE FROM performance_logs WHERE timestamp < cutoff_date;
    
    SELECT CONCAT('Cleaned up logs older than ', days_to_keep, ' days') AS result;
END$$

DELIMITER ;

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

CREATE OR REPLACE VIEW `recent_anticheat_flags` AS
SELECT 
    license,
    player_name,
    violation_type,
    COUNT(*) as flag_count,
    MAX(timestamp) as last_flag
FROM anticheat_logs
WHERE timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY license, violation_type
HAVING flag_count > 3;

CREATE OR REPLACE VIEW `player_activity_summary` AS
SELECT 
    citizenid,
    COUNT(DISTINCT DATE(session_start)) as days_played,
    SUM(duration_minutes) as total_minutes,
    MAX(session_end) as last_seen
FROM player_sessions
WHERE session_end IS NOT NULL
GROUP BY citizenid;

CREATE OR REPLACE VIEW `admin_action_summary` AS
SELECT 
    admin_name,
    action_type,
    COUNT(*) as action_count,
    MAX(timestamp) as last_action
FROM admin_actions
WHERE timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY admin_name, action_type;

-- ============================================
-- INITIAL DATA / TESTING
-- ============================================

-- Insert test log to verify table creation
INSERT INTO logs (timestamp, datetime, category, title, data, source, resource) 
VALUES (UNIX_TIMESTAMP(), NOW(), 'system', 'Database Tables Created', '{"version":"2.0.0"}', 'server', 'lxr-core');

-- ============================================
-- GRANTS (Adjust username as needed)
-- ============================================

-- GRANT SELECT, INSERT, UPDATE, DELETE ON lxrcore.* TO 'your_mysql_user'@'localhost';
-- FLUSH PRIVILEGES;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

SELECT 'LXRCore v2.0.0 Database Tables Created Successfully!' as status,
       'All tables, indexes, and views are ready' as message,
       'Made by iBoss • LXRCore - www.lxrcore.com' as author;
