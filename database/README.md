# LXRCore Database Schema

<div align="center">

**🗄️ SQL Database Schema Files 🗄️**

[![Database](https://img.shields.io/badge/Database-MySQL-orange?style=for-the-badge&logo=mysql)](https://www.mysql.com/)
[![Schema](https://img.shields.io/badge/Schema-Complete-green?style=for-the-badge)](README.md)

[🏠 Back to Main](../README.md) • [📚 Documentation](../docs/)

</div>

---

## 📊 Database Files

This directory contains all SQL schema files required for LXRCore Framework.

### Schema Files

#### 1. **lxrcore.sql**
Main database initialization file. This is the primary schema file you should import first.

```bash
mysql -u username -p database_name < lxrcore.sql
```

**Contains:**
- Core framework tables
- Player data structure
- Job and gang systems
- Vehicle and horse management
- Basic configuration

#### 2. **lxrcore_tables.sql**
Detailed table structure definitions with complete column specifications.

```bash
mysql -u username -p database_name < lxrcore_tables.sql
```

**Contains:**
- Extended player information
- Inventory system tables
- Transaction logging
- Performance monitoring tables
- Audit logs

#### 3. **tebex_tables.sql**
Tebex integration schema for premium currency and tokens.

```bash
mysql -u username -p database_name < tebex_tables.sql
```

**Contains:**
- Gold currency tracking
- Premium token management
- Purchase history
- Webhook data storage

#### 4. **migrate_rsg_to_lxr.sql**
Migration script for servers upgrading from RSG-Core to LXR-Core.

```bash
mysql -u username -p database_name < migrate_rsg_to_lxr.sql
```

**Contains:**
- Schema migration (adds normalized columns to existing RSG-Core players table)
- Data migration (extracts JSON blob data into normalized columns)
- Idempotent — safe to re-run without data loss

---

## 📋 Installation Order

For a **fresh installation**, import the files in this order:

1. **lxrcore.sql** (Required) - Base schema
2. **lxrcore_tables.sql** (Required) - Extended tables
3. **tebex_tables.sql** (Optional) - Only if using Tebex integration

For **migration from RSG-Core**, run these instead:

1. **migrate_rsg_to_lxr.sql** (Required) - Adds normalized columns and migrates data
2. **lxrcore_tables.sql** (Required) - Extended tables (logging, monitoring, etc.)
3. **tebex_tables.sql** (Optional) - Only if using Tebex integration

### Quick Installation

```bash
# Navigate to database directory
cd database/

# Import all files (with Tebex)
mysql -u username -p database_name < lxrcore.sql
mysql -u username -p database_name < lxrcore_tables.sql
mysql -u username -p database_name < tebex_tables.sql

# Or use one command (without Tebex)
cat lxrcore.sql lxrcore_tables.sql | mysql -u username -p database_name
```

---

## 🔧 Requirements

- **MySQL** 5.7+ or **MariaDB** 10.2+
- **oxmysql** resource installed
- Database user with CREATE, INSERT, UPDATE, DELETE privileges

---

## 📝 Configuration

After importing the schema, configure your connection in `server.cfg`:

```lua
set mysql_connection_string "mysql://username:password@localhost/database_name?charset=utf8mb4"
```

---

## 🔄 Updates & Migrations

When updating LXRCore, check for migration scripts that may be required. Always backup your database before applying updates:

```bash
# Backup your database
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql
```

### Migrating from RSG-Core

If you are migrating from RSG-Core (which stores money, charinfo, job, gang, and position as JSON TEXT blobs), run the migration script **before** starting lxr-core:

```bash
mysql -u username -p database_name < database/migrate_rsg_to_lxr.sql
```

This script:
- Adds normalized columns (`cash`, `bank`, `firstname`, `job_name`, `pos_x`, etc.) if they don't already exist
- Extracts data from the legacy JSON blob columns using `JSON_EXTRACT`
- Is idempotent and safe to re-run

See the full migration guide: [RSG-Core → LXR-Core Migration](../docs/migration/rsg-to-lxr.md)

---

## 📚 Related Documentation

- [Main Documentation](../docs/DOCUMENTATION.md)
- [API Reference](../docs/API.md)
- [Tebex Integration Guide](../docs/TEBEX.md)

---

## ⚠️ Important Notes

- **Always backup** your database before making changes
- **Test updates** on a development server first
- **Character set** should be utf8mb4 for proper emoji support
- **Collation** recommended: utf8mb4_unicode_ci

---

<div align="center">

**Made by iBoss • LXRCore - www.lxrcore.com**

**🐺 Launched on [The Land of Wolves RP](https://www.wolves.land) 🐺**

</div>
