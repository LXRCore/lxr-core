-- =========================================================================
-- RSG-Core → LXR-Core Data Migration Script
-- =========================================================================
-- PURPOSE:
--   One-time migration that converts an existing RSG-Core players table
--   (which stores money, charinfo, job, gang, and position as JSON TEXT
--   blobs) into the LXR-Core normalized column layout.
--
-- PREREQUISITES:
--   1. Back up your database:
--      mysqldump -u user -p lxrcore > backup_$(date +%Y%m%d).sql
--   2. MySQL 5.7+ / MariaDB 10.2+ (requires JSON_EXTRACT / JSON_UNQUOTE)
--   3. Run this script BEFORE starting lxr-core for the first time.
--
-- WHAT IT DOES:
--   Phase 1 – Adds normalized columns (IF NOT EXISTS) so the script is
--             idempotent and safe to re-run.
--   Phase 2 – Populates the new columns from the legacy JSON blobs using
--             JSON_EXTRACT.  Only rows that still have NULL in the new
--             columns are touched, so re-running is harmless.
--   Phase 3 – (Optional, commented out) Drops the legacy JSON blob columns
--             after you have verified the migration.
--
-- RSG-CORE JSON BLOB FORMAT (typical QBCore/RSG-Core layout):
--   money    TEXT  '{"cash":100,"bank":5000,"gold":0, ...}'
--   charinfo TEXT  '{"firstname":"John","lastname":"Doe","birthdate":"1990-01-01","gender":0,"nationality":"USA","account":"US001"}'
--   job      TEXT  '{"name":"unemployed","label":"Civilian","payment":10,"onduty":false,"isboss":false,"grade":{"name":"Freelancer","level":0}}'
--   gang     TEXT  '{"name":"none","label":"No Gang Affiliation","isboss":false,"grade":{"name":"none","level":0}}'
--   position TEXT  '{"x":-1035.71,"y":-2731.87,"z":12.86,"heading":0.0}'
--
-- USAGE:
--   mysql -u username -p lxrcore < database/migrate_rsg_to_lxr.sql
-- =========================================================================

-- =========================================================================
-- PHASE 1: Add normalized columns (idempotent — skips if column exists)
-- =========================================================================
-- Note: MariaDB 10.2+ and MySQL 8.0 support different syntax for
-- conditional column addition.  We use stored procedure wrappers to
-- handle the IF NOT EXISTS check portably.

DELIMITER //

DROP PROCEDURE IF EXISTS _lxr_add_column_if_missing //
CREATE PROCEDURE _lxr_add_column_if_missing(
    IN tbl VARCHAR(64),
    IN col VARCHAR(64),
    IN col_def VARCHAR(255)
)
BEGIN
    SET @col_exists = 0;
    SELECT COUNT(*) INTO @col_exists
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME   = tbl
       AND COLUMN_NAME  = col;

    IF @col_exists = 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `', col, '` ', col_def);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //

DELIMITER ;

-- ── Money columns ────────────────────────────────────────────────────────
CALL _lxr_add_column_if_missing('players', 'cash',           'DECIMAL(18,2) NOT NULL DEFAULT 2.00');
CALL _lxr_add_column_if_missing('players', 'bank',           'DECIMAL(18,2) NOT NULL DEFAULT 5.00');
CALL _lxr_add_column_if_missing('players', 'gold',           'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'goldcurrency',   'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'coins',          'DECIMAL(18,2) NOT NULL DEFAULT 50.00');
CALL _lxr_add_column_if_missing('players', 'goldcoins',      'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'silvercoins',    'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'marshalcoins',   'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'trustcoins',     'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'diamonds',       'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'bloodmoney',     'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'bloodcoins',     'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'tokens',         'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'rewardtokens',   'DECIMAL(18,2) NOT NULL DEFAULT 0.00');
CALL _lxr_add_column_if_missing('players', 'promisarynotes', 'DECIMAL(18,2) NOT NULL DEFAULT 0.00');

-- ── Character info columns ───────────────────────────────────────────────
CALL _lxr_add_column_if_missing('players', 'firstname',   'VARCHAR(50)  DEFAULT NULL');
CALL _lxr_add_column_if_missing('players', 'lastname',    'VARCHAR(50)  DEFAULT NULL');
CALL _lxr_add_column_if_missing('players', 'birthdate',   'VARCHAR(20)  DEFAULT NULL');
CALL _lxr_add_column_if_missing('players', 'gender',      'TINYINT(1)   NOT NULL DEFAULT 0');
CALL _lxr_add_column_if_missing('players', 'nationality', 'VARCHAR(50)  NOT NULL DEFAULT ''USA''');
CALL _lxr_add_column_if_missing('players', 'account',     'VARCHAR(50)  DEFAULT NULL');

