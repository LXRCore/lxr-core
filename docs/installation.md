# 🐺 LXR Core - Installation Guide

```
██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**🐺 The Land of Wolves - Georgian RP**  
**Complete Installation Instructions**

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📋 TABLE OF CONTENTS
## ═══════════════════════════════════════════════════════════════════════════════

1. [Prerequisites](#prerequisites)
2. [Fresh Installation](#fresh-installation)
3. [Database Setup](#database-setup)
4. [Configuration](#configuration)
5. [Starting the Server](#starting-the-server)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🔧 PREREQUISITES
## ═══════════════════════════════════════════════════════════════════════════════

Before installing LXR Core, ensure you have:

### Required Software

- **RedM Server** (Latest Build)
  - Download: https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/
  - RedM build 1355.0 or higher recommended

- **MySQL/MariaDB Database**
  - MySQL 8.0+ or MariaDB 10.5+
  - Recommended: MariaDB 10.6.x for best performance

- **oxmysql Resource**
  - Download: https://github.com/overextended/oxmysql/releases
  - Required for database operations

### System Requirements

**Minimum:**
- CPU: 4 cores @ 3.0 GHz
- RAM: 8 GB
- Storage: 10 GB free space
- Network: 100 Mbps upload

**Recommended:**
- CPU: 8+ cores @ 3.5+ GHz
- RAM: 16 GB+
- Storage: 20 GB+ SSD
- Network: 1 Gbps upload

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📦 FRESH INSTALLATION
## ═══════════════════════════════════════════════════════════════════════════════

### Step 1: Download LXR Core

**Option A: Git Clone (Recommended)**
```bash
cd /path/to/your/server/resources
git clone https://github.com/LXRCore/lxr-core.git
```

**Option B: Manual Download**
1. Visit https://github.com/LXRCore/lxr-core
2. Click "Code" → "Download ZIP"
3. Extract to your resources folder
4. **IMPORTANT:** Rename folder to `lxr-core` (lowercase, hyphen)

### Step 2: Verify Folder Name

**⚠️ CRITICAL: The folder MUST be named `lxr-core`**

The framework has runtime name protection. If the folder name doesn't match, you'll see:

```
❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
Expected: lxr-core
Got: lxr-core-main (or other name)

Rename the folder to "lxr-core" to continue.
```

### Step 3: Install oxmysql

```bash
cd /path/to/your/server/resources
git clone https://github.com/overextended/oxmysql.git
```

Or download the latest release from GitHub.

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🗄️ DATABASE SETUP
## ═══════════════════════════════════════════════════════════════════════════════

### Step 1: Create Database

Create a new MySQL/MariaDB database:

```sql
CREATE DATABASE IF NOT EXISTS `lxrcore` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

### Step 2: Import SQL Files

Import the SQL files in this order:

1. **Main Schema**
   ```bash
   mysql -u username -p lxrcore < database/lxrcore.sql
   ```

2. **Tables Schema**
   ```bash
   mysql -u username -p lxrcore < database/lxrcore_tables.sql
   ```

3. **Tebex Integration (Optional)**
   ```bash
   mysql -u username -p lxrcore < database/tebex_tables.sql
   ```

### Step 3: Configure oxmysql

Edit your `server.cfg`:

```cfg
# MySQL Connection String
set mysql_connection_string "mysql://username:password@localhost/lxrcore?charset=utf8mb4"

# Alternative: Individual parameters
set mysql_connection_string "user=username;password=yourpassword;host=localhost;database=lxrcore"
```

**Security Note:** Use a dedicated database user with limited permissions, not root!

### Step 4: Grant Permissions

```sql
CREATE USER 'lxrcore_user'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON lxrcore.* TO 'lxrcore_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## ⚙️ CONFIGURATION
## ═══════════════════════════════════════════════════════════════════════════════

### Step 1: Edit config.lua

Open `lxr-core/config.lua` and configure:

#### Server Information

```lua
LXRConfig.ServerInfo = {
    name = 'Your Server Name',
    tagline = 'Your Server Tagline',
    description = 'Your Server Description',
    -- ... update website, discord, etc.
}
```

#### Basic Settings

```lua
-- Maximum players
LXRConfig.MaxPlayers = 48  -- Match your sv_maxclients

-- Default spawn location
LXRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)

-- Discord invite
LXRConfig.Discord = "https://discord.gg/yourserver"

-- Language
LXRConfig.Lang = 'en'  -- Available: en, es, fr, de, ru, pt, it, etc.
```

#### Economy

```lua
-- Starting money (already configured)
LXRConfig.Money.MoneyTypes.cash.startAmount = 2
LXRConfig.Money.MoneyTypes.bank.startAmount = 5
```

#### Spawn Locations

```lua
LXRConfig.Player.SpawnLocations = {
    {label = 'Valentine', coords = vector4(-275.46, 805.17, 119.38, 0.0)},
    {label = 'Blackwater', coords = vector4(-813.97, -1324.19, 43.88, 0.0)},
    -- Add your custom locations...
}
```

### Step 2: Configure server.cfg

Add to your `server.cfg`:

```cfg
# Server Name
sv_hostname "Your Server Name ^2[LXR Core]"

# Max Players
sv_maxclients 48

# Server Description
sets sv_projectName "RedM RP Server"
sets sv_projectDesc "Powered by LXR Core Framework"

# Tags (for server listing)
sets tags "roleplay, redm, lxrcore, whitelist, serious"

