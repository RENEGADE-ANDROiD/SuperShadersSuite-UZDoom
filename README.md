# SuperShadersSuiteRT

A universal post-processing and material enhancement addon for Doom/Doom 2/Heretic/Hexen running on GZDoom or UZDoom which introduces RayTrace-lite effects and bundles MariFX, Screen-M, ACES tonemap, VHS/CRT, fisheye, **BodyCam Visual**, SoftShade, filmic LUTs, ReLite-inspired enhanced lighting, integrated DarkDoomZ, and unified **Visual Presets** that apply the whole stack at once.

<img width="578" height="456" alt="Screenshot 2026-06-21 021757" src="https://github.com/user-attachments/assets/6153699b-2331-4cee-ba3a-d919c10cd3dd" />

**Requires UZDoom/GZDoom 4.10 or newer** with the **hardware renderer** (OpenGL or Vulkan). Not compatible with the software renderer.

Forum link: https://forum.zdoom.org/viewtopic.php?t=62772

Load as a PK3/WAD alongside any IWAD or mod. Configure via **Main Menu → Super Shaders Suite RT Options** or **Options → Super Shaders Suite RT Options**.

---

## Visual Presets

The fastest way to use the addon. **Options → Visual Presets** applies coordinated settings across enhanced lighting, RT-lite, tone mapping, MariFX, and post-process FX.

**Dark Doom:** Quality and most style presets share the same baseline darkness (**Clamp** mode, **Dismal** setting). Preset tier does **not** make the scene darker — use **Lighting & Atmosphere → Dark Doom** for Murky, Oppressive, Pure, and other darkness levels. **Found Footage** uses **Compress + Oppressive** for extra horror darkness.

### Quality presets

| Preset | Description |
|--------|-------------|
| **Custom** | Manual control; selecting it does not auto-change settings |
| **Lite — Modern** | Enhanced lighting + planar/material reflections; RT-lite, wall bake, and sprite shadows off; MariFX sharpen/blur only |
| **Balanced — Enhanced** *(default)* | Lite stack plus contact AO, fluid SSR, wall bake lite, player floor shadows, stronger fluid glow |
| **Modern — RT Enhanced** | Balanced+ RT-lite (stronger AO/SSR, recursive relight, window/texture lights); ACES Narkowicz, clean grade — no film grain, monster/ceiling shadows, or wall-shadow traces |
| **Cinematic** | Stronger RT-lite and color bleed; filmic LUT (Cemetery), MariFX grade + vignette, lens flare/vignette post FX, film grain |
| **Ultra** | Maximum RT-lite (ceiling reflections, monster shadows); filmic LUT (Tide), MariFX ultra grade, stronger post FX; no film grain |

### Style presets

| Preset | Inspiration | Highlights |
|--------|-------------|------------|
| **Tactical — Operator** | Ready or Not, Squad | ACES Narkowicz (low crosstalk), contact AO, desaturated grade, light vignette, moderate bloom |
| **Arena — Competitive** | CS2, Valorant | Performance mode, no RT-lite/shadows/color bleed, sharpen-only MariFX, max readability |
| **Neon Hell — Inferno** | DOOM Eternal, Hotline Miami | Technicolor + strong bleed/glow, Salvation LUT, lens flare, heavy bloom |
| **Cold Sector — Sci-Fi** | Dead Space, Alien | Snow LUT, cool MariFX grade, high contact AO/wall bake, SoftShade dither |
| **Found Footage — Horror** | Outlast, bodycam games | Compress + Oppressive dark, grain/noise, vignette, chromatic aberration, subtle fisheye |
| **Retro Terminal — CRT** | Dusk, Blood | Screen-M phosphor + grill, SoftShade, Old Pal makeover, warm CRT temperature |
| **Painterly — Stylized** | Hades, BOTW | Plaza LUT, light technicolor, sector color bleed, SoftShade, no heavy shadows |
| **Photoreal — HDR** | Modern DOOM, RE4 | Ultra RT-lite + ACES Full, low bleed, ceiling reflections, clean bloom — no stylized post FX |

**Auto-Apply Preset** is on by default. Post-process effects update live; **reload the current map** after changing presets so sector lighting, wall bake, fluid lights, and reflections take full effect.

<img width="576" height="488" alt="Screenshot 2026-06-21 021842" src="https://github.com/user-attachments/assets/2b9c2bf1-d030-484b-ab75-521dcf4ac5d9" />

---

## RT-Lite (toward ray-traced look)

These are approximations — not true ray tracing — but they stack to feel closer to modern lighting:

