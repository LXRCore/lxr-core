# Framework Architecture

Technical overview of how LXRCore is structured internally.

---

## Layer Architecture

```
┌─────────────────────────────────────────────────────┐
│              CLIENT LAYER (8 Files)                  │
│  performance.lua  anticheat.lua  functions.lua       │
│  loops.lua  events.lua  drawtxt.lua  prompts.lua     │
│  notify.js                                           │
└─────────────────────┬───────────────────────────────┘
                      │  Net Events / Exports
                      ▼
┌─────────────────────────────────────────────────────┐
│        FRAMEWORK ADAPTER (shared/framework.lua)      │
│  Auto-detects active framework at startup            │
│  Provides unified API across LXR/RSG/VORP/etc.       │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│              SERVER LAYER (16 Files)                 │
│  player.lua  functions.lua  events.lua  commands.lua │
│  database.lua  security.lua  anticheat.lua           │
│  antidupe.lua  bridge.lua  protection.lua            │
│  logs.lua  performance.lua  exports.lua              │
│  debug.lua  developertools.lua  tebex.lua            │
└─────────────────────┬───────────────────────────────┘
                      │  oxmysql
                      ▼
┌─────────────────────────────────────────────────────┐
│              DATABASE LAYER (MySQL/MariaDB)           │
│  players  items  vehicles  jobs  gangs  logs          │
└─────────────────────────────────────────────────────┘
```

---

## Directory Layout

```
lxr-core/
├── client/              # Client-side scripts
│   ├── anticheat.lua    # Client anti-cheat detection
│   ├── drawtxt.lua      # Text drawing utilities
│   ├── events.lua       # Client event handlers
│   ├── functions.lua    # Client utility functions
│   ├── loops.lua        # FPS-aware client loops
│   ├── notify.js        # Notification UI (NUI)
│   ├── performance.lua  # Client performance monitoring
│   └── prompts.lua      # Interaction prompt system
├── server/              # Server-side scripts
│   ├── anticheat.lua    # Server anti-cheat validation
│   ├── antidupe.lua     # Anti-duplication system
│   ├── bridge.lua       # Framework compatibility bridge
│   ├── commands.lua     # Admin & player commands
│   ├── database.lua     # Database operations & caching
│   ├── debug.lua        # Debug utilities
│   ├── developertools.lua # Development tools
│   ├── events.lua       # Server event handlers
│   ├── exports.lua      # Public API exports
│   ├── functions.lua    # Core server functions
│   ├── logs.lua         # Audit logging system
│   ├── performance.lua  # Server performance monitoring
│   ├── player.lua       # Player management (largest file)
│   ├── protection.lua   # Rate limiting & DDoS protection
│   ├── security.lua     # Input validation & security
│   └── tebex.lua        # Tebex monetization integration
├── shared/              # Shared between client & server
│   ├── framework.lua    # Multi-framework adapter
│   ├── gangs.lua        # Gang definitions
│   ├── horse.lua        # Horse data
│   ├── items.lua        # Item definitions
│   ├── jobs.lua         # Job definitions
│   ├── locale.lua       # Localization system
│   ├── main.lua         # Core shared functions
│   ├── vehicles.lua     # Vehicle data
│   └── weapons.lua      # Weapon definitions
├── database/            # SQL schemas
├── docs/                # Documentation
├── html/                # NUI interface
├── locale/              # 17 language files
├── config.lua           # Main configuration (1100+ lines)
└── fxmanifest.lua       # Resource manifest
```

---

## Core Components

### Player System (`server/player.lua`)

The largest module. Handles:
- Character creation and loading
- Player data persistence (periodic saves)
- Money management (15+ currency types)
- Job and gang assignment
- Inventory management
- Player state tracking

### Framework Adapter (`shared/framework.lua`)

Provides a unified API that works across multiple RedM frameworks:
- Auto-detects the active framework at startup
- Translates API calls to the detected framework's format
- Supports: LXR-Core, RSG-Core, VORP, RedEM:RP, QBR-Core, QR-Core
- Falls back to standalone mode if no framework detected

### Security Layer

Distributed across multiple files:
- `server/security.lua` — Input validation, data sanitization
- `server/protection.lua` — Rate limiting, DDoS mitigation
- `server/anticheat.lua` — Exploit detection (server-side)
- `client/anticheat.lua` — Exploit detection (client-side)
- `server/antidupe.lua` — Item/money duplication prevention

### Database Layer (`server/database.lua`)

- Uses oxmysql for all database operations
- Implements query caching with TTL
- Prepared statements for security
- Batch operations for performance

---

## Data Flow

### Player Connection

```
1. Player connects to server
2. server/events.lua handles playerConnecting
3. server/player.lua loads or creates player data
4. Data sent to client via LXRCore:Client:OnPlayerLoaded
5. client/events.lua handles player setup
6. Player spawns at configured location
```

### API Request (Export)

```
1. External resource calls exports['lxr-core']:GetPlayer(source)
2. server/exports.lua routes to server/functions.lua
3. Returns Player object with .PlayerData and .Functions
4. External resource uses Player.Functions.AddMoney(), etc.
5. Changes are cached and periodically saved to database
```

### Framework Bridge Call

```
1. Resource calls LXRFramework.AddMoney(source, 'cash', 100)
2. shared/framework.lua checks LXRFramework.ActiveFramework
3. Routes to appropriate framework's API
4. If LXR-Core: calls Player.Functions.AddMoney directly
5. If RSG-Core: translates to RSGCore equivalent
6. If VORP: translates to VORP equivalent
```

---

## Configuration

All framework behavior is controlled through `config.lua`:

- **Server settings** — Name, max players, spawn locations
- **Economy** — Currency types, starting amounts, paycheck intervals
- **Security** — Rate limits, anti-cheat toggles, logging
- **Performance** — Cache settings, update intervals
- **Framework** — Primary framework, fallback, auto-detection

See [DOCUMENTATION.md](DOCUMENTATION.md) for the full configuration reference.