# Locale
sets locale "en-US"

# License Key (from Cfx.re)
sv_licenseKey "your_cfx_license_key_here"

# Resources
ensure oxmysql
ensure lxr-core

# Optional: Other resources
# ensure lxr-inventory
# ensure lxr-multicharacter
# ensure lxr-admin
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🚀 STARTING THE SERVER
## ═══════════════════════════════════════════════════════════════════════════════

### Step 1: Start Order

Resources must start in this order:
1. `oxmysql` (database)
2. `lxr-core` (framework)
3. Other LXR resources
4. Third-party resources

### Step 2: First Start

```bash
./run.sh   # Linux
# or
run.cmd    # Windows
```

### Step 3: Watch Console Output

You should see:

```
═══════════════════════════════════════════════════════════════════════════════

    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
    
    ███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
    ██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
    █████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
    ██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
    ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

═══════════════════════════════════════════════════════════════════════════════
🐺 LXR CORE FRAMEWORK - SUCCESSFULLY LOADED
═══════════════════════════════════════════════════════════════════════════════

Version:          2.0.0
Server:           Your Server Name

Framework:        LXR-Core (Primary)
Language:         en
Max Players:      48

Currency Types:   15 configured
Skills System:    6 skills available
Progression:      ENABLED ✓

PVP:              ENABLED ✓
Security:         ACTIVE ✓
Performance:      OPTIMIZED ✓
Debug Mode:       DISABLED
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## ✅ VERIFICATION
## ═══════════════════════════════════════════════════════════════════════════════

### Check Console

1. **No Red Errors** - Framework loaded without errors
2. **Boot Banner Displayed** - ASCII art banner shows
3. **Framework Detected** - Shows "LXR-Core (Primary)"
4. **Database Connected** - oxmysql shows connection success

### Test In-Game

1. **Connect to Server**
   - Open RedM
   - Connect to your server
   - Watch for loading screens

2. **Create Character**
   - Character creation should load
   - Can set firstname, lastname, etc.

3. **Spawn In-World**
   - Should spawn at configured location
   - HUD elements visible
   - Can move and interact

4. **Test Commands**
   ```
   /help          - Show available commands
   /adminmenu     - Open admin menu (if admin)
   /inventory     - Open inventory
   ```

### Check Database

```sql
-- Check if player was created
SELECT * FROM players ORDER BY id DESC LIMIT 1;

-- Check if tables exist
SHOW TABLES;
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🔧 TROUBLESHOOTING
## ═══════════════════════════════════════════════════════════════════════════════

### Error: "RESOURCE NAME MISMATCH"

**Problem:** Folder is not named `lxr-core`

**Solution:**
```bash
cd resources
mv lxr-core-main lxr-core
# or whatever the current name is
```

### Error: "oxmysql not found"

**Problem:** oxmysql not installed or not started

**Solution:**
1. Install oxmysql: `git clone https://github.com/overextended/oxmysql.git`
2. Add to server.cfg: `ensure oxmysql`
3. Ensure it's before lxr-core

### Error: "Could not connect to database"

**Problem:** Database connection string incorrect

**Solution:**
1. Check `server.cfg` mysql_connection_string
2. Verify database exists: `SHOW DATABASES;`
3. Verify user has permissions
4. Test connection: `mysql -u username -p database_name`

### Error: "Table 'lxrcore.players' doesn't exist"

**Problem:** Database tables not imported

**Solution:**
```bash
mysql -u username -p lxrcore < database/lxrcore.sql
mysql -u username -p lxrcore < database/lxrcore_tables.sql
```

### Error: "Framework not loading"

**Problem:** Dependencies not started

**Solution:**
Check server.cfg load order:
```cfg
ensure oxmysql          # 1. Database first
ensure lxr-core         # 2. Framework second
ensure other-resources  # 3. Everything else
```

### Performance Issues

**Problem:** Server lagging or slow

**Solutions:**
1. Check `config.lua` performance settings
2. Enable database caching: `LXRConfig.Performance.caching.enabled = true`
3. Reduce player count if needed
4. Check MySQL/MariaDB is optimized
5. Use SSD storage for database

### Character Not Saving

**Problem:** Player data not persisting

**Solutions:**
1. Check database connection
2. Verify player table exists
3. Check logs for SQL errors
4. Increase save interval: `LXRConfig.UpdateInterval = 5`

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📞 SUPPORT
## ═══════════════════════════════════════════════════════════════════════════════

### Need Help?

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
- **Documentation:** https://www.wolves.land/docs
- **Website:** https://www.wolves.land

### Before Asking for Help

Please provide:
1. Server console output (full log)
2. Client F8 console errors
3. Your server.cfg (remove sensitive info)
4. Your config.lua settings
5. Steps to reproduce the issue

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🎯 NEXT STEPS
## ═══════════════════════════════════════════════════════════════════════════════

After successful installation:

1. **Read Configuration Guide** - Customize your server
2. **Install Additional Resources** - Add jobs, scripts, maps
3. **Configure Permissions** - Set up admin/mod roles
4. **Test Gameplay** - Create test accounts and verify systems
5. **Setup Whitelist** - Configure application process
6. **Configure Discord Bot** - Link your Discord server
7. **Add Custom Content** - Jobs, vehicles, items, etc.

---

**🐺 wolves.land - The Land of Wolves**  
*ისტორია ცოცხლდება აქ! (History Lives Here!)*

© 2026 iBoss21 / The Lux Empire | All Rights Reserved
