# Framework Compatibility Matrix

Verified compatibility status of LXRCore systems with other RedM frameworks.

---

## Supported Frameworks

LXRCore currently targets compatibility with two primary external frameworks:

- **RSG-Core** — Primary compatibility target (closest API match)
- **VORP Core** — Secondary compatibility target (different API patterns)

---

## Compatibility Status

### Core Systems

| System | LXR-Core | RSG-Core Bridge | VORP Bridge | Notes |
|--------|----------|-----------------|-------------|-------|
| Player Loading | ✅ Native | ✅ Compatible | ⚠️ Partial | VORP uses different player object structure |
| Character Creation | ✅ Native | ✅ Compatible | ⚠️ Partial | VORP has different character model |
| Money (Cash) | ✅ Native | ✅ Compatible | ✅ Compatible | VORP uses numeric currency IDs |
| Money (Gold) | ✅ Native | ✅ Compatible | ✅ Compatible | Mapped from VORP currency ID 1 |
| Money (Bank) | ✅ Native | ✅ Compatible | ❌ Not Available | VORP lacks bank currency by default |
| Inventory | ✅ Native | ✅ Compatible | ⚠️ Partial | VORP uses separate vorp_inventory |
| Jobs | ✅ Native | ✅ Compatible | ⚠️ Partial | Different job data structure |
| Gangs | ✅ Native | ⚠️ Partial | ❌ Not Available | RSG gang support varies |
| Notifications | ✅ Native | ✅ Compatible | ⚠️ Partial | Different notification styles |
| Callbacks | ✅ Native | ✅ Compatible | ❌ Not Available | VORP uses different callback pattern |
| Commands | ✅ Native | ✅ Compatible | ⚠️ Partial | Basic commands work |

### Security Systems

| System | LXR-Core | RSG-Core Bridge | VORP Bridge |
|--------|----------|-----------------|-------------|
| Rate Limiting | ✅ Active | ✅ Active | ✅ Active |
| Anti-Cheat | ✅ Active | ✅ Active | ✅ Active |
| Anti-Dupe | ✅ Active | ⚠️ Partial | ❌ N/A |
| Audit Logging | ✅ Active | ✅ Active | ✅ Active |
| Input Validation | ✅ Active | ✅ Active | ✅ Active |

### Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully working and tested |
| ⚠️ | Partially working, some features may not be available |
| ❌ | Not available or not compatible |

---

## Testing Methodology

Compatibility is verified by:

1. Starting a server with the bridge framework configured
2. Testing each API function through the framework adapter
3. Verifying data persistence and consistency
4. Checking for errors in server console

---

## Known Limitations

### RSG-Core Bridge
- Gang systems may differ depending on RSG-Core version
- Some advanced RSG exports may not have LXR equivalents
- RSG-specific UI components are not bridged

### VORP Bridge
- VORP's separate inventory system (vorp_inventory) is not directly bridged
- Currency mapping is limited to cash and gold
- VORP callback patterns require manual adaptation
- Character data structure differences may cause issues with complex resources

---

## Reporting Compatibility Issues

If you find a compatibility issue:

1. Check the [migration guides](migration/) for known differences
2. Open a [GitHub Issue](https://github.com/LXRCore/lxr-core/issues) with:
   - Framework and version you're bridging with
   - The specific API call that fails
   - Error messages from server console
   - Expected vs. actual behavior
