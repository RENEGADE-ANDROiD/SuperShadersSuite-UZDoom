// Disables all bundled post shaders when the user master switch is off.
// Autosave / cl_waitforsave must be set via launch args or ini — engine blocks ZScript changes.

class SSSPostProcessSuppressor : StaticEventHandler
{
	override void UiTick()
	{
		let menuOpen = CVar.FindCVar("sss_menu_open");
		if (menuOpen)
			menuOpen.SetBool(Menu.GetCurrentMenu() != null);

		let preview = CVar.FindCVar("sss_preset_preview");
		if (preview)
			preview.SetBool(Menu.GetCurrentMenu() != null && gamestate == GS_LEVEL);
	}

	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!CVar.GetCVar("sss_post_stack", p).GetBool())
		{
			DisableSSSPostShaders(p);
			return;
		}

		// Only bleed + contact AO false-trigger on menu UI; grade/ACES stay on for preset preview.
		if (SSSPostProcessSuppressor.MenuBlocksBleedAO())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			Shader.SetEnabled(p, "sss_contactao", false);
		}

		if (!SSSPostProcessSuppressor.PostWarmupReady())
		{
			SSSPostProcessSuppressor.DisableLuminanceScreenFX(p);
			MariFXHandler.DisableMariFXStack(p);
			return;
		}

		EnforceModernSafeStack(p);
		EnforcePhotorealSafeStack(p);
	}

	// Modern (13): last handler in chain — strip luminance post even if CVAR apply desyncs.
	clearscope static void EnforceModernSafeStack(PlayerInfo p)
	{
		if (CVar.GetCVar("sss_visual_preset", p).GetInt() != 13)
			return;

		DisableLuminanceScreenFX(p);
		Shader.SetEnabled(p, "sss_mfx_lumasharp", false);
		Shader.SetEnabled(p, "sss_mfx_bss_sharp", false);
		Shader.SetEnabled(p, "mfx_grading", false);
		Shader.SetEnabled(p, "mfx_vignette", false);
		Shader.SetEnabled(p, "mfx_bss_blur", false);
		Shader.SetEnabled(p, "mfx_bss_shift", false);
		Shader.SetEnabled(p, "sss_fluidssr", false);
		// ACES allowed on Modern — mild grade set by ApplyModern (at_enabled + sky soften).
		Shader.SetEnabled(p, "TonemapDefault", false);
		Shader.SetEnabled(p, "TonemapArena", false);
		Shader.SetEnabled(p, "TonemapSalvation", false);
		Shader.SetEnabled(p, "TonemapPlaza", false);
		Shader.SetEnabled(p, "TonemapCemetery", false);
		Shader.SetEnabled(p, "TonemapTitlemap", false);
		Shader.SetEnabled(p, "TonemapTide", false);
		Shader.SetEnabled(p, "TonemapSnow", false);
		DisableScreenMShaders(p);
	}

	// Photoreal (12): ACES-only grade — strip MariFX grade/sharpen and tic-based fluid SSR.
	clearscope static void EnforcePhotorealSafeStack(PlayerInfo p)
	{
		if (CVar.GetCVar("sss_visual_preset", p).GetInt() != 12)
			return;

		Shader.SetEnabled(p, "sss_mfx_lumasharp", false);
		Shader.SetEnabled(p, "sss_mfx_bss_sharp", false);
		Shader.SetEnabled(p, "mfx_grading", false);
		Shader.SetEnabled(p, "mfx_bss_blur", false);
		Shader.SetEnabled(p, "mfx_bss_shift", false);
		Shader.SetEnabled(p, "sss_fluidssr", false);
	}

	// Bleed + contact AO only — flat menu panels false-trigger these.
	clearscope static bool PostWarmupReady()
	{
		if (gamestate != GS_LEVEL)
			return false;
		if (SSSReflectionHelper.IsPresetFastApply())
			return Level.MapTime >= 3;
		return Level.MapTime >= 35;
	}

	// Block bleed/AO on flat menus; allow during in-level preset browse (sss_preset_preview).
	clearscope static bool MenuBlocksBleedAO()
	{
		let c = CVar.FindCVar("sss_menu_open");
		if (!c || !c.GetBool())
			return false;
		let preview = CVar.FindCVar("sss_preset_preview");
		return !(preview && preview.GetBool());
	}

	clearscope static bool BodyCamActive()
	{
		let c = CVar.FindCVar("sss_bodycam_active");
		return c && c.GetBool();
	}

	// Screen-M / full overlay stack — same preview exception as bleed/AO.
	clearscope static bool MenuBlocksScreenFX()
	{
		return MenuBlocksBleedAO();
	}

	clearscope static void DisableLuminanceScreenFX(PlayerInfo p)
	{
		Shader.SetEnabled(p, "sss_colorbleed", false);
		Shader.SetEnabled(p, "sss_contactao", false);
		Shader.SetEnabled(p, "sss_atmo_haze", false);
		Shader.SetEnabled(p, "sss_atmo_godrays", false);
		Shader.SetEnabled(p, "sss_atmo_deband", false);
		Shader.SetEnabled(p, "db_softshade", false);
	}

	// Clears stale enable state when CVARs change mid-frame (preset auto-apply).
	clearscope static void FlushPresetTransition(PlayerInfo p)
	{
		Shader.SetEnabled(p, "sss_colorbleed", false);
		Shader.SetEnabled(p, "sss_contactao", false);
		Shader.SetEnabled(p, "sss_mfx_lumasharp", false);
		Shader.SetEnabled(p, "sss_mfx_bss_sharp", false);
		Shader.SetEnabled(p, "sss_fluidssr", false);
	}

	clearscope static void DisableScreenMShaders(PlayerInfo p)
	{
		Shader.SetEnabled(p, "Fos4", false);
		Shader.SetEnabled(p, "res", false);
		Shader.SetEnabled(p, "OldPals", false);
		Shader.SetEnabled(p, "Gamma", false);
		Shader.SetEnabled(p, "GrillerDivvy", false);
		Shader.SetEnabled(p, "GrillerSubby", false);
		Shader.SetEnabled(p, "Temp", false);
		Shader.SetEnabled(p, "TempColour", false);
		Shader.SetEnabled(p, "TempGrey", false);
		Shader.SetEnabled(p, "Widescreem", false);
		Shader.SetEnabled(p, "WidescreemZ", false);
	}

	clearscope static void DisableSSSPostShaders(PlayerInfo p)
	{
		Shader.SetEnabled(p, "sss_mfx_lumasharp", false);
		Shader.SetEnabled(p, "mfx_grading", false);
		Shader.SetEnabled(p, "mfx_technicolor", false);
		Shader.SetEnabled(p, "mfx_lutgrading", false);
		Shader.SetEnabled(p, "mfx_colormatrix", false);
		Shader.SetEnabled(p, "mfx_huesaturation", false);
		Shader.SetEnabled(p, "mfx_bss_blur", false);
		Shader.SetEnabled(p, "sss_mfx_bss_sharp", false);
		Shader.SetEnabled(p, "mfx_bss_shift", false);
		Shader.SetEnabled(p, "mfx_borderblur", false);
		Shader.SetEnabled(p, "mfx_grain", false);
		Shader.SetEnabled(p, "mfx_dirt", false);
		Shader.SetEnabled(p, "mfx_vignette", false);
		Shader.SetEnabled(p, "mfx_retrofx", false);
		Shader.SetEnabled(p, "mfx_palette", false);
		Shader.SetEnabled(p, "sss_bodycam", false);
		Shader.SetEnabled(p, "fisheyeshader", false);
		Shader.SetEnabled(p, "VHSCRTShader", false);
		Shader.SetEnabled(p, "sss_colorbleed", false);
		Shader.SetEnabled(p, "sss_fluidssr", false);
		Shader.SetEnabled(p, "sss_contactao", false);
		Shader.SetEnabled(p, "sss_atmo_haze", false);
		Shader.SetEnabled(p, "sss_atmo_godrays", false);
		Shader.SetEnabled(p, "sss_atmo_deband", false);
		Shader.SetEnabled(p, "AcesTonemap", false);
		Shader.SetEnabled(p, "TonemapDefault", false);
		Shader.SetEnabled(p, "TonemapArena", false);
		Shader.SetEnabled(p, "TonemapSalvation", false);
		Shader.SetEnabled(p, "TonemapPlaza", false);
		Shader.SetEnabled(p, "TonemapCemetery", false);
		Shader.SetEnabled(p, "TonemapTitlemap", false);
		Shader.SetEnabled(p, "TonemapTide", false);
		Shader.SetEnabled(p, "TonemapSnow", false);
		Shader.SetEnabled(p, "FilmicTonemap", false);
		Shader.SetEnabled(p, "FilmGrain", false);
		Shader.SetEnabled(p, "CubicCA", false);
		Shader.SetEnabled(p, "oldvideoshader", false);
		Shader.SetEnabled(p, "db_softshade", false);
		Shader.SetEnabled(p, "NaturalVignette", false);
		Shader.SetEnabled(p, "lensflareshader", false);
		Shader.SetEnabled(p, "vignetteshader", false);
		Shader.SetEnabled(p, "noiseshader", false);
		Shader.SetEnabled(p, "WorldGammaPostBloom", false);
		Shader.SetEnabled(p, "WorldGammaPreBloom", false);
		Shader.SetEnabled(p, "BloomBoostPre", false);
		Shader.SetEnabled(p, "BloomBoostPost", false);
		Shader.SetEnabled(p, "sss_psxlight", false);
		DisableScreenMShaders(p);
	}
}