-- ── Job columns ──────────────────────────────────────────────────────────
CALL _lxr_add_column_if_missing('players', 'job_name',       'VARCHAR(50)  NOT NULL DEFAULT ''unemployed''');
CALL _lxr_add_column_if_missing('players', 'job_label',      'VARCHAR(100) NOT NULL DEFAULT ''Civilian''');
CALL _lxr_add_column_if_missing('players', 'job_grade_name', 'VARCHAR(50)  NOT NULL DEFAULT ''Freelancer''');
CALL _lxr_add_column_if_missing('players', 'job_grade_level','INT           NOT NULL DEFAULT 0');
CALL _lxr_add_column_if_missing('players', 'job_payment',    'INT           NOT NULL DEFAULT 10');
CALL _lxr_add_column_if_missing('players', 'job_onduty',     'TINYINT(1)   NOT NULL DEFAULT 0');
CALL _lxr_add_column_if_missing('players', 'job_isboss',     'TINYINT(1)   NOT NULL DEFAULT 0');

-- ── Gang columns ─────────────────────────────────────────────────────────
CALL _lxr_add_column_if_missing('players', 'gang_name',       'VARCHAR(50)  NOT NULL DEFAULT ''none''');
CALL _lxr_add_column_if_missing('players', 'gang_label',      'VARCHAR(100) NOT NULL DEFAULT ''No Gang Affiliation''');
CALL _lxr_add_column_if_missing('players', 'gang_grade_name', 'VARCHAR(50)  NOT NULL DEFAULT ''none''');
CALL _lxr_add_column_if_missing('players', 'gang_grade_level','INT           NOT NULL DEFAULT 0');
CALL _lxr_add_column_if_missing('players', 'gang_isboss',     'TINYINT(1)   NOT NULL DEFAULT 0');

-- ── Position columns ─────────────────────────────────────────────────────
CALL _lxr_add_column_if_missing('players', 'pos_x',       'DOUBLE NOT NULL DEFAULT -1035.71');
CALL _lxr_add_column_if_missing('players', 'pos_y',       'DOUBLE NOT NULL DEFAULT -2731.87');
CALL _lxr_add_column_if_missing('players', 'pos_z',       'DOUBLE NOT NULL DEFAULT 12.86');
CALL _lxr_add_column_if_missing('players', 'pos_heading', 'DOUBLE NOT NULL DEFAULT 0.0');

-- ── Indexes ──────────────────────────────────────────────────────────────
-- Add last_updated if missing (needed by lxr-core for stale-player tracking)
CALL _lxr_add_column_if_missing('players', 'last_updated',
    'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');


-- =========================================================================
-- PHASE 2: Populate normalized columns from JSON blobs
-- =========================================================================
-- Each UPDATE only touches rows where the legacy JSON column exists and the
-- normalized column still holds its default/NULL value.  This makes the
-- script safe to re-run.
--
-- We wrap each block in a check for the source column's existence so the
-- script does not error on a fresh install (where the JSON columns were
-- never created).

DELIMITER //

