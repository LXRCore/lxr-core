# 🐺 LXR Core - Screenshots & Media

```
██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**Visual Documentation & Requirements**

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📸 REQUIRED SCREENSHOTS
## ═══════════════════════════════════════════════════════════════════════════════

All screenshots must be placed in: `/docs/assets/screenshots/`

### Mandatory Screenshots

| # | Filename | Description | Requirements |
|---|----------|-------------|--------------|
| 1 | `01_startup_console.png` | Server console showing LXR Core boot banner | Full ASCII art visible, framework detected |
| 2 | `02_config_sections.png` | config.lua file showing bannered sections | Multiple █████ banners visible |
| 3 | `03_ui_interaction.png` | In-game UI/HUD elements | HUD, inventory, or menu visible |
| 4 | `04_framework_detection.png` | Console showing framework adapter output | Framework detection banner |
| 5 | `05_discord_logs.png` | Discord webhook logs (if configured) | Audit log examples |
| 6 | `06_txadmin_performance.png` | txAdmin resource monitor | CPU, Memory, Net usage shown |

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📋 SCREENSHOT GUIDELINES
## ═══════════════════════════════════════════════════════════════════════════════

### Resolution Requirements

- **Minimum:** 1920x1080 (Full HD)
- **Recommended:** 2560x1440 (2K)
- **Format:** PNG (for crisp text) or JPG (for in-game photos)

### Content Requirements

1. **No sensitive information** - Hide server IPs, passwords, API keys
2. **Clear visibility** - Text must be readable
3. **Production quality** - No debug overlays unless relevant
4. **Branded** - Show wolves.land/LXR Core branding where applicable

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📷 SCREENSHOT SPECIFICATIONS
## ═══════════════════════════════════════════════════════════════════════════════

### 1. Startup Console (`01_startup_console.png`)

**What to capture:**
- Full server console window
- LXR Core ASCII art banner
- Version, framework detection
- Currency count, skills, settings
- Developer credit line

**Example content:**
```
═══════════════════════════════════════════════════════════════════════════════

    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    [... full ASCII art ...]

═══════════════════════════════════════════════════════════════════════════════
🐺 LXR CORE FRAMEWORK - SUCCESSFULLY LOADED
═══════════════════════════════════════════════════════════════════════════════

Version:          2.0.0
Server:           The Land of Wolves 🐺
Framework:        LXR-Core (Primary)
[... rest of boot info ...]
```

### 2. Config Sections (`02_config_sections.png`)

**What to capture:**
- config.lua file open in editor
- Show multiple bannered sections (████████)
- Server branding section
- Framework configuration section
- Any other major section

**Highlight:**
- Clean, organized structure
- Heavy branding banners
- wolves.land information

### 3. UI Interaction (`03_ui_interaction.png`)

**What to capture:**
- In-game screenshot
- Character HUD (health, stamina, money)
- Inventory menu (if open)
- Notification examples
- Interaction prompts

**Quality:**
- High graphics settings
- Clear UI elements
- Good lighting/time of day

### 4. Framework Detection (`04_framework_detection.png`)

**What to capture:**
- Console showing framework adapter output
- Framework detection banner
- List of detected frameworks (✓ or ✗)
- Active framework indication

**Example:**
```
═══════════════════════════════════════════════════════════════════════════════
🐺 LXR FRAMEWORK ADAPTER - SERVER-SIDE LOADED
═══════════════════════════════════════════════════════════════════════════════

Active Framework:     lxr-core

