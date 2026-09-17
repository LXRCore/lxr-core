/*  ═══════════════════════════════════════════════════════════════════════════
    🐺 LXR-CORE — Native RedM UI Feed Notifications (client, JavaScript)
    ═══════════════════════════════════════════════════════════════════════════
    The RDR3 feed natives take pointer structs, which Lua cannot build without a
    DataView shim; JavaScript has one natively, so this file owns the struct
    marshalling and exposes plain exports consumed by client/notify.lua:

      ShowTooltip(text, duration)                      top-left tip
      DisplayRightText(text, duration)                 right-hand tip
      ShowObjective(text, duration)                    bottom objective
      ShowBasicTopNotification(text, duration)         top banner
      ShowSimpleCenterText(text, duration)             center text
      ShowTopNotification(title, subtitle, duration)   top banner with subtitle
      ShowLocationNotification(text, location, duration)
      ShowAdvancedLeftNotification(title, subtitle, dict, icon, duration)
      ShowAdvancedRightNotification(text, dict, icon, color, duration)

    Struct layouts follow the public RDR3 native documentation.
    ═══════════════════════════════════════════════════════════════════════════
    © 2026 iBoss21 / LXRCore — All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════ */

(() => {
  'use strict';

  const str = (v) => CreateVarString(10, 'LITERAL_STRING', String(v ?? ''));
  const hash = (v) => BigInt(GetHashKey(String(v ?? '')));
  const ms = (v, d = 4000) => { const n = Number(v); return Number.isFinite(n) && n > 0 ? Math.floor(n) : d; };

  const duration = (d) => {
    const s = new DataView(new ArrayBuffer(48));
    s.setInt32(0, ms(d), true);
    return s;
  };

  const body = (size, writer) => {
    const s = new DataView(new ArrayBuffer(size));
    writer(s);
    return s;
  };

  // 0x049D5C615BD38BAD  UiFeedPostSampleNshTooltip
  exports('ShowTooltip', (text, d) => {
    const b = body(16, (s) => s.setBigInt64(8, BigInt(str(text)), true));
    Citizen.invokeNative('0x049D5C615BD38BAD', duration(d), b, 1);
  });

  // 0xB2920B9760F0F36B  UiFeedPostSampleNshRightText
  exports('DisplayRightText', (text, d) => {
    const b = body(16, (s) => s.setBigInt64(8, BigInt(str(text)), true));
    Citizen.invokeNative('0xB2920B9760F0F36B', duration(d), b, 1);
  });

  // 0xCEDBF17EFCC0E4A4  UiFeedPostObjective
  exports('ShowObjective', (text, d) => {
    const b = body(16, (s) => s.setBigInt64(8, BigInt(str(text)), true));
    Citizen.invokeNative('0xCEDBF17EFCC0E4A4', duration(d), b, 1);
  });

  // 0x860DDFE97CC94DF0  UiFeedPostOneTextShard
  exports('ShowBasicTopNotification', (text, d) => {
    const b = body(48, (s) => s.setBigInt64(8, BigInt(str(text)), true));
    Citizen.invokeNative('0x860DDFE97CC94DF0', duration(d), b, 1);
  });

  // 0x893128CDB4B81FBB  UiFeedPostSimpleText (center)
  exports('ShowSimpleCenterText', (text, d, color) => {
    const b = body(24, (s) => {
      s.setBigInt64(8, BigInt(str(text)), true);
      s.setBigInt64(16, hash(color || 'COLOR_PURE_WHITE'), true);
    });
    Citizen.invokeNative('0x893128CDB4B81FBB', duration(d), b, 1);
  });

  // 0xA6F4216AB10EB08E  UiFeedPostTwoTextShard
  exports('ShowTopNotification', (title, subtitle, d) => {
    const b = body(48, (s) => {
      s.setBigInt64(8, BigInt(str(title)), true);
      s.setBigInt64(16, BigInt(str(subtitle)), true);
    });
    Citizen.invokeNative('0xA6F4216AB10EB08E', duration(d), b, 1, 1);
  });

  // 0xD05590C1AB38F068  UiFeedPostSampleNshLocation
  exports('ShowLocationNotification', (text, location, d) => {
    const b = body(24, (s) => {
      s.setBigInt64(8, BigInt(str(location)), true);
      s.setBigInt64(16, BigInt(str(text)), true);
    });
    Citizen.invokeNative('0xD05590C1AB38F068', duration(d), b, 1, 1);
  });

  // 0x26E87218390E6729  UiFeedPostSampleNshMessage (left, with texture)
  exports('ShowAdvancedLeftNotification', (title, subtitle, dict, icon, d, color) => {
    const b = body(56, (s) => {
      s.setBigInt64(8, BigInt(str(title)), true);
      s.setBigInt64(16, BigInt(str(subtitle)), true);
      s.setBigInt64(32, hash(dict || 'generic_textures'), true);
      s.setBigInt64(40, hash(icon || 'tick'), true);
      s.setBigInt64(48, hash(color || 'COLOR_WHITE'), true);
    });
    Citizen.invokeNative('0x26E87218390E6729', duration(d), b, 1, 1);
  });

  // 0xB249EBCB30DD88E0  UiFeedPostSampleNshRight (with texture + sound)
  exports('ShowAdvancedRightNotification', (text, dict, icon, color, d) => {
    const s1 = duration(d);
    s1.setBigInt64(8, BigInt(str('Transaction_Feed_Sounds')), true);
    s1.setBigInt64(16, BigInt(str('Transaction_Positive')), true);
    const b = body(80, (s) => {
      s.setBigInt64(8, BigInt(str(text)), true);
      s.setBigInt64(16, BigInt(str(dict || 'generic_textures')), true);
      s.setBigInt64(24, hash(icon || 'tick'), true);
      s.setBigInt64(40, hash(color || 'COLOR_WHITE'), true);
      s.setInt32(48, 0, true);
    });
    Citizen.invokeNative('0xB249EBCB30DD88E0', s1, b, 1);
  });
})();
