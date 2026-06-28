# SuperShadersSuiteRT

A universal post-processing and material enhancement addon for Doom/Doom 2/Heretic/Hexen on **GZDoom / UZDoom**. It bundles ray-trace-*lite* screen effects, ReLite-inspired world lighting, integrated **Dark Doom**, MariFX grading, ACES tonemap, atmospheric haze, **BodyCam Visual**, and **28 one-click Visual Presets** that configure the whole stack at once.

<img width="578" height="456" alt="Screenshot 2026-06-21 021757" src="https://github.com/user-attachments/assets/6153699b-2331-4cee-ba3a-d919c10cd3dd" />

**Requires UZDoom/GZDoom 4.10+** with the **hardware renderer** (OpenGL or Vulkan). Software renderer is not supported.

Forum: https://forum.zdoom.org/viewtopic.php?t=62772

**Menu:** Main Menu → **Super Shaders Suite RT Options** (or Options → same name)

---

## Quick start

1. Load `SuperShadersSuiteRT.wad` after your IWAD/map, before or with gameplay mods.
2. Open **Visual Presets** → pick a tier (default: **Vanilla Plus — Classic Enhanced**).
3. Leave **Auto-Apply Preset** on — post FX and tone update live when you change presets.
4. **Reload the map** after picking a preset so sector lighting, relight passes, fluid lights, and reflections fully apply.

---

## Visual Presets

One menu applies lighting, RT-lite, Dark Doom darkness, tone mapping, MariFX, and post-process FX together.

Presets are grouped in the menu as **Quality**, **Style**, and **IWAD** submenus. Pick **Custom (Manual)** to tune everything yourself without auto-overwrites.

### Dark Doom per preset

Presets no longer all share the same darkness. Each picks a **Clamp** darkness tier (Dim → Stygian). Dark moods still keep **sector color bleed** and enhanced lighting — post bleed is toned down, not removed.

| Darkness | Used by (examples) |
|----------|-------------------|
| **Off** | Arena — Competitive |
| **Dim** | Lite, Vanilla Plus |
| **Murky** | Modern, Co-op Ready, Overcast Outdoor |
| **Dismal** | Balanced (default middle tier) |
| **Oppressive** | Cinematic, Stormy, Found Footage (mode 2 Compress) |
| **Inky** | Ultra, Noir Operator, Liminal |
| **Stygian** | Gothic Indoor, Hexen Crypt |

Override anytime under **Lighting & Atmosphere → Dark Doom**.

### Quality presets

| Preset | What you'll notice |
|--------|-------------------|
| **Lite — Modern** | Lightest stack: contact AO only, sector relight bleed, no post bleed, Dim dark |
| **Vanilla Plus — Classic Enhanced** *(default)* | Faithful 1993+: soft sharpen, light fluids, contact AO, **no post bleed**, Dim dark |
| **Balanced — Enhanced** | Hybrid AO + post color bleed, filmic grade, player shadows, Dismal dark |
| **Modern — RT Enhanced** | ACES Narkowicz, contact AO, map-load bleed only, light haze |
| **Cinematic** | Film LUT, grain, lens FX, atmosphere, Oppressive dark |
| **Ultra — RT-Lite** | Max RT-lite (ceiling reflections, monster shadows), Inky dark + lift |
| **Arena — Competitive** | Performance mode, no bleed/shadows/RT-lite, max readability, dark off |
| **Co-op Ready** | Multiplayer-friendly; player shadows only, Murky dark |

### Style presets