Detected Frameworks:
- LXR-Core:           ✓ DETECTED
- RSG-Core:           ✗ Not Found
- VORP Core:          ✗ Not Found
[... etc ...]
```

### 5. Discord Logs (`05_discord_logs.png`)

**What to capture:** (if Discord webhooks configured)
- Discord channel with log embeds
- Examples of transaction logs
- Admin action logs
- Security alerts

**Content:**
- At least 3-5 log entries
- Different log types
- Timestamps visible
- Server branding in embeds

### 6. txAdmin Performance (`06_txadmin_performance.png`)

**What to capture:**
- txAdmin web interface
- Resource monitor page
- lxr-core resource stats:
  - CPU usage (should be low)
  - Memory usage
  - Network usage
  - Active threads

**Demonstration:**
- Low CPU usage (< 2% per tick)
- Stable memory (< 150 MB)
- High performance

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🎬 VIDEO REQUIREMENTS (OPTIONAL)
## ═══════════════════════════════════════════════════════════════════════════════

Optional video demonstrations:

### Setup Walkthrough
- **Duration:** 5-10 minutes
- **Content:** Installation, configuration, first start
- **Platform:** YouTube/Streamable

### Feature Showcase
- **Duration:** 10-15 minutes
- **Content:** Gameplay, systems demonstration
- **Platform:** YouTube/Streamable

### Performance Test
- **Duration:** 3-5 minutes
- **Content:** txAdmin stats during gameplay
- **Platform:** YouTube/Streamable

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📁 FILE STRUCTURE
## ═══════════════════════════════════════════════════════════════════════════════

```
docs/
└── assets/
    └── screenshots/
        ├── 01_startup_console.png
        ├── 02_config_sections.png
        ├── 03_ui_interaction.png
        ├── 04_framework_detection.png
        ├── 05_discord_logs.png
        ├── 06_txadmin_performance.png
        ├── extras/                         # Optional additional screenshots
        │   ├── character_creation.png
        │   ├── inventory_system.png
        │   ├── job_menu.png
        │   └── admin_panel.png
        └── videos/                         # Optional video files
            ├── setup_walkthrough.mp4
            └── feature_showcase.mp4
```

---

## ═══════════════════════════════════════════════════════════════════════════════
## ✅ SCREENSHOT CHECKLIST
## ═══════════════════════════════════════════════════════════════════════════════

Before submitting screenshots, verify:

- [ ] All 6 required screenshots present
- [ ] Files named correctly (01_ through 06_)
- [ ] Resolution at least 1920x1080
- [ ] Text is readable and clear
- [ ] No sensitive information visible
- [ ] Branding/ASCII art properly displayed
- [ ] Files in `/docs/assets/screenshots/` directory
- [ ] PNG format for console/code screenshots
- [ ] JPG/PNG for in-game screenshots

---

## ═══════════════════════════════════════════════════════════════════════════════
## 📤 SUBMISSION
## ═══════════════════════════════════════════════════════════════════════════════

### For Repository

1. Place screenshots in `/docs/assets/screenshots/`
2. Commit to your branch
3. Include in pull request
4. Reference in README.md

### For Support/Issues

When reporting issues, include:
- Console screenshot showing error
- F8 console (client-side errors)
- txAdmin resource stats
- Relevant config sections

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🎨 BRANDING GUIDELINES
## ═══════════════════════════════════════════════════════════════════════════════

When creating promotional screenshots or videos:

### Required Elements

- **🐺 wolves.land** branding visible
- **LXR Core** name/logo
- **Server information** if relevant
- **Developer credit:** iBoss21 / The Lux Empire

### Color Scheme

- **Primary:** Dark theme (black/dark gray backgrounds)
- **Accent:** Wolf emoji 🐺 and Georgian flag 🇬🇪
- **Text:** High contrast for readability

### Watermarks (Optional)

Add watermark with:
- wolves.land logo
- Server name
- Discord link
- Position: Bottom right corner, 10-20% opacity

---

## ═══════════════════════════════════════════════════════════════════════════════
## 🆘 NEED HELP?
## ═══════════════════════════════════════════════════════════════════════════════

For screenshot examples and templates:

- **Discord:** https://discord.gg/CrKcWdfd3A
- **Website:** https://www.wolves.land
- **GitHub:** https://github.com/iBoss21

---

**🐺 wolves.land - The Land of Wolves**  
*ისტორია ცოცხლდება აქ! (History Lives Here!)*

© 2026 iBoss21 / The Lux Empire | All Rights Reserved
