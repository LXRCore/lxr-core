# Getting Started with LXRCore

Get a basic LXRCore server running in under 15 minutes.

---

## Prerequisites

- [RedM Server](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) (latest build)
- MySQL or MariaDB (8.0+ / 10.5+)
- [oxmysql](https://github.com/overextended/oxmysql/releases) resource

---

## Quick Start

### 1. Clone the repository

```bash
cd /path/to/your/server/resources
git clone https://github.com/LXRCore/lxr-core.git
```

### 2. Import the database

```bash
mysql -u username -p database_name < lxr-core/database/lxrcore.sql
mysql -u username -p database_name < lxr-core/database/lxrcore_tables.sql
```

### 3. Configure your database connection

Add to `server.cfg`:

```cfg
set mysql_connection_string "mysql://username:password@localhost/database_name?charset=utf8mb4"
```

### 4. Configure settings

Edit `lxr-core/config.lua`:
- Set your server name
- Set your Discord invite link
- Adjust spawn locations and economy settings

### 5. Ensure resources and start

Add to `server.cfg`:

```cfg
ensure oxmysql
ensure lxr-core
```

Start your server:

```bash
./run.sh    # Linux
run.cmd     # Windows
```

---

## Verify Installation

After starting the server, check the console for:

```
🐺 LXR CORE FRAMEWORK - SUCCESSFULLY LOADED
```

Connect to the server with RedM and verify:
- Character creation loads
- You can spawn into the world
- `/help` command works

---

## Next Steps

- [Full Installation Guide](installation.md) — Detailed setup with troubleshooting
- [Configuration Guide](DOCUMENTATION.md) — Customize your server settings
- [API Reference](API.md) — Start building resources with LXRCore
- [Framework Compatibility](frameworks.md) — Multi-framework support

---

## Need Help?

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