| Preset | Vibe |
|--------|------|
| **Tactical — Operator** | Desaturated MariFX grade, contact AO, map-load bleed (no ACES) |
| **Neon Hell — Inferno** | Technicolor inferno, heavy bloom, Salvation LUT |
| **Cold Sector — Sci-Fi** | Cool grade, SoftShade dither, high wall bake |
| **Found Footage — Horror** | Compress + Oppressive dark, grain, vignette, fisheye |
| **Retro Terminal — CRT** | *Alien: Isolation* green phosphor CRT, grain, Murky industrial dark |
| **Painterly — Stylized** | Plaza LUT, warm sector color, SoftShade |
| **Photoreal — HDR** | ACES Full, clean reflections, low stylization |
| **Overcast Outdoor** | Aerial haze + god rays for outdoor maps |
| **Gothic Indoor** | Stygian crypt dark, shadow deband, natural vignette |
| **Noir Operator** | Inky dark + **built-in clean bodycam**, mono grade, red bleed |
| **Golden Hour** | Warm sunset haze, Plaza LUT |
| **Liminal** | Washed SoftShade backrooms, Inky dark |
| **Stormy Atmosphere** | Cool haze, strong AO, low reflections |
| **Ultraviolence** | Everything stacked — screenshot mode |
| **Vaporwave — Outrun** | Pastel technicolor, Plaza LUT |
| **Brutal Carnage** | Heavy blood glow, RG bleed (PB-friendly) |
| **Software Nostalgia** | SoftShade ordered dither + warm vanilla palette (no CRT / no RT-lite) |
| **VR Comfort** | Stable ACES, no CA / fisheye / heavy vignette |

### IWAD presets

| Preset | Tuned for |
|--------|-----------|
| **Heretic Haven** | Warm fantasy fluids, outdoor castle lighting |
| **Hexen Crypt** | Purple crypt grade, Stygian dark, recursive bleed |

### Live vs map reload

| Changes immediately (no reload) | Needs map reload |
|--------------------------------|------------------|
| Post shaders (ACES, MariFX, bloom, BodyCam, haze, contact AO) | Sector lighting / bias / smooth walls |
| Dark Doom sector darkness (after a moment) | RT-Relight world passes |
| Visual preset CVAR bundle | Fluid point lights, wall bake, planar reflections |

**Auto-Apply Preset** is on by default — changing the dropdown applies the bundle in-game without pressing Apply.

<img width="576" height="488" alt="Screenshot 2026-06-21 021842" src="https://github.com/user-attachments/assets/2b9c2bf1-d030-484b-ab75-821dcf4ac5d9" />

---

## RT-Lite (ray-trace *lite*)

Screen-space and map-load approximations — not true path tracing, but they stack well:

| Effect | What it does |
|--------|--------------|
| **Engine SSAO** | Real depth AO (`gl_ssao` in engine menu) |
| **Contact AO** | Custom crevice darkening post shader |
| **Fluid SSR** | Reflection/distortion boost while on allowlisted fluid flats |
| **Wall Bake Lite** | Softer wall shadow crush + ambient fill |
| **RT-Relight Enhance** | Sector flat tint, recursive bleed, procedural window/texture lights, door spill, lite wall shadows |
| **Planar reflections** | Engine mirrors on tagged fluid sectors |
| **Wall env shine** | Generic Fresnel on stock IWAD wall names |

**AO Strategy** (RT-Lite menu): Off / Engine only / Contact only / Hybrid (recommended on Balanced+) / Contact primary.

**Universal fluid flats:** Default CVAR lists cover Doom fluids. Enable **Match Fluid Name Patterns** for Heretic/Hexen names (`FLTWAWA*`, `X_*`, `*WATER*`, …). Add custom names in **Floor Flat 1–10** text fields, then reload the map.

Manual tuning: **Visual Presets → RT-Lite Effects (Manual)**.

---

## Atmospheric post FX

New screen-space mood passes under **Lighting & Atmosphere → Atmospheric** (also toggled by several style presets):

| Shader | Purpose |
|--------|---------|
| **Aerial Haze** | Distance wash + cool sky tint (outdoor / overcast looks) |
| **Light Shafts** | Radial god-ray bloom from bright sky pixels |
| **Shadow Deband** | Reduces color banding in crushed dark areas (Gothic, stormy maps) |

These are lightweight compared to full RT-lite and update live.

---

## Integrated Dark Doom

Built-in — no separate DarkDoomZ WAD. **Options → Lighting & Atmosphere → Dark Doom**.

- Eight darkness amounts: Dim (32) through Pure (256)
- Modes: Subtract, Compress, Clamp, Crush, plus classic Lite/Classic/Black
- **Sync Enhanced & RT-Lite** — darkness tier also nudges enhanced lighting and RT-lite CVARs when enabled
- Flashlight on **F** by default (configurable)

DarkDoomZ by Sterling "Caligari87" Parker (zlib license).

---

## Performance & stability

Large PB maps and long mod stacks can spike CPU on map load. Two safety toggles (on by default):