- **Engine SSAO** — GZDoom depth-based ambient occlusion (`gl_ssao`)
- **Contact AO** — Screen-space crevice darkening
- **Fluid SSR** — Screen-space reflection boost while standing on allowlisted fluid flats (not on metal/snow)
- **Wall Bake Lite** — Softer wall shadow crush with ambient fill
- **RT-Relight Enhance** — Relighting-inspired world passes (flat/palette sector color, recursive bleed, smart volume, window/texture/GLDEF lights, polylabel fluid placement, lite door/lift light spill, lite wall shadows); tiered per visual preset
- **Planar reflections** — Engine mirrors on tagged fluid flats (NUKAGE, FWATER, LAVA, etc.)
- **Wall env reflections** — Generic shine on stock Doom / Heretic / Hexen wall names (`GLDEFS/materials_vanilla.gl`); TC flats can use the flat list below

Manual tuning: **Visual Presets → RT-Lite Effects (Manual)** (screen-space + RT-Relight world options).

Also included: sector bias, fluid glow, capped point lights on large pools, optional flat-name heuristics (`*WATER*`, `*LAVA*`, …), sprite floor/wall shadows (lite), and post-process color bleed with gamma/saturation grade.

**Universal flat matching:** Default CVAR list covers classic Doom fluids. With **Match Fluid Name Patterns** enabled, flats also match Heretic (`FLTWAWA*`, `FLTSLUD*`, `FLTLAVA*`, …) and Hexen (`X_001`–style) names, plus common tokens like `*WATER*` and `*LAVA*`. Add exact flat names via **Floor Flat 1–10** / **Ceiling Flat 1–3** text fields, then **reload the map**.

---

## Integrated Dark Doom

Replaces the separate DarkDoomZ WAD. **Options → Lighting & Atmosphere → Dark Doom**.

- Eight darkness presets (Dim through Pure) and multiple darkening modes
- Visual presets all start from **Clamp + Dismal** (except Found Footage); change darkness here without affecting RT-lite or post FX tier
- **Sync Enhanced & RT-Lite** ties each darkness preset to enhanced lighting *and* RT-lite (engine SSAO, contact AO, fluid SSR, wall bake, player shadows from Oppressive upward)
- Flashlight on **F** by default (configurable)

DarkDoomZ by Sterling "Caligari87" Parker (zlib license).

---

## Menu layout

The root options menu is organized into focused submenus:

- **Visual Presets** — One-click quality tiers
- **Lighting & Atmosphere** — Dark Doom, enhanced lighting, color bleed, materials
- **Color & Tone** — ACES, filmic LUT, World Gamma, Screen-M, bloom
- **Post-Process** — Vignette, lens flares, noise, FOV
- **MariFX** — Full GPU grading stack and preset slots
- **BodyCam Visual** — One-key digital BWC look (or analog VHS fallback)
- **Fisheye / VHS-CRT / SoftShade / Old Video** — Specialty effects

Only one filmic tonemap (ACES or Filmic LUT) should be active at a time.

---

## BodyCam Visual

Quick toggle for a chest-mounted camera look. **Options → BodyCam Visual** opens the submenu; use **Toggle Key** there to bind or rebind the in-game shortcut (default **B**). You can also assign **Toggle BodyCam Visual** under **Options → Customize Controls**.

Two styles are available:

| Style | Description |
|--------|-------------|
| **Digital (BWC shader)** *(default)* | Dedicated `bodycam.fp` post shader: wide-angle barrel lens, edge chromatic aberration, flat CMOS sensor noise, modest contrast/saturation grade, rolling-shutter skew on fast pans, and optional H.264-style block noise under motion |
| **Analog (VHS + fisheye)** | Legacy found-footage stack (VHS/CRT wobble + fisheye) |

When enabled, BodyCam saves your current VHS/fisheye settings and restores them when toggled off. **Evidence Overlay** draws a blinking **REC** marker, unit ID, map name, and session elapsed time in the corner (ZScript has no real-world clock, so the timestamp tracks time since BodyCam was enabled). Changes apply live — no map reload needed.

Tuning sliders (barrel, chromatic, noise, contrast, saturation, rolling shutter) affect Digital mode only.

---

## ACES tonemap

**Color & Tone → ACES Tonemap** includes:

- **ACES Narkowicz (Fast)** — Punchy game-friendly default curve
- **Full ACES (RRT+ODT)** — Heavier cinematic roll-off
- **Exposure Bias** slider (replaces old hardcoded brightness)
- Camera-style exposure controls and improved chroma-preserving pipeline

---

## Other features

MariFX, Screen-M, World Gamma, bloom boost, lens flares, chromatic aberration, film grain, generic environment reflections on stock Doom / Heretic / Hexen wall names, BodyCam Visual (keybind toggle), and optional performance mode (caps fluid lights, skips some color/reflection passes).

Motion blur is intentionally not included — use your mod's own mblur or a dedicated motion blur addon if desired.

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

Load before gameplay mods that depend on vanilla lighting if you use Dark Doom presets.
