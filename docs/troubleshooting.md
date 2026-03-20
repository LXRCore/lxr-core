# Troubleshooting

Common issues and solutions when running LXRCore.

---

## Installation Issues

### Resource name mismatch

**Error:**
```
❌ CRITICAL ERROR: RESOURCE NAME MISMATCH
Expected: lxr-core
Got: lxr-core-main
```

**Solution:** Rename the resource folder to exactly `lxr-core`:
```bash
mv lxr-core-main lxr-core
```

---

### oxmysql not found

**Error:** `oxmysql` dependency missing or not started.

**Solution:**
1. Download [oxmysql](https://github.com/overextended/oxmysql/releases) and place it in your resources folder
2. Ensure it starts before lxr-core in `server.cfg`:
```cfg
ensure oxmysql
ensure lxr-core
```

---

### Database connection failed

**Error:** Could not connect to MySQL/MariaDB.

**Solution:**
1. Verify your connection string in `server.cfg`:
```cfg
set mysql_connection_string "mysql://username:password@localhost/database_name?charset=utf8mb4"
```
2. Verify the database exists: `SHOW DATABASES;`
3. Verify the user has permissions: `SHOW GRANTS FOR 'username'@'localhost';`
4. Test connection manually: `mysql -u username -p database_name`

---

### Tables not found

**Error:** `Table 'lxrcore.players' doesn't exist`

**Solution:** From your server's resources directory, import the SQL schema files:
```bash
cd /path/to/server/resources/lxr-core
mysql -u username -p database_name < database/lxrcore.sql
mysql -u username -p database_name < database/lxrcore_tables.sql
```

---

## Runtime Issues

### Framework not loading

**Symptoms:** No boot banner, exports return nil.

**Check:**
1. Correct resource load order in `server.cfg`
2. No syntax errors in config.lua
3. Check server console for Lua errors

---

### Player data not saving

**Symptoms:** Player progress resets on reconnect.

**Check:**
1. Database connection is active
2. `players` table exists and is writable
3. Check logs for SQL errors
4. Verify `LXRConfig.UpdateInterval` is set (default: 5 minutes)

---

### Performance issues

**Symptoms:** Server lag, high tick time.

**Solutions:**
1. Enable database caching in `config.lua`:
```lua
LXRConfig.Performance.caching.enabled = true
```
2. Check for resource conflicts with `/resmon`
3. Review database query performance
4. Ensure SSD storage for the database

---

### Events not triggering

**Symptoms:** Custom resources not receiving LXRCore events.

**Check:**
1. Event names match exactly (case-sensitive)
2. `RegisterNetEvent` is called before `AddEventHandler`
3. Resource dependencies include `lxr-core`
4. Resource starts after `lxr-core` in server.cfg

---

## Getting Help

When reporting issues, please include:

1. Server console output (full startup log)
2. Client F8 console errors
3. Your `server.cfg` (remove sensitive information)
4. Relevant `config.lua` settings
5. Steps to reproduce the issue

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