| Option | What it does |
|--------|--------------|
| **Large Map Safe** | On heavy maps (768+ sectors): skips sync lighting on load, disables smooth walls / recursive relight on medium maps, chunks remaining work across ticks |
| **Process Safe** | Disables the full post stack (`sss_post_stack`) and caps expensive runtime features |

If the game stutters on map entry, leave both on. If you want the full visual stack on a big map, turn **Process Safe** off first, then **Large Map Safe** — expect a longer load hitch.

**Hitbox Debug** (PB-style locational damage overlay) is **off by default**. Enable under **Super Shaders Suite RT → Hitbox Debug** only when tuning — it can cost performance when many enemies are active.

---

## BodyCam Visual

Chest-mounted camera look. **Options → BodyCam Visual** or bind **Toggle BodyCam Visual** (default key **B**).

| Style | Description |
|-------|-------------|
| **Digital (BWC shader)** *(default)* | Barrel lens, edge chroma, CMOS noise, rolling shutter on fast pans |
| **Analog (VHS + fisheye)** | Legacy found-footage stack |

**Noir Operator** preset enables a **clean digital bodycam** automatically (low noise, no REC overlay). Other presets turn BodyCam off unless you toggle it yourself.

When toggled manually, BodyCam saves/restores your VHS and fisheye settings. **Evidence Overlay** shows REC marker, unit ID, map name, and session time.

---

## ACES tonemap

**Color & Tone → ACES Tonemap**

- **ACES Narkowicz (Fast)** — punchy game-friendly curve (Modern; Tactical uses MariFX grade instead)
- **Full ACES (RRT+ODT)** — heavier cinematic roll-off (Photoreal)
- Exposure bias and saturation sliders

Only one filmic path (ACES **or** Filmic LUT) should be active at a time.

---

## Menu map

| Submenu | Contents |
|---------|----------|
| **Visual Presets** | Quality / Style / IWAD tiers, Auto-Apply, Apply Now |
| **Lighting & Atmosphere** | Dark Doom, enhanced lighting, color bleed, atmospheric FX, materials |
| **RT-Lite Effects (Manual)** | AO strategy, contact AO, fluid SSR, relight tiers |
| **Color & Tone** | ACES, filmic LUT, World Gamma, Screen-M, bloom |
| **Post-Process** | Vignette, lens flares, noise, natural vignette, FOV |
| **MariFX** | Full GPU grading stack + 8 preset slots |
| **BodyCam Visual** | Style, overlay, tuning sliders, toggle key |
| **Hitbox Debug** | PB-style zone wireframe / HUD (off by default) |
| **Fisheye / VHS-CRT / SoftShade / Old Video** | Specialty stacks |

---

## Other bundled features

- **MariFX** — Sharpen, blur, technicolor, LUT, grain, vignette, color matrix, preset save/load
- **Screen-M (gl_screem)** — CRT phosphor, grill, palette makeover
- **SoftShade** — Ordered dither / palette crush
- **World Gamma + Bloom Boost** — Pre/post bloom grading
- **Filmic LUTs** — Cemetery, Plaza, Snow, Salvation, Tide, Arena, …
- **Sprite shadows** — Lite floor stencils under players/monsters (tiered per preset)
- **Color bleed** — Post shader and/or sector recursive bleed (configurable source)
- **Performance mode** — Caps fluid lights, skips heavy passes (Arena preset)

Motion blur is intentionally not included — use your mod's mblur or a dedicated addon if desired.

---

## Renderer support

| Backend | Support |
|---------|---------|
| OpenGL | Full |
| Vulkan | Full |
| OpenGL ES | Partial (some effects may differ) |
| Software | Not supported |

---

## Load order

1. IWAD  
2. Map WAD  
3. **SuperShadersSuiteRT.wad**  
4. Gameplay / TC mods (order depends on intent)

Load **before** TCs that replace fluid flat names if you rely on default fluid lists. Load **before** gameplay mods that assume vanilla sector brightness if you use Dark Doom presets.

**Do not** run alongside the standalone **Relighting** mod — effects will double-apply.

---

## Building from source

From the repo root (PowerShell):

```powershell
.\build-addon.ps1
```

Outputs `SuperShadersSuiteRT.wad` and updates configured Steam bundle zips. See `tools/build-addon.ps1` for paths.