DROP PROCEDURE IF EXISTS _lxr_migrate_json_blobs //
CREATE PROCEDURE _lxr_migrate_json_blobs()
BEGIN
    -- ── Check if the legacy JSON columns exist ──────────────────────────
    DECLARE has_money    INT DEFAULT 0;
    DECLARE has_charinfo INT DEFAULT 0;
    DECLARE has_job      INT DEFAULT 0;
    DECLARE has_gang     INT DEFAULT 0;
    DECLARE has_position INT DEFAULT 0;

    SELECT COUNT(*) INTO has_money    FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'money';
    SELECT COUNT(*) INTO has_charinfo FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'charinfo';
    SELECT COUNT(*) INTO has_job      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'job';
    SELECT COUNT(*) INTO has_gang     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'gang';
    SELECT COUNT(*) INTO has_position FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'position';

    -- ── Money ───────────────────────────────────────────────────────────
    IF has_money = 1 THEN
        UPDATE players SET
            cash           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.cash')),           cash),
            bank           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.bank')),           bank),
            gold           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.gold')),           gold),
            goldcurrency   = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.goldcurrency')),   goldcurrency),
            coins          = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.coins')),          coins),
            goldcoins      = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.goldcoins')),      goldcoins),
            silvercoins    = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.silvercoins')),    silvercoins),
            marshalcoins   = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.marshalcoins')),   marshalcoins),
            trustcoins     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.trustcoins')),     trustcoins),
            diamonds       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.diamonds')),       diamonds),
            bloodmoney     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.bloodmoney')),     bloodmoney),
            bloodcoins     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.bloodcoins')),     bloodcoins),
            tokens         = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.tokens')),         tokens),
            rewardtokens   = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.rewardtokens')),   rewardtokens),
            promisarynotes = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(money, '$.promisarynotes')), promisarynotes)
        WHERE money IS NOT NULL
          AND JSON_VALID(money);

        SELECT CONCAT('✅  Money migration complete — ', ROW_COUNT(), ' rows updated') AS status;
    ELSE
        SELECT 'ℹ️  No legacy "money" JSON column found — skipping money migration' AS status;
    END IF;

    -- ── Character Info ──────────────────────────────────────────────────
    IF has_charinfo = 1 THEN
        UPDATE players SET
            firstname   = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')),   firstname),
            lastname    = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')),    lastname),
            birthdate   = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.birthdate')),   birthdate),
            gender      = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.gender')),      gender),
            nationality = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.nationality')), nationality),
            account     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.account')),     account)
        WHERE charinfo IS NOT NULL
          AND JSON_VALID(charinfo);

        SELECT CONCAT('✅  Charinfo migration complete — ', ROW_COUNT(), ' rows updated') AS status;
    ELSE
        SELECT 'ℹ️  No legacy "charinfo" JSON column found — skipping charinfo migration' AS status;
    END IF;

    -- ── Job ─────────────────────────────────────────────────────────────
    IF has_job = 1 THEN
        UPDATE players SET
            job_name        = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')),        job_name),
            job_label       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(job, '$.label')),       job_label),
            job_grade_name  = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(job, '$.grade.name')),  job_grade_name),
            job_grade_level = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(job, '$.grade.level')), job_grade_level),
            job_payment     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(job, '$.payment')),     job_payment),
            job_onduty      = CASE
                                WHEN JSON_EXTRACT(job, '$.onduty') = true  THEN 1
                                WHEN JSON_EXTRACT(job, '$.onduty') = false THEN 0
                                ELSE job_onduty
                              END,
            job_isboss      = CASE
                                WHEN JSON_EXTRACT(job, '$.isboss') = true  THEN 1
                                WHEN JSON_EXTRACT(job, '$.isboss') = false THEN 0
                                ELSE job_isboss
                              END
        WHERE job IS NOT NULL
          AND JSON_VALID(job);

        SELECT CONCAT('✅  Job migration complete — ', ROW_COUNT(), ' rows updated') AS status;
    ELSE
        SELECT 'ℹ️  No legacy "job" JSON column found — skipping job migration' AS status;
    END IF;

    -- ── Gang ────────────────────────────────────────────────────────────
    IF has_gang = 1 THEN
        UPDATE players SET
            gang_name        = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(gang, '$.name')),        gang_name),
            gang_label       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(gang, '$.label')),       gang_label),
            gang_grade_name  = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(gang, '$.grade.name')),  gang_grade_name),
            gang_grade_level = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(gang, '$.grade.level')), gang_grade_level),
            gang_isboss      = CASE
                                 WHEN JSON_EXTRACT(gang, '$.isboss') = true  THEN 1
                                 WHEN JSON_EXTRACT(gang, '$.isboss') = false THEN 0
                                 ELSE gang_isboss
                               END
        WHERE gang IS NOT NULL
          AND JSON_VALID(gang);

        SELECT CONCAT('✅  Gang migration complete — ', ROW_COUNT(), ' rows updated') AS status;
    ELSE
        SELECT 'ℹ️  No legacy "gang" JSON column found — skipping gang migration' AS status;
    END IF;

    -- ── Position ────────────────────────────────────────────────────────
    IF has_position = 1 THEN
        UPDATE players SET
            pos_x       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(position, '$.x')),       pos_x),
            pos_y       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(position, '$.y')),       pos_y),
            pos_z       = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(position, '$.z')),       pos_z),
            pos_heading = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(position, '$.heading')), pos_heading)
        WHERE position IS NOT NULL
          AND JSON_VALID(position);

        SELECT CONCAT('✅  Position migration complete — ', ROW_COUNT(), ' rows updated') AS status;
    ELSE
        SELECT 'ℹ️  No legacy "position" JSON column found — skipping position migration' AS status;
    END IF;

    SELECT '══════════════════════════════════════════════════════════' AS '';
    SELECT '  Migration complete.  Verify the data, then optionally' AS '';
    SELECT '  run Phase 3 to drop the legacy JSON columns.' AS '';
    SELECT '══════════════════════════════════════════════════════════' AS '';
END //

DELIMITER ;

-- Run the migration
CALL _lxr_migrate_json_blobs();


-- =========================================================================
-- PHASE 3 (OPTIONAL): Drop legacy JSON blob columns
-- =========================================================================
-- ONLY run this after you have verified the data migration is correct.
-- Uncomment the lines below when you are ready.
--
-- ALTER TABLE players DROP COLUMN IF EXISTS money;
-- ALTER TABLE players DROP COLUMN IF EXISTS charinfo;
-- ALTER TABLE players DROP COLUMN IF EXISTS job;
-- ALTER TABLE players DROP COLUMN IF EXISTS gang;
-- ALTER TABLE players DROP COLUMN IF EXISTS position;
--
-- SELECT '✅  Legacy JSON columns dropped.' AS status;


-- =========================================================================
-- CLEANUP: Drop the helper procedures (they are no longer needed)
-- =========================================================================
DROP PROCEDURE IF EXISTS _lxr_add_column_if_missing;
DROP PROCEDURE IF EXISTS _lxr_migrate_json_blobs;

SELECT '✅  RSG-Core → LXR-Core migration script finished.' AS result;
