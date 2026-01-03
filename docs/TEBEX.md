# LXRCore Tebex Integration Guide

<div align="center">

![LXRCore Tebex](https://via.placeholder.com/600x100/1a1a2e/16c784?text=LXRCore+Tebex+Integration)

**Complete Tebex Integration for Gold Currency & Premium Tokens**

[🏠 Home](../README.md) • [📚 Documentation](DOCUMENTATION.md)

**Made by iBoss • LXRCore - www.lxrcore.com**

</div>

---

## 🎯 Overview

LXRCore includes **full Tebex integration** allowing players to purchase:
- **Gold Currency** - Premium currency for special items
- **Premium Tokens** - Used in token shops
- **In-game Cash** - Direct money deposits
- **Items & Vehicles** - Instant delivery
- **VIP Status** - Automatic VIP assignment

---

## 📦 Features

✅ **Automatic Delivery** - Instant delivery when player is online
✅ **Offline Queue** - Purchases delivered when player logs in
✅ **Refund Support** - Automatic logging of refunds
✅ **Chargeback Detection** - Fraud prevention alerts
✅ **Transaction Logging** - Complete audit trail
✅ **Multiple Package Types** - Flexible reward system
✅ **Secure Webhooks** - Signature verification
✅ **Admin Commands** - Easy management

---

## 🚀 Quick Setup

### Step 1: Create Tebex Account

1. Go to [tebex.io](https://www.tebex.io)
2. Create a webstore account
3. Set up your store (name, currency, etc.)
4. Note your **Secret Key** from the settings

### Step 2: Configure LXRCore

Edit `/lxr-core/config.lua`:

```lua
LXRConfig.Tebex = {
    Enabled = true,              -- Enable Tebex integration
    SecretKey = 'YOUR_SECRET_KEY_HERE',  -- Paste your Tebex secret key
    
    -- Keep existing package configuration or customize
}
```

### Step 3: Import Database Tables

Run the SQL file:

```bash
mysql -u your_username -p your_database < tebex_tables.sql
```

Or manually execute in your database tool (HeidiSQL, phpMyAdmin, etc.)

### Step 4: Set Up Webhook

In your Tebex panel:

1. Go to **Settings** → **Webhooks**
2. Add new webhook:
   - **URL**: `https://your-server-ip:30120/tebex/webhook`
   - **Secret**: Your Tebex secret key
   - **Events**: Select "Payment Completed", "Payment Refunded", "Chargeback"
3. Save and test

### Step 5: Create Packages

In Tebex panel, create packages and note their IDs. Then configure in `config.lua`:

```lua
Packages = {
    [YOUR_PACKAGE_ID] = {
        name = 'Starter Pack',
        goldcurrency = 100,  -- Amount of gold currency
        tokens = 50,         -- Amount of tokens
        cash = 10,          -- Cash in dollars
    },
}
```

### Step 6: Restart Server

```bash
restart lxr-core
```

Check console for:
```
[LXRCore] [Tebex] Integration initialized
[LXRCore] [Tebex] Loaded X package rewards
```

---

## 💰 Package Configuration Examples

### Basic Pack
```lua
[1001] = {
    name = 'Starter Pack - $4.99',
    goldcurrency = 100,
    tokens = 50,
    cash = 10,
}
```

### Gold Only
```lua
[2001] = {
    name = '100 Gold - $2.99',
    goldcurrency = 100,
}
```

### Item Pack
```lua
[3001] = {
    name = 'Gunslinger Pack - $9.99',
    goldcurrency = 200,
    tokens = 100,
    items = {
        weapon_revolver_schofield = 1,
        weapon_rifle_springfield = 1,
        ammo_revolver = 100,
    }
}
```

### VIP Package
```lua
[4001] = {
    name = 'VIP 30 Days - $14.99',
    goldcurrency = 300,
    tokens = 150,
    command = 'setvip %s 30'  -- Sets VIP for 30 days
}
```

### Ultimate Pack
```lua
[5001] = {
    name = 'Ultimate Pack - $49.99',
    goldcurrency = 2500,
    tokens = 1000,
    cash = 100,
    items = {
        horse_arabian = 1,
        saddle_special_01 = 1,
        weapon_revolver_schofield = 1,
    },
    command = 'setvip %s 90'
}
```

---

## 🎮 In-Game Usage

### For Players

**Purchasing:**
1. Visit your Tebex store
2. Select package
3. Complete payment
4. Receive items instantly (or when logging in)

**Checking Gold Currency:**
```
/checkmoney goldcurrency
```

**Checking Tokens:**
```
/checkmoney tokens
```

### For Admins

**Check Status:**
```
/tebex:status
```

**Test Delivery:**
```
/tebex:test [player_id] [package_id]
```

**View Queue:**
```
/tebex:queue
```

**Manual Give Gold:**
```lua
exports['lxr-core']:GiveGoldCurrency(source, 100, 'Admin gift')
```

**Manual Give Tokens:**
```lua
exports['lxr-core']:GiveTokens(source, 50, 'Event reward')
```

---

## 🛒 Setting Up Shops

### Gold Currency Shop

Create a script that uses gold currency:

```lua
-- server/gold_shop.lua
RegisterNetEvent('goldshop:purchase', function(itemName)
    local Player = exports['lxr-core']:GetPlayer(source)
    local goldCost = LXRConfig.Tebex.GoldShop.items[itemName]
    
    if not goldCost then return end
    
    local goldAmount = Player.Functions.GetMoney('goldcurrency')
    
    if goldAmount >= goldCost then
        if Player.Functions.RemoveMoney('goldcurrency', goldCost, 'Gold Shop Purchase') then
            Player.Functions.AddItem(itemName, 1)
            TriggerClientEvent('LXRCore:Notify', source, 9, 
                'Purchased ' .. itemName .. ' for ' .. goldCost .. ' gold!', 5000)
        end
    else
        TriggerClientEvent('LXRCore:Notify', source, 9, 
            'Not enough gold currency!', 5000)
    end
end)
```

### Token Shop

```lua
-- server/token_shop.lua
RegisterNetEvent('tokenshop:purchase', function(itemName)
    local Player = exports['lxr-core']:GetPlayer(source)
    local tokenCost = LXRConfig.Tebex.TokenShop.items[itemName]
    
    if not tokenCost then return end
    
    local tokenAmount = Player.Functions.GetMoney('tokens')
    
    if tokenAmount >= tokenCost then
        if Player.Functions.RemoveMoney('tokens', tokenCost, 'Token Shop Purchase') then
            Player.Functions.AddItem(itemName, 1)
            TriggerClientEvent('LXRCore:Notify', source, 9, 
                'Purchased ' .. itemName .. ' for ' .. tokenCost .. ' tokens!', 5000)
        end
    else
        TriggerClientEvent('LXRCore:Notify', source, 9, 
            'Not enough tokens!', 5000)
    end
end)
```

---

## 📊 Database Structure

### tebex_queue
Stores pending deliveries for offline players.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Auto-increment ID |
| uuid | VARCHAR(100) | Player identifier |
| packages | LONGTEXT | JSON array of packages |
| transaction_id | VARCHAR(255) | Tebex transaction ID |
| created_at | TIMESTAMP | When queued |
| delivered | TINYINT(1) | Delivery status |
| delivered_at | TIMESTAMP | When delivered |

### tebex_transactions
Logs all transactions for audit and analytics.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Auto-increment ID |
| transaction_id | VARCHAR(255) | Tebex transaction ID (unique) |
| identifier | VARCHAR(100) | Player identifier |
| player_name | VARCHAR(255) | Player name |
| package_id | INT | Package ID |
| package_name | VARCHAR(255) | Package name |
| amount | DECIMAL(10,2) | Real money amount |
| goldcurrency_amount | INT | Gold delivered |
| tokens_amount | INT | Tokens delivered |
| status | ENUM | completed/refunded/chargeback |
| created_at | TIMESTAMP | Purchase date |

### Analytics View
```sql
SELECT * FROM tebex_summary ORDER BY purchase_date DESC;
```

Shows daily revenue, total transactions, refunds, etc.

---

## 🔒 Security Features

### Webhook Verification
- Signature validation prevents fake webhooks
- Only accepts requests from Tebex servers

### Fraud Protection
- Chargeback detection and logging
- Automatic admin alerts for suspicious activity
- Transaction audit trail

### Anti-Abuse
- Duplicate transaction prevention
- Offline delivery queue prevents exploits
- Rate limiting on package delivery

---

## 🐛 Troubleshooting

### Webhook Not Working

**Check:**
1. Is LXRCore started? Check console for `[Tebex] Integration initialized`
2. Is webhook URL correct? Should be `your-ip:30120/tebex/webhook`
3. Is secret key set in config.lua?
4. Check Tebex panel → Webhooks → Test Connection

**Console Errors:**
```
[LXRCore] [Tebex] ERROR: Tebex secret key not configured!
```
**Fix:** Set `SecretKey` in config.lua

### Package Not Delivered

**Check:**
1. Was player online? Check offline queue: `/tebex:queue`
2. Is package ID configured in config.lua?
3. Check database: `SELECT * FROM tebex_queue`
4. Check logs: `SELECT * FROM tebex_transactions`

**Manual Delivery:**
```
/tebex:test [player_id] [package_id]
```

### Gold/Tokens Not Showing

**Check:**
1. Restart server after config changes
2. Check player data: `/checkmoney goldcurrency`
3. Verify package configuration includes goldcurrency/tokens

---

## 💡 Best Practices

### Pricing Strategy

**1899 Economy Reference:**
- Starter packs: $2.99 - $4.99 (100-250 gold)
- Medium packs: $9.99 - $14.99 (500-750 gold)
- Large packs: $19.99 - $29.99 (1000-2000 gold)
- Ultimate packs: $49.99+ (2500+ gold)

**Token Ratios:**
- Generally 50% of gold amount
- Example: 100 gold = 50 tokens

### Package Design

✅ **Do:**
- Offer starter pack ($2.99-$4.99) for new players
- Include "best value" pack with bonus gold
- Bundle VIP with large purchases
- Offer gold-only packs for flexibility

❌ **Don't:**
- Make items only available for real money (pay-to-win)
- Offer instant max-level or god-mode items
- Price too high for your community
- Forget about refund impact

### Marketing Tips

1. **First Purchase Bonus** - Extra gold for first-time buyers
2. **Limited Time** - Sale events increase urgency
3. **Bundles** - Save money buying bundles vs individual
4. **VIP Perks** - Make VIP valuable but not required
5. **Seasonal** - Holiday-themed packages

---

## 📈 Analytics & Reports

### Revenue Tracking

```sql
-- Total revenue
SELECT SUM(amount) as total_revenue 
FROM tebex_transactions 
WHERE status = 'completed';

-- Revenue by month
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') as month,
    COUNT(*) as transactions,
    SUM(amount) as revenue
FROM tebex_transactions
WHERE status = 'completed'
GROUP BY month
ORDER BY month DESC;

-- Top packages
SELECT 
    package_name,
    COUNT(*) as purchases,
    SUM(amount) as revenue
FROM tebex_transactions
WHERE status = 'completed'
GROUP BY package_id
ORDER BY purchases DESC
LIMIT 10;
```

### Player Spending

```sql
-- Top spenders
SELECT 
    player_name,
    identifier,
    COUNT(*) as purchases,
    SUM(amount) as total_spent,
    SUM(goldcurrency_amount) as total_gold,
    SUM(tokens_amount) as total_tokens
FROM tebex_transactions
WHERE status = 'completed'
GROUP BY identifier
ORDER BY total_spent DESC
LIMIT 20;
```

---

## 🔗 Additional Resources

- [Tebex Documentation](https://docs.tebex.io)
- [Tebex API Reference](https://docs.tebex.io/developers/)
- [LXRCore Discord](https://discord.gg/lxrcore)
- [Support](https://www.lxrcore.com/support)

---

## 📞 Support

Need help with Tebex integration?

- 📖 [Read Full Documentation](DOCUMENTATION.md)
- 💬 [Join Discord](https://discord.gg/lxrcore)
- 🐛 [Report Issues](https://github.com/LXRCore/lxr-core/issues)
- 🌐 [Visit Website](https://www.lxrcore.com)

---

<div align="center">

**Made by iBoss • LXRCore - www.lxrcore.com**

**Launched on [The Land of Wolves RP](https://www.wolves.land)**

</div>
