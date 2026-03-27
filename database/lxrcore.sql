-- =========================================================================
-- LXR-Core Database Schema (Normalized)
-- =========================================================================
-- This schema normalizes the players table by expanding JSON TEXT blobs
-- into proper typed columns for money, charinfo, job, gang, and position.
-- metadata and inventory remain as JSON TEXT due to their variable nature.
-- =========================================================================

-- =========================================================================
-- Players Table (Normalized)
-- =========================================================================
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,

  -- ===================== Money (DECIMAL columns) =====================
  `cash` DECIMAL(18,2) NOT NULL DEFAULT 2.00,
  `bank` DECIMAL(18,2) NOT NULL DEFAULT 5.00,
  `gold` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `goldcurrency` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `coins` DECIMAL(18,2) NOT NULL DEFAULT 50.00,
  `goldcoins` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `silvercoins` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `marshalcoins` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `trustcoins` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `diamonds` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `bloodmoney` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `bloodcoins` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `tokens` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `rewardtokens` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `promisarynotes` DECIMAL(18,2) NOT NULL DEFAULT 0.00,

  -- ===================== Character Info =====================
  `firstname` VARCHAR(50) DEFAULT NULL,
  `lastname` VARCHAR(50) DEFAULT NULL,
  `birthdate` VARCHAR(20) DEFAULT NULL,
  `gender` TINYINT(1) NOT NULL DEFAULT 0,
  `nationality` VARCHAR(50) NOT NULL DEFAULT 'USA',
  `account` VARCHAR(50) DEFAULT NULL,

  -- ===================== Job =====================
  `job_name` VARCHAR(50) NOT NULL DEFAULT 'unemployed',
  `job_label` VARCHAR(100) NOT NULL DEFAULT 'Civilian',
  `job_grade_name` VARCHAR(50) NOT NULL DEFAULT 'Freelancer',
  `job_grade_level` INT NOT NULL DEFAULT 0,
  `job_payment` INT NOT NULL DEFAULT 10,
  `job_onduty` TINYINT(1) NOT NULL DEFAULT 0,
  `job_isboss` TINYINT(1) NOT NULL DEFAULT 0,

  -- ===================== Gang =====================
  `gang_name` VARCHAR(50) NOT NULL DEFAULT 'none',
  `gang_label` VARCHAR(100) NOT NULL DEFAULT 'No Gang Affiliation',
  `gang_grade_name` VARCHAR(50) NOT NULL DEFAULT 'none',
  `gang_grade_level` INT NOT NULL DEFAULT 0,
  `gang_isboss` TINYINT(1) NOT NULL DEFAULT 0,

  -- ===================== Position =====================
  `pos_x` DOUBLE NOT NULL DEFAULT -1035.71,
  `pos_y` DOUBLE NOT NULL DEFAULT -2731.87,
  `pos_z` DOUBLE NOT NULL DEFAULT 12.86,
  `pos_heading` DOUBLE NOT NULL DEFAULT 0.0,

  -- ===================== Flexible JSON Data =====================
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,

  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),

  -- ===================== Keys & Indexes =====================
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`),
  KEY `idx_citizenid_license` (`citizenid`, `license`)

  -- FK constraint placeholder: add foreign keys when referenced tables are created
  -- e.g. FOREIGN KEY (`citizenid`) REFERENCES `some_table`(`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1;

-- =========================================================================
-- Bans Table
-- =========================================================================
CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

-- =========================================================================
-- Player Contacts Table
-- =========================================================================
CREATE TABLE IF NOT EXISTS `player_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

-- =========================================================================
-- Dev Myths Table
-- =========================================================================
CREATE TABLE IF NOT EXISTS lxrcore.dev_myths (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `myth_entry` varchar(255) NOT NULL DEFAULT 'Liberty is the soul of progress, and code is the path we forge.',
  `author` varchar(50) NOT NULL DEFAULT 'https://github.com/iboss21',
  `dev_credits` varchar(255) NOT NULL DEFAULT 'iBoss - Developer and Contributor',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

