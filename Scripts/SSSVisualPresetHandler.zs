// Unified visual presets + RT-lite post-process handlers

class SSSVisualPresets
{
	// Play-context bridge for preset apply (UZDoom 4.14: UI vs play CVAR split).
	clearscope static CVar GetCVarForApply(String name)
	{
		let bridge = CVar.FindCVar("sss_preset_apply_play");
		int playIndex = bridge ? bridge.GetInt() : -1;
		if (playIndex < 0 || playIndex >= MAXPLAYERS)
			playIndex = consoleplayer;
		if (playIndex >= 0 && playIndex < MAXPLAYERS)
		{
			let c = CVar.GetCVar(name, players[playIndex]);
			if (c)
				return c;
		}
		return CVar.FindCVar(name);
	}

	clearscope static void Apply(int preset)
	{
		if (preset <= 0)
			return;

		SetSpecialtyOff();

		int p = clamp(preset, 1, 29);
		if (p == 21)
			p = 20; // Stream Safe removed — Co-op Ready

		switch (p)
		{
		case 1: ApplyLite(); break;
		case 2: ApplyBalanced(); break;
		case 3: ApplyCinematic(); break;
		case 4: ApplyUltra(); break;
		case 13: ApplyModern(); break;
		case 5: ApplyTactical(); break;
		case 6: ApplyArena(); break;
		case 7: ApplyNeonHell(); break;
		case 8: ApplyColdSector(); break;
		case 9: ApplyFoundFootage(); break;
		case 10: ApplyRetroTerminal(); break;
		case 11: ApplyPainterly(); break;
		case 12: ApplyPhotoreal(); break;
		case 14: ApplyVanillaPlus(); break;
		case 15: ApplyOvercastOutdoor(); break;
		case 16: ApplyGothicIndoor(); break;
		case 17: ApplyNoirOperator(); break;
		case 18: ApplyHereticHaven(); break;
		case 19: ApplyHexenCrypt(); break;
		case 20: ApplyCoopReady(); break;
		case 22: ApplyGoldenHour(); break;
		case 23: ApplyLiminal(); break;
		case 24: ApplyStormyAtmosphere(); break;
		case 25: ApplyUltraviolence(); break;
		case 26: ApplyVaporwave(); break;
		case 27: ApplyBrutalCarnage(); break;
		case 28: ApplySoftwareNostalgia(); break;
		case 29: ApplyVRComfort(); break;
		}

		ApplyRelightPresetTier(p);
	}

	clearscope static void ApplyRelightPresetTier(int preset)
	{
		switch (preset)
		{
		case 1:
			SetRelightEnhance(true, false, 1, false, true, false, false, false, false, false, false, 4);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 2:
			SetRelightEnhance(true, true, 2, false, true, true, false, false, false, false, false, 10);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 3:
			SetRelightEnhance(true, true, 3, true, true, true, false, false, true, false, true, 12);
			SetBleedGrade(0.92, 1.08, false);
			break;
		case 4:
			SetRelightEnhance(true, true, 3, true, true, true, true, true, true, true, true, 16);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 5:
			SetRelightEnhance(true, true, 2, false, true, false, false, false, false, false, false, 8);
			SetBleedGrade(1.05, 0.92, false);
			break;
		case 6:
			SetRelightEnhance(false, false, 1, false, false, false, false, false, false, false, false, 0);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 7:
			SetRelightEnhance(true, true, 3, false, true, true, true, false, true, false, true, 14);
			SetBleedGrade(0.95, 1.15, true);
			break;
		case 8:
			SetRelightEnhance(true, true, 2, true, true, false, false, false, false, false, false, 6);
			SetBleedGrade(1.02, 0.90, false);
			break;
		case 9:
			SetRelightEnhance(true, true, 2, true, true, false, false, false, false, false, false, 6);
			SetBleedGrade(0.88, 0.82, false);
			break;
		case 10:
			SetRelightEnhance(true, true, 1, false, false, false, false, false, false, false, false, 4);
			SetBleedGrade(1.08, 0.95, false);
			break;
		case 11:
			SetRelightEnhance(true, true, 3, false, true, false, false, false, true, false, false, 10);
			SetBleedGrade(1.0, 1.10, false);
			break;
		case 12:
			SetRelightEnhance(true, true, 2, false, true, true, true, true, true, true, true, 16);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 13:
			SetRelightEnhance(true, true, 2, false, true, true, true, false, true, false, true, 12);
			SetBleedGrade(0.96, 1.04, false);
			break;
		case 14:
			SetRelightEnhance(true, true, 1, false, true, false, false, false, false, false, false, 6);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 15:
			SetRelightEnhance(true, true, 2, false, true, true, false, false, false, false, false, 10);
			SetBleedGrade(1.0, 1.02, false);
			break;
		case 16:
			SetRelightEnhance(true, true, 2, true, true, false, false, false, false, false, false, 6);
			SetBleedGrade(0.90, 0.88, false);
			break;
		case 17:
			SetRelightEnhance(true, true, 2, false, true, false, false, false, false, false, false, 8);
			SetBleedGrade(1.08, 0.85, false);
			break;
		case 18:
			SetRelightEnhance(true, true, 3, false, true, false, false, true, true, false, false, 10);
			SetBleedGrade(1.04, 1.08, false);
			break;
		case 19:
			SetRelightEnhance(true, true, 2, true, true, false, false, false, false, false, false, 8);
			SetBleedGrade(0.94, 0.86, false);
			break;
		case 20:
			SetRelightEnhance(true, true, 2, false, true, true, false, false, false, false, false, 8);
			SetBleedGrade(1.02, 1.04, false);
			break;
		case 22:
			SetRelightEnhance(true, true, 2, false, true, true, false, false, false, false, false, 10);
			SetBleedGrade(1.02, 1.10, false);
			break;
		case 23:
			SetRelightEnhance(true, true, 2, true, true, false, false, false, false, false, false, 4);
			SetBleedGrade(0.90, 0.86, false);
			break;
		case 24:
			SetRelightEnhance(true, true, 2, false, true, true, true, false, true, false, true, 12);
			SetBleedGrade(0.98, 0.92, false);
			break;
		case 25:
			SetRelightEnhance(true, true, 3, true, true, true, true, true, true, true, true, 16);
			SetBleedGrade(0.92, 1.18, true);
			break;
		case 26:
			SetRelightEnhance(true, true, 2, false, true, true, false, false, true, false, false, 12);
			SetBleedGrade(0.98, 1.12, false);
			break;
		case 27:
			SetRelightEnhance(true, true, 3, false, true, true, true, false, true, false, true, 14);
			SetBleedGrade(0.90, 1.20, true);
			break;
		case 28:
			SetRelightEnhance(false, false, 1, false, false, false, false, false, false, false, false, 0);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 29:
			SetRelightEnhance(true, true, 2, false, true, false, false, false, false, false, false, 8);
			SetBleedGrade(1.0, 1.0, false);
			break;
		}
	}

	clearscope static void SetRelightEnhance(bool flats, bool recursive, int recDepth, bool dimBleed, bool smart, bool window, bool texture, bool gldef, bool polylabel, bool wallShadow, bool doors, int procMax)
	{
		SetBool("sss_relight_flats", flats);
		SetBool("sss_relight_recursive", recursive);
		SetInt("sss_relight_rec_depth", recDepth);
		SetBool("sss_relight_dimbleed", dimBleed);
		SetBool("sss_relight_smart", smart);
		SetBool("sss_relight_window", window);
		SetBool("sss_relight_texture", texture);
		SetBool("sss_relight_gldef", gldef);
		SetBool("sss_relight_polylabel", polylabel);
		SetBool("sss_wall_shadows", wallShadow);
		SetBool("sss_relight_doors", doors);
		SetInt("sss_relight_proc_max", procMax);
	}

	clearscope static void SetBleedGrade(double gamma, double saturation, bool rgMode)
	{
		SetFloat("sss_bleed_gamma", gamma);
		SetFloat("sss_bleed_saturation", saturation);
		SetBool("sss_bleed_rg", rgMode);
	}

	clearscope static void ApplyLite()
	{
		SetRTLite(true, 0.12, 1.8, false, 0.0);
		SetWallBake(0.0);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.46);
		SetFloat("sss_brighten", 0.54);
		SetFloat("sss_additive", 0.18);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", false);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.58);
		SetFloat("sss_wall_glow", 0.30);
		SetFloat("sss_flat_lights", 0.38);
		SetInt("sss_flat_light_max", 8);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 14);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", false);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(3, 1, true);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.40);
		SetPostFX(false, 0.0);
		SetFilmGrain(false);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetBool("sss_mfx_lite_single", true);
	}

	clearscope static void ApplyBalanced()
	{
		SetRTLite(true, 0.32, 2.6, true, 0.42);
		SetWallBake(0.32);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.54);
		SetFloat("sss_brighten", 0.46);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.84);
		SetFloat("sss_wall_glow", 0.46);
		SetFloat("sss_flat_lights", 0.64);
		SetInt("sss_flat_light_max", 16);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 26);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.072);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapDefault");
		SetACES(false);
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.58);
		SetPostFX(false, 0.0);
		SetFilmGrain(false);
		SetAOMode(3, true, 0.40);
		SetBleedSource(1);
		SetFluidEnhanced(0.34, 0.24);
		SetDepthProxy(true, 0.58);
		SetBool("sss_mfx_lite_single", true);
	}

	clearscope static void ApplyModern()
	{
		// RT-forward + mild ACES — no bleed/AO/sharpen (PB false-triggers).
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.52);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.38);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 1.02);
		SetFloat("sss_wall_glow", 0.64);
		SetFloat("sss_flat_lights", 0.84);
		SetInt("sss_flat_light_max", 20);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 36);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(3, 4, false, 4, 8);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 1, 0.06, 1.08, 1.04);
		SetFloat("at_sky_soften", 0.90);
		SetMariFXLite(false);
		SetBool("mfx_gradeenable", false);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_lsharpenable", false);
		SetBool("sss_mfx_lite_single", true);
		SetBool("mfx_bssblurenable", false);
		SetBool("mfx_bsssharpenable", false);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.02, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.65);
		SetAtmosphere(true, 0.34, false, 0.0, false, 0.0);
		SetFloat("sss_atmo_haze_tint", 0.72);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyCinematic()
	{
		SetRTLite(true, 0.42, 3.0, true, 0.55);
		SetWallBake(0.48);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.60);
		SetFloat("sss_brighten", 0.40);
		SetFloat("sss_additive", 0.34);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.95);
		SetFloat("sss_wall_glow", 0.52);
		SetFloat("sss_flat_lights", 0.74);
		SetInt("sss_flat_light_max", 18);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 34);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetBool("sss_shadows", true);
		SetBool("sss_shadow_players", true);
		SetBool("sss_shadow_monsters", false);
		SetInt("sss_shadow_interval", 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.088);

		SetDarkDoomProfile(3, 4, true);
		SetFilmic(true, "TonemapCemetery");
		SetACES(false);
		SetMariFXCinematic();
		SetPostFX(true, 0.12, 10);
		SetFilmGrain(true);
		SetAOMode(3, true, 0.40);
		SetBleedSource(0);
		SetFluidEnhanced(0.42, 0.30);
		SetDepthProxy(true, 0.58);
		SetAtmosphere(true, 0.16, true, 0.14, true, 0.009);
	}

	clearscope static void ApplyUltra()
	{
		SetFilmGrain(false);

		SetRTLite(true, 0.48, 3.2, true, 0.58);
		SetWallBake(0.50);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.46);
		SetFloat("sss_brighten", 0.58);
		SetFloat("sss_additive", 0.34);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 1.0);
		SetFloat("sss_wall_glow", 0.64);
		SetFloat("sss_flat_lights", 0.86);
		SetInt("sss_flat_light_max", 20);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 36);
		SetBool("sss_ceilreflections", true);
		SetInt("sss_ceilstrength", 12);
		SetBool("sss_material_reflect", true);
		SetBool("sss_shadows", true);
		SetBool("sss_shadow_players", true);
		SetBool("sss_shadow_monsters", true);
		SetInt("sss_shadow_interval", 2);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.095);

		SetDarkDoomProfile(3, 3, true, 28, 14);
		SetFilmic(true, "TonemapTide");
		SetACES(false);
		SetMariFXUltra();
		SetFloat("mfx_vigmul", 0.26);
		SetBloomBoost(true, 1.0, 100.0, 0.06);
		SetPostFX(true, 0.14, 12);
		SetAOMode(3, true, 0.38);
		SetBleedSource(2);
		SetFluidEnhanced(0.42, 0.30);
		SetDepthProxy(true, 0.58);
		SetAtmosphere(false, 0.0, true, 0.06, true, 0.007);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyTactical()
	{
		// Operator: mild ACES Narkowicz lift + desaturated MariFX (not full Photoreal HDR).
		SetRTLite(true, 0.36, 2.8, false, 0.0);
		SetWallBake(0.44);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.56);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.88);
		SetFloat("sss_wall_glow", 0.50);
		SetFloat("sss_flat_lights", 0.76);
		SetInt("sss_flat_light_max", 20);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 38);
		SetBool("sss_ceilreflections", true);
		SetInt("sss_ceilstrength", 14);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.040);

		SetDarkDoomProfile(3, 3, true, 4, 4);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 1, 0.12, 1.03, 1.0);
		SetFloat("at_sky_soften", 0.78);
		SetMariFXTactical();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.01, 100.0, 0.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetAtmosphere(true, 0.05, false, 0.0, false, 0.0);
		// Clean digital bodycam: low rolling/noise, mild barrel, lighter overlay vig.
		SetBodyCamToggleStyle(true, true, "OP-TAC1", 0.002, 0.010, 1.04, 0.97, 0.05, 0.040, 0.20, 0.55);
	}

	clearscope static void ApplyArena()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.0);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.42);
		SetFloat("sss_brighten", 0.58);
		SetFloat("sss_additive", 0.18);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", true);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.62);
		SetFloat("sss_wall_glow", 0.34);
		SetFloat("sss_flat_lights", 0.42);
		SetInt("sss_flat_light_max", 10);
		SetBool("sss_floorreflections", false);
		SetInt("sss_floorstrength", 0);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", false);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(0, 0, true);
		SetInt("ddz_postgain", 18);
		SetFilmic(false, "TonemapArena");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXArena();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(1);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetBool("sss_mfx_lite_single", true);
	}

	clearscope static void ApplyNeonHell()
	{
		SetRTLite(true, 0.38, 3.0, true, 0.52);
		SetWallBake(0.40);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.32);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 1.0);
		SetFloat("sss_wall_glow", 0.56);
		SetFloat("sss_flat_lights", 0.80);
		SetInt("sss_flat_light_max", 18);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 32);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.105);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapSalvation");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXNeon();
		SetPostFXEx(true, 0.14, false, 0.0, 10);
		SetFilmGrain(false);
		SetBloomBoost(true, 0.95, 110.0, 2.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(0);
		SetFluidEnhanced(0.48, 0.38);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.82);
	}

	clearscope static void ApplyColdSector()
	{
		SetRTLite(true, 0.44, 3.2, false, 0.0);
		SetWallBake(0.52);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.72);
		SetFloat("sss_wall_glow", 0.48);
		SetFloat("sss_flat_lights", 0.58);
		SetInt("sss_flat_light_max", 14);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 22);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.038);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapSnow");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXCold();
		SetSoftShade(true, 0.04);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(3, true, 0.38);
		SetBleedSource(1);
		SetFluidEnhanced(0.35, 0.25);
		SetDepthProxy(true, 0.55);
		SetAtmosphere(true, 0.14, false, 0.0, true, 0.010);
	}

	clearscope static void ApplyFoundFootage()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.38);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.52);
		SetFloat("sss_brighten", 0.48);
		SetFloat("sss_additive", 0.28);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.70);
		SetFloat("sss_wall_glow", 0.40);
		SetFloat("sss_flat_lights", 0.50);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 20);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.058);

		SetDarkDoomProfile(0, 2, true);
		SetInt("ddz_postgain", 14);
		SetInt("ddz_minlight", 8);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXFoundFootage();
		SetSoftShade(false, 0.0);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBool("dpwh_chromaticAberration2", false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(2);
		SetFluidEnhanced(0.18, 0.12);
		SetDepthProxy(false, 0.0);
		SetNaturalVignette(true, 0.22, 0.52);
		SetAtmosphere(false, 0.0, false, 0.0, true, 0.009);
		SetBodyCamToggleStyle(true, true, "FF-CAM1", 0.005, 0.042, 1.00, 0.88, 0.14, 0.082);
	}

	clearscope static void ApplyRetroTerminal()
	{
		// Alien: Isolation — Sevastopol CRT terminals, green phosphor, industrial dark.
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.30);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.24);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.58);
		SetFloat("sss_wall_glow", 0.32);
		SetFloat("sss_flat_lights", 0.38);
		SetInt("sss_flat_light_max", 8);
		SetBool("sss_floorreflections", false);
		SetInt("sss_floorstrength", 0);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", false);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(2, 4, true);
		SetInt("ddz_postgain", 3);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetScreenMAlienTerminal();
		SetSoftShade(false, 0.0);
		SetMariFXAlienTerminal();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBool("dpwh_chromaticAberration2", true);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetNaturalVignette(true, 0.14, 0.52);
		SetAtmosphere(false, 0.0, false, 0.0, true, 0.008);
		SetBool("sss_mfx_lite_single", true);
	}

	clearscope static void ApplyPainterly()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.18);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.46);
		SetFloat("sss_brighten", 0.54);
		SetFloat("sss_additive", 0.18);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.78);
		SetFloat("sss_wall_glow", 0.42);
		SetFloat("sss_flat_lights", 0.58);
		SetInt("sss_flat_light_max", 14);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 24);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.075);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapPlaza");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXPainterly();
		SetSoftShade(true, 0.03);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(1);
		SetFluidEnhanced(0.28, 0.20);
		SetDepthProxy(false, 0.0);
	}

	clearscope static void ApplyPhotoreal()
	{
		SetRTLite(true, 0.36, 2.8, false, 0.0);
		SetWallBake(0.52);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.50);
		SetFloat("sss_brighten", 0.50);
		SetFloat("sss_additive", 0.28);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.94);
		SetFloat("sss_wall_glow", 0.58);
		SetFloat("sss_flat_lights", 0.82);
		SetInt("sss_flat_light_max", 20);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 38);
		SetBool("sss_ceilreflections", true);
		SetInt("sss_ceilstrength", 14);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.040);

		SetDarkDoomProfile(3, 2, true, 14, 10);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 0, 0.03, 1.03, 1.0);
		SetFloat("at_sky_soften", 0.94);
		SetMariFXPhotoreal();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetAtmosphere(true, 0.08, false, 0.0, false, 0.0);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyVanillaPlus()
	{
		SetRTLite(true, 0.10, 1.8, true, 0.18);
		SetWallBake(0.10);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.44);
		SetFloat("sss_brighten", 0.58);
		SetFloat("sss_additive", 0.16);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.56);
		SetFloat("sss_wall_glow", 0.28);
		SetFloat("sss_flat_lights", 0.38);
		SetInt("sss_flat_light_max", 8);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 12);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", false);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(3, 1, true);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.36);
		SetBool("mfx_gradeenable", false);
		SetBool("mfx_vigenable", false);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetFluidEnhanced(0.18, 0.12);
		SetDepthProxy(false, 0.0);
		SetBool("sss_mfx_lite_single", true);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyOvercastOutdoor()
	{
		SetRTLite(true, 0.30, 2.6, true, 0.40);
		SetWallBake(0.30);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.52);
		SetFloat("sss_brighten", 0.48);
		SetFloat("sss_additive", 0.26);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.78);
		SetFloat("sss_wall_glow", 0.42);
		SetFloat("sss_flat_lights", 0.58);
		SetInt("sss_flat_light_max", 16);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 28);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.055);

		SetDarkDoomProfile(3, 2, true);
		SetFilmic(true, "TonemapArena");
		SetACES(false);
		SetMariFXLite(true);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(3, true, 0.38);
		SetBleedSource(1);
		SetFluidEnhanced(0.34, 0.24);
		SetDepthProxy(true, 0.58);
		SetAtmosphere(true, 0.14, true, 0.12, false, 0.0);
	}

	clearscope static void ApplyGothicIndoor()
	{
		SetRTLite(true, 0.34, 2.8, false, 0.0);
		SetWallBake(0.48);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.62);
		SetFloat("sss_brighten", 0.38);
		SetFloat("sss_additive", 0.34);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.68);
		SetFloat("sss_wall_glow", 0.44);
		SetFloat("sss_flat_lights", 0.52);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 20);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.048);

		SetDarkDoomProfile(3, 6, true);
		SetInt("ddz_postgain", 0);
		SetInt("ddz_minlight", 0);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXGothic();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(3, true, 0.40);
		SetBleedSource(1);
		SetFluidEnhanced(0.18, 0.12);
		SetDepthProxy(true, 0.55);
		SetNaturalVignette(true, 0.25, 0.48);
		SetAtmosphere(false, 0.0, false, 0.0, true, 0.010);
	}

	clearscope static void ApplyNoirOperator()
	{
		SetRTLite(true, 0.32, 2.6, false, 0.0);
		SetWallBake(0.32);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.72);
		SetFloat("sss_wall_glow", 0.40);
		SetFloat("sss_flat_lights", 0.54);
		SetInt("sss_flat_light_max", 14);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 24);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.062);

		SetDarkDoomProfile(3, 5, true);
		SetBodyCamToggleStyle(true, true, "NOIR-01", 0.005, 0.038, 1.02, 0.86, 0.12, 0.078);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 1, 1.4, 1.0, 0.88);
		SetMariFXNoir();
		SetPostFXEx(false, 0.0, true, 22.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 0.98, 108.0, 0.0);
		SetAOMode(3, true, 0.38);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.22, 0.15);
		SetDepthProxy(true, 0.60);
	}

	clearscope static void ApplyHereticHaven()
	{
		SetRTLite(true, 0.28, 2.5, true, 0.48);
		SetWallBake(0.34);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.38);
		SetFloat("sss_brighten", 0.62);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.98);
		SetFloat("sss_wall_glow", 0.60);
		SetFloat("sss_flat_lights", 0.76);
		SetInt("sss_flat_light_max", 18);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 30);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.068);

		SetDarkDoomProfile(2, 1, true);
		SetInt("ddz_postgain", 16);
		SetFilmic(true, "TonemapPlaza");
		SetACES(false);
		SetMariFXHeretic();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 102.0, 0.5);
		SetAOMode(3, true, 0.32);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.42, 0.32);
		SetDepthProxy(true, 0.48);
		SetAtmosphere(true, 0.24, false, 0.0, false, 0.0);
		SetFloat("sss_atmo_haze_tint", 0.30);
		SetBool("sss_mfx_lite_single", false);
	}

	clearscope static void ApplyHexenCrypt()
	{
		SetRTLite(true, 0.38, 2.9, false, 0.0);
		SetWallBake(0.50);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.64);
		SetFloat("sss_brighten", 0.36);
		SetFloat("sss_additive", 0.34);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.68);
		SetFloat("sss_wall_glow", 0.40);
		SetFloat("sss_flat_lights", 0.48);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 18);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.044);

		SetDarkDoomProfile(3, 6, true);
		SetInt("ddz_postgain", 0);
		SetInt("ddz_minlight", 0);
		SetFilmic(true, "TonemapCemetery");
		SetACES(false);
		SetMariFXHexen();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(3, true, 0.44);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.14, 0.10);
		SetDepthProxy(true, 0.58);
		SetAtmosphere(false, 0.0, false, 0.0, true, 0.012);
		SetNaturalVignette(true, 0.18, 0.55);
	}

	clearscope static void ApplyCoopReady()
	{
		SetRTLite(false, 0.0, 2.0, true, 0.38);
		SetWallBake(0.26);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.50);
		SetFloat("sss_brighten", 0.50);
		SetFloat("sss_additive", 0.26);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.76);
		SetFloat("sss_wall_glow", 0.40);
		SetFloat("sss_flat_lights", 0.56);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 24);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.052);

		SetDarkDoomProfile(3, 1, true);
		SetInt("ddz_postgain", 10);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXCoop();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(1);
		SetFluidEnhanced(0.36, 0.26);
		SetDepthProxy(false, 0.0);
		SetBool("sss_mfx_lite_single", true);
	}

	clearscope static void ApplyGoldenHour()
	{
		SetRTLite(true, 0.28, 2.5, true, 0.44);
		SetWallBake(0.32);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.50);
		SetFloat("sss_brighten", 0.50);
		SetFloat("sss_additive", 0.26);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.84);
		SetFloat("sss_wall_glow", 0.44);
		SetFloat("sss_flat_lights", 0.62);
		SetInt("sss_flat_light_max", 16);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 28);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.065);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapPlaza");
		SetACES(false);
		SetMariFXHeretic();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 102.0, 1.0);
		SetAOMode(3, true, 0.34);
		SetBleedSource(1);
		SetFluidEnhanced(0.36, 0.26);
		SetDepthProxy(true, 0.52);
		SetAtmosphere(true, 0.18, true, 0.10, false, 0.0);
		SetFloat("sss_atmo_haze_tint", 0.22);
	}

	clearscope static void ApplyLiminal()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.34);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.56);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.28);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.66);
		SetFloat("sss_wall_glow", 0.38);
		SetFloat("sss_flat_lights", 0.48);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 18);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.046);

		SetDarkDoomProfile(3, 5, true);
		SetInt("ddz_postgain", 0);
		SetInt("ddz_minlight", 0);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXLiminal();
		SetSoftShade(true, 0.065);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(1);
		SetFluidEnhanced(0.14, 0.10);
		SetDepthProxy(false, 0.0);
		SetNaturalVignette(true, 0.36, 0.48);
		SetAtmosphere(true, 0.28, false, 0.0, true, 0.010);
		SetFloat("sss_atmo_haze_tint", 0.78);
	}

	clearscope static void ApplyStormyAtmosphere()
	{
		SetRTLite(true, 0.36, 2.8, false, 0.0);
		SetWallBake(0.44);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.70);
		SetFloat("sss_wall_glow", 0.48);
		SetFloat("sss_flat_lights", 0.54);
		SetInt("sss_flat_light_max", 14);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 18);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.045);

		SetDarkDoomProfile(3, 4, true);
		SetFilmic(true, "TonemapSnow");
		SetACES(false);
		SetMariFXStormy();
		SetSoftShade(false, 0.0);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(3, true, 0.40);
		SetBleedSource(1);
		SetFluidEnhanced(0.24, 0.16);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.55);
		SetAtmosphere(true, 0.26, true, 0.14, true, 0.012);
		SetFloat("sss_atmo_haze_tint", 0.62);
	}

	clearscope static void ApplyUltraviolence()
	{
		SetRTLite(true, 0.44, 3.2, true, 0.55);
		SetWallBake(0.42);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.36);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 1.0);
		SetFloat("sss_wall_glow", 0.56);
		SetFloat("sss_flat_lights", 0.82);
		SetInt("sss_flat_light_max", 20);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 36);
		SetBool("sss_ceilreflections", true);
		SetInt("sss_ceilstrength", 14);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, true, 2);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.110);

		SetBalancedDarkDoom();
		SetInt("ddz_postgain", 10);
		SetFilmic(true, "TonemapSalvation");
		SetACESConfig(true, 1, 0.02, 1.06, 1.0);
		SetFloat("at_sky_soften", 0.93);
		SetMariFXNeon();
		SetMariFXRedAccent(0.10);
		SetPostFXEx(false, 0.0, true, 10.0, 8);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 106.0, 0.8);
		SetAOMode(3, true, 0.40);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFloat("sss_bleeding", 0.072);
		SetFluidEnhanced(0.42, 0.30);
		SetDepthProxy(true, 0.58);
		SetAtmosphere(false, 0.0, false, 0.0, false, 0.0);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyVaporwave()
	{
		SetRTLite(true, 0.32, 2.8, true, 0.46);
		SetWallBake(0.34);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.54);
		SetFloat("sss_brighten", 0.46);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.88);
		SetFloat("sss_wall_glow", 0.48);
		SetFloat("sss_flat_lights", 0.68);
		SetInt("sss_flat_light_max", 16);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 30);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.085);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapPlaza");
		SetACES(false);
		SetMariFXVaporwave();
		SetPostFXEx(true, 0.10, false, 0.0, 10);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 108.0, 2.0);
		SetAOMode(2, false, 0.0);
		SetBleedSource(1);
		SetFluidEnhanced(0.40, 0.30);
		SetDepthProxy(false, 0.0);
	}

	clearscope static void ApplyBrutalCarnage()
	{
		SetRTLite(true, 0.38, 3.0, true, 0.50);
		SetWallBake(0.38);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.58);
		SetFloat("sss_brighten", 0.42);
		SetFloat("sss_additive", 0.34);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.98);
		SetFloat("sss_wall_glow", 0.52);
		SetFloat("sss_flat_lights", 0.78);
		SetInt("sss_flat_light_max", 18);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 30);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.115);

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapSalvation");
		SetFloat("at_sky_soften", 0.91);
		SetACES(false);
		SetMariFXBrutal();
		SetMariFXRedAccent(0.12);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 106.0, 0.6);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFloat("sss_bleeding", 0.088);
		SetFluidEnhanced(0.44, 0.34);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.82);
	}

	clearscope static void ApplySoftwareNostalgia()
	{
		// Classic software-renderer nostalgia — SoftShade dither, warm PLAYPAL, no CRT stack.
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.0);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.42);
		SetFloat("sss_brighten", 0.58);
		SetFloat("sss_additive", 0.14);
		SetBool("sss_smooth_walls", false);
		SetBool("sss_performance", true);
		SetBool("sss_color_sec", false);
		SetBool("sss_color_walls", false);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.54);
		SetFloat("sss_wall_glow", 0.26);
		SetFloat("sss_flat_lights", 0.30);
		SetInt("sss_flat_light_max", 6);
		SetBool("sss_floorreflections", false);
		SetInt("sss_floorstrength", 0);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", false);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetDarkDoomProfile(0, 0, true);
		SetInt("ddz_postgain", 14);
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetScreenMRetro();
		SetSoftShade(true, 0.058);
		SetMariFXSoftwareNostalgia();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetAOMode(0, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.0, 0.0);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.24);
		SetBool("sss_mfx_lite_single", true);
		SetBodyCamAnalog(false, false);
	}

	clearscope static void ApplyVRComfort()
	{
		SetRTLite(true, 0.20, 2.1, true, 0.28);
		SetWallBake(0.20);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.50);
		SetFloat("sss_brighten", 0.50);
		SetFloat("sss_additive", 0.20);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.68);
		SetFloat("sss_wall_glow", 0.34);
		SetFloat("sss_flat_lights", 0.46);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 18);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetBalancedDarkDoom();
		SetInt("ddz_postgain", 10);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 1, 1.0, 1.0, 1.0);
		SetFloat("at_sky_soften", 0.94);
		SetMariFXVRComfort();
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
		SetBool("dpwh_chromaticAberration2", false);
		SetBool("fisheye_enabled", false);
		SetBool("dpwh_naturalVignette2", false);
		SetAOMode(2, false, 0.0);
		SetBleedSource(2);
		SetBool("sss_bleed_rg", false);
		SetFluidEnhanced(0.22, 0.14);
		SetDepthProxy(false, 0.0);
		SetBool("sss_mfx_lite_single", true);
		SetFloat("sss_pp_flat_soften", 0.18);
	}

	clearscope static void SetRTLite(bool contact, double contactStr, double contactRad, bool fluidSSR, double fluidStr)
	{
		SetBool("sss_contactao", contact);
		SetFloat("sss_contactao_strength", contactStr);
		SetFloat("sss_contactao_radius", contactRad);
		SetBool("sss_fluidssr", fluidSSR);
		SetFloat("sss_fluidssr_strength", fluidStr);
	}

	clearscope static void SetWallBake(double amount)
	{
		SetFloat("sss_wall_bake", amount);
	}

	clearscope static void SetDarkDoom(int mode, int preset, bool reliteSync)
	{
		SetInt("ddz_mode", mode);
		SetInt("ddz_preset", preset);
		SetBool("sss_darkdoom_relite_sync", reliteSync);
	}

	clearscope static void SetDarkDoomProfile(int mode, int preset, bool reliteSync, int postGain = 0, int minLight = 0)
	{
		SetDarkDoom(mode, preset, reliteSync);
		SetInt("ddz_postgain", postGain);
		SetInt("ddz_minlight", minLight);
	}

	clearscope static void SetBodyCamLook(bool on, int mode = 0, double chroma = 0.005, double noise = 0.035,
		double contrast = 1.00, double saturation = 0.90, double rolling = 0.20, bool overlay = false)
	{
		SetBool("sss_bodycam_active", on);
		let active = CVar.FindCVar("sss_bodycam_active");
		if (active)
			active.SetBool(on);
		let modeLive = CVar.FindCVar("sss_bodycam_mode_live");
		if (modeLive)
			modeLive.SetInt(on ? mode : 0);
		SetMirrorFloat("sss_bodycam_chroma_live", chroma);
		SetMirrorFloat("sss_bodycam_noise_live", noise);
		SetMirrorFloat("sss_bodycam_contrast_live", contrast);
		SetMirrorFloat("sss_bodycam_saturation_live", saturation);
		SetMirrorFloat("sss_bodycam_rolling_live", rolling);
		SetMirrorBool("sss_bodycam_overlay_live", overlay);
		SetMirrorFloat("sss_bodycam_vig_live", on ? 0.34 : 0.0);
		SetMirrorFloat("sss_bodycam_vig_fall_live", on ? 0.64 : 0.50);
		SetInt("sss_bodycam_mode", mode);
		SetFloat("sss_bodycam_chroma", chroma);
		SetFloat("sss_bodycam_noise", noise);
		SetFloat("sss_bodycam_contrast", contrast);
		SetFloat("sss_bodycam_saturation", saturation);
		SetFloat("sss_bodycam_rolling", rolling);
		SetBool("sss_bodycam_overlay", overlay);
	}

	// Analog VHS — menu/advanced only; presets should use SetBodyCamToggleStyle.
	clearscope static void SetBodyCamAnalog(bool on, bool overlay, double fishStr = 0.015,
		double vhsNoise = 0.001, double vhsOffset = 0.002, double lineCount = 250.0)
	{
		SetBodyCamLook(on, 1, 0.005, 0.035, 1.00, 0.90, 0.20, overlay);
		SetBool("SH_ShaderEnable", on);
		SetBool("SH_VHSEnable", on);
		if (on)
		{
			SetFloat("SH_VHSLineCount", lineCount);
			SetFloat("SH_VHSNoiseIntensity", vhsNoise);
			SetFloat("SH_VHSNoiseQuality", 300.0);
			SetFloat("SH_VHSOffsetIntensity", vhsOffset);
			SetFloat("SH_VHSRange", 0.05);
			SetBool("fisheye_enabled", true);
			SetBool("fisheye_chromatic", true);
			SetFloat("fisheye_strength", fishStr);
			let fl = CVar.FindCVar("sss_bodycam_fish_live");
			if (fl) fl.SetFloat(fishStr);
			let vn = CVar.FindCVar("sss_bodycam_vhs_noise_live");
			if (vn) vn.SetFloat(vhsNoise);
			let vo = CVar.FindCVar("sss_bodycam_vhs_offset_live");
			if (vo) vo.SetFloat(vhsOffset);
			let vl = CVar.FindCVar("sss_bodycam_vhs_lines_live");
			if (vl) vl.SetFloat(lineCount);
			let vr = CVar.FindCVar("sss_bodycam_vhs_range_live");
			if (vr) vr.SetFloat(0.05);
		}
	}

	clearscope static void SetBodyCamDigital(bool on, bool overlay, double chroma = 0.005,
		double noise = 0.035, double contrast = 1.00, double saturation = 0.90, double rolling = 0.20)
	{
		SetBodyCamLook(on, 0, chroma, noise, contrast, saturation, rolling, overlay);
		SetBool("SH_ShaderEnable", false);
		SetBool("SH_VHSEnable", false);
		SetBool("fisheye_enabled", on);
		if (on)
		{
			SetBool("fisheye_chromatic", chroma > 0.001);
		}
	}

	// Preset bodycam — same stack as the B-key toggle (digital + mild fisheye).
	clearscope static void SetBodyCamToggleStyle(bool on, bool overlay, String unit = "",
		double chroma = 0.005, double noise = 0.035, double contrast = 1.00,
		double saturation = 0.90, double rolling = 0.20, double barrel = 0.080,
		double vigStrength = 0.34, double vigFalloff = 0.64)
	{
		SetBodyCamDigital(on, overlay, chroma, noise, contrast, saturation, rolling);
		if (unit.Length() > 0)
			SetString("sss_bodycam_unit", unit);
		if (on)
		{
			SetFloat("sss_bodycam_barrel", barrel);
			double fish = clamp(barrel * 0.85, 0.012, 0.12);
			SetFloat("fisheye_strength", fish);
			SetBool("fisheye_chromatic", chroma > 0.001);
			let fl = CVar.FindCVar("sss_bodycam_fish_live");
			if (fl) fl.SetFloat(fish);
			SetMirrorFloat("sss_bodycam_vig_live", vigStrength);
			SetMirrorFloat("sss_bodycam_vig_fall_live", vigFalloff);
		}
	}

	clearscope static void SetMariFXRedAccent(double strength = 0.08)
	{
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", strength);
		SetFloat("mfx_gradecol_r", 0.14);
		SetFloat("mfx_gradecol_g", -0.04);
		SetFloat("mfx_gradecol_b", -0.08);
		SetFloat("mfx_gradesatmul", 1.06);
	}

	// Default quality baseline: Clamp + Dismal. Many presets override via SetDarkDoomProfile.
	clearscope static void SetBalancedDarkDoom()
	{
		SetDarkDoom(3, 3, true);
		SetInt("ddz_postgain", 0);
		SetInt("ddz_minlight", 0);
	}

	clearscope static void SetFilmic(bool on, String lut)
	{
		SetBool("dpwh_filmictonemap2", on);
		SetString("dsc_scene_lut2", lut);
	}

	clearscope static void SetACES(bool on)
	{
		SetBool("at_enabled", on);
	}

	clearscope static void SetMariFXLite(bool on)
	{
		SetBool("mfx_lsharpenable", on);
		SetFloat("mfx_lsharpradius", 0.8);
		SetFloat("mfx_lsharpclamp", 0.05);
		SetFloat("mfx_lsharpblend", 0.65);
		SetBool("mfx_bssshiftenable", false);
		SetBool("mfx_bssblurenable", on && !GetCVarForApply("sss_mfx_lite_single").GetBool());
		SetFloat("mfx_bssblurradius", 0.12);
		SetBool("mfx_bsssharpenable", on && !GetCVarForApply("sss_mfx_lite_single").GetBool());
		SetBool("mfx_techenable", false);
		SetFloat("mfx_techblend", 0.0);
		SetBool("mfx_gradeenable", false);
		SetFloat("mfx_gradecolfact", 0.0);
		SetFloat("mfx_gradesatmul", 1.0);
		SetFloat("mfx_gradecol_r", 0.0);
		SetFloat("mfx_gradecol_g", 0.0);
		SetFloat("mfx_gradecol_b", 0.0);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
		SetBool("mfx_cmatenable", false);
	}

	clearscope static void SetMariFXModern()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.32);
		SetBool("sss_mfx_lite_single", true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 1.0);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.28);
		SetBool("mfx_ne", false);
	}

	// Photoreal: ACES owns grade — no MariFX grade/sharpen (prevents HDR sky crawl).
	clearscope static void SetMariFXPhotoreal()
	{
		SetMariFXLite(true);
		SetBool("mfx_lsharpenable", false);
		SetBool("mfx_bssblurenable", false);
		SetBool("mfx_bsssharpenable", false);
		SetBool("sss_mfx_lite_single", true);
		SetBool("mfx_gradeenable", false);
		SetFloat("mfx_gradecolfact", 0.0);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.20);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXCinematic()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.08);
		SetFloat("mfx_gradesatmul", 1.05);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.35);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXUltra()
	{
		SetMariFXCinematic();
		SetFloat("mfx_gradecolfact", 0.10);
		SetFloat("mfx_vigmul", 0.38);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetPostFX(bool lens, double lensAmount, int lensSamples = 12)
	{
		SetPostFXEx(lens, lensAmount, false, 0.0, lensSamples);
	}

	clearscope static void SetPostFXEx(bool lens, double lensAmount, bool vig, double vigIntensity, int lensSamples = 12)
	{
		SetBool("tc_pp_lensflares", lens);
		SetFloat("tc_pp_lensflares_amount", lensAmount);
		SetInt("tc_pp_lensflares_samples", lensSamples);
		SetBool("tc_pp_vignette", vig);
		SetFloat("tc_pp_vignette_intensity", vigIntensity);
		SetBool("tc_pp_noise", false);
	}

	clearscope static void SetFilmGrain(bool on)
	{
		SetBool("dpwh_filmgrain2", on);
		if (!on)
		{
			SetBool("mfx_ne", false);
			SetFloat("mfx_ni", 0.0);
		}
	}

	clearscope static void SetShadows(bool on, bool players, bool monsters, int interval)
	{
		SetBool("sss_shadows", on);
		SetBool("sss_shadow_players", players);
		SetBool("sss_shadow_monsters", monsters);
		SetInt("sss_shadow_interval", interval);
	}

	clearscope static void SetACESConfig(bool on, int acesMode, double crosstalk, double exposure, double saturation)
	{
		SetBool("at_enabled", on);
		SetInt("at_aces_mode", acesMode);
		SetFloat("at_Crosstalk", crosstalk);
		SetFloat("at_exposure_bias", exposure);
		SetFloat("at_Saturation", saturation);
		SetFloat("at_CrossSaturation", 1.0);
	}

	clearscope static void SetBloomBoost(bool on, double gamma, double contrast, double brightness)
	{
		SetBool("gl_bloomboost", on);
		SetFloat("gl_bloomboost_gamma", gamma);
		SetFloat("gl_bloomboost_contrast", contrast);
		SetFloat("gl_bloomboost_brightness", brightness);
	}

	clearscope static void SetSoftShade(bool on, double dither)
	{
		SetBool("db_softshade_enabled", on);
		SetFloat("db_softshade_dither", dither);
		SetBool("db_softshade_doscale", true);
	}

	clearscope static void SetScreenMRetro()
	{
		SetBool("gl_screem", true);
		SetFloat("gl_screem_oldpallut", 45.0);
		SetFloat("gl_screem_ybias", 1.0);
		SetInt("gl_screem_wide", 0);
		SetInt("gl_screem_res_mode", 0);
		SetInt("gl_screem_res_detail", 2);
		SetBool("gl_screem_tonecontrols", false);
		SetBool("gl_screem_phosphor", true);
		SetFloat("gl_screem_phosphor_amount", 35.0);
		SetFloat("gl_screem_phosphor_residue", 18.0);
		SetInt("gl_screem_grillmode", 1);
		SetFloat("gl_screem_grilldepth", 12.0);
		SetInt("gl_screem_tempmode", 2);
		SetFloat("gl_screem_kelvin", 320.0);
	}

	// Alien: Isolation — MOTHER-style green phosphor CRT, scanlines, cool industrial grade.
	clearscope static void SetScreenMAlienTerminal()
	{
		SetBool("gl_screem", true);
		SetFloat("gl_screem_oldpallut", 26.0);
		SetFloat("gl_screem_ybias", 1.02);
		SetInt("gl_screem_wide", 0);
		SetInt("gl_screem_res_mode", 0);
		SetInt("gl_screem_res_detail", 3);
		SetBool("gl_screem_tonecontrols", true);
		SetFloat("gl_screem_gamma", 1.06);
		SetFloat("gl_screem_brightness", 5.0);
		SetFloat("gl_screem_contrast", 112.0);
		SetFloat("gl_screem_saturation", 66.0);
		SetBool("gl_screem_phosphor", true);
		SetFloat("gl_screem_phosphor_amount", 12.0);
		SetFloat("gl_screem_phosphor_residue", 6.0);
		SetInt("gl_screem_grillmode", 1);
		SetFloat("gl_screem_grilldepth", 5.5);
		SetInt("gl_screem_tempmode", 2);
		SetFloat("gl_screem_kelvin", 2200.0);
	}

	clearscope static void SetSpecialtyOff()
	{
		SetBool("gl_screem", false);
		SetSoftShade(false, 0.05);
		SetBool("dpwh_chromaticAberration2", false);
		SetBool("dpwh_naturalVignette2", false);
		SetAtmosphere(false, 0.0, false, 0.0, false, 0.0);
		SetBool("fisheye_enabled", false);
		SetBool("SH_VHSEnable", false);
		SetBool("SH_ShaderEnable", false);
		SetBodyCamLook(false);
		SetBool("sss_bleed_rg", false);
		SetDepthProxy(false, 0.0);
		SetFloat("sss_pp_flat_soften", 0.65);
		SetFloat("sss_atmo_haze_tint", 0.50);
		SetBool("mfx_cmatenable", false);
		SetBool("mfx_hsenable", false);
		SetBool("mfx_lutenable", false);
		SetBool("mfx_techenable", false);
		SetFloat("mfx_techblend", 0.0);
		SetFloat("mfx_cmat_rr", 1.0);
		SetFloat("mfx_cmat_rg", 0.0);
		SetFloat("mfx_cmat_rb", 0.0);
		SetFloat("mfx_cmat_gr", 0.0);
		SetFloat("mfx_cmat_gg", 1.0);
		SetFloat("mfx_cmat_gb", 0.0);
		SetFloat("mfx_cmat_br", 0.0);
		SetFloat("mfx_cmat_bg", 0.0);
		SetFloat("mfx_cmat_bb", 1.0);
	}

	clearscope static void SetMariFXTactical()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.50);
		SetBool("sss_mfx_lite_single", true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.05);
		SetFloat("mfx_gradesatmul", 0.94);
		SetFloat("mfx_gradecol_r", 0.0);
		SetFloat("mfx_gradecol_g", 0.0);
		SetFloat("mfx_gradecol_b", 0.0);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.26);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXArena()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.22);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.03);
		SetFloat("mfx_gradesatmul", 1.12);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXCoop()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.04);
		SetFloat("mfx_gradesatmul", 1.06);
		SetFloat("mfx_gradecol_r", 0.02);
		SetFloat("mfx_gradecol_g", 0.02);
		SetFloat("mfx_gradecol_b", 0.0);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXStormy()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.14);
		SetFloat("mfx_gradesatmul", 0.86);
		SetFloat("mfx_gradecol_r", -0.10);
		SetFloat("mfx_gradecol_g", 0.0);
		SetFloat("mfx_gradecol_b", 0.16);
		SetBool("mfx_cmatenable", true);
		SetFloat("mfx_cmat_rr", 0.92);
		SetFloat("mfx_cmat_rg", 0.0);
		SetFloat("mfx_cmat_rb", 0.0);
		SetFloat("mfx_cmat_gr", 0.0);
		SetFloat("mfx_cmat_gg", 0.96);
		SetFloat("mfx_cmat_gb", 0.0);
		SetFloat("mfx_cmat_br", 0.0);
		SetFloat("mfx_cmat_bg", 0.0);
		SetFloat("mfx_cmat_bb", 1.08);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.18);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXAlienTerminal()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.48);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.11);
		SetFloat("mfx_gradesatmul", 0.76);
		SetFloat("mfx_gradecol_r", -0.14);
		SetFloat("mfx_gradecol_g", 0.16);
		SetFloat("mfx_gradecol_b", -0.08);
		SetBool("mfx_cmatenable", true);
		SetFloat("mfx_cmat_rr", 0.88);
		SetFloat("mfx_cmat_rg", 0.05);
		SetFloat("mfx_cmat_rb", 0.02);
		SetFloat("mfx_cmat_gr", 0.08);
		SetFloat("mfx_cmat_gg", 1.04);
		SetFloat("mfx_cmat_gb", 0.05);
		SetFloat("mfx_cmat_br", 0.02);
		SetFloat("mfx_cmat_bg", 0.06);
		SetFloat("mfx_cmat_bb", 0.90);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.20);
		SetBool("mfx_ne", true);
		SetFloat("mfx_ni", 0.034);
		SetFloat("mfx_ns", 0.0);
	}

	clearscope static void SetMariFXSoftwareNostalgia()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.26);
		SetFloat("mfx_lsharpradius", 0.65);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.05);
		SetFloat("mfx_gradesatmul", 0.96);
		SetFloat("mfx_gradecol_r", 0.06);
		SetFloat("mfx_gradecol_g", 0.04);
		SetFloat("mfx_gradecol_b", -0.03);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
		SetBool("mfx_cmatenable", false);
	}

	clearscope static void SetMariFXNeon()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", true);
		SetFloat("mfx_techblend", 0.55);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 1.15);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.30);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXCold()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.12);
		SetFloat("mfx_gradesatmul", 0.92);
		SetFloat("mfx_gradecol_r", -0.08);
		SetFloat("mfx_gradecol_g", 0.02);
		SetFloat("mfx_gradecol_b", 0.12);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXFoundFootage()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 0.72);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.48);
		SetBool("mfx_ne", true);
		SetFloat("mfx_ni", 0.14);
		SetFloat("mfx_ns", 0.0);
	}

	clearscope static void SetMariFXPainterly()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", true);
		SetFloat("mfx_techblend", 0.25);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.04);
		SetFloat("mfx_gradesatmul", 1.08);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXNoir()
	{
		SetMariFXLite(true);
		SetBool("mfx_cmatenable", true);
		SetFloat("mfx_cmat_rr", 1.25);
		SetFloat("mfx_cmat_rg", 0.08);
		SetFloat("mfx_cmat_rb", 0.08);
		SetFloat("mfx_cmat_gr", 0.15);
		SetFloat("mfx_cmat_gg", 0.35);
		SetFloat("mfx_cmat_gb", 0.10);
		SetFloat("mfx_cmat_br", 0.10);
		SetFloat("mfx_cmat_bg", 0.10);
		SetFloat("mfx_cmat_bb", 0.35);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.04);
		SetFloat("mfx_gradesatmul", 0.82);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.32);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXGothic()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.08);
		SetFloat("mfx_gradesatmul", 0.78);
		SetFloat("mfx_gradecol_r", -0.04);
		SetFloat("mfx_gradecol_g", -0.02);
		SetFloat("mfx_gradecol_b", -0.06);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXHeretic()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", true);
		SetFloat("mfx_techblend", 0.30);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.10);
		SetFloat("mfx_gradesatmul", 1.14);
		SetFloat("mfx_gradecol_r", 0.12);
		SetFloat("mfx_gradecol_g", 0.05);
		SetFloat("mfx_gradecol_b", -0.06);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
		SetBool("mfx_cmatenable", false);
	}

	clearscope static void SetMariFXHexen()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", false);
		SetFloat("mfx_techblend", 0.0);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.12);
		SetFloat("mfx_gradesatmul", 0.78);
		SetFloat("mfx_gradecol_r", 0.06);
		SetFloat("mfx_gradecol_g", -0.04);
		SetFloat("mfx_gradecol_b", 0.14);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
		SetBool("mfx_cmatenable", true);
		SetFloat("mfx_cmat_rr", 0.88);
		SetFloat("mfx_cmat_rg", 0.06);
		SetFloat("mfx_cmat_rb", 0.14);
		SetFloat("mfx_cmat_gr", 0.04);
		SetFloat("mfx_cmat_gg", 0.82);
		SetFloat("mfx_cmat_gb", 0.10);
		SetFloat("mfx_cmat_br", 0.10);
		SetFloat("mfx_cmat_bg", 0.08);
		SetFloat("mfx_cmat_bb", 1.08);
	}

	clearscope static void SetMariFXVRComfort()
	{
		SetMariFXLite(true);
		SetFloat("mfx_lsharpblend", 0.42);
		SetFloat("mfx_lsharpradius", 0.7);
		SetBool("mfx_gradeenable", false);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_techenable", false);
		SetBool("mfx_cmatenable", false);
	}

	clearscope static void SetMariFXLiminal()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 0.68);
		SetFloat("mfx_gradecol_r", 0.06);
		SetFloat("mfx_gradecol_g", 0.04);
		SetFloat("mfx_gradecol_b", -0.04);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXVaporwave()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", true);
		SetFloat("mfx_techblend", 0.45);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 1.12);
		SetFloat("mfx_gradecol_r", 0.08);
		SetFloat("mfx_gradecol_g", -0.02);
		SetFloat("mfx_gradecol_b", 0.10);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.24);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXBrutal()
	{
		SetMariFXLite(true);
		SetBool("mfx_techenable", true);
		SetFloat("mfx_techblend", 0.35);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.08);
		SetFloat("mfx_gradesatmul", 1.18);
		SetFloat("mfx_gradecol_r", 0.14);
		SetFloat("mfx_gradecol_g", -0.06);
		SetFloat("mfx_gradecol_b", -0.08);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.28);
		SetBool("mfx_ne", false);
	}

	private clearscope static void SetFloat(String name, double value)
	{
		let c = GetCVarForApply(name);
		if (c) c.SetFloat(value);
	}

	private clearscope static void SetMirrorFloat(String name, double value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetFloat(value);
	}

	private clearscope static void SetMirrorBool(String name, bool value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetBool(value);
	}

	private clearscope static void SetMirrorString(String name, String value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetString(value);
	}

	private clearscope static void SetInt(String name, int value)
	{
		let c = GetCVarForApply(name);
		if (c) c.SetInt(value);
	}

	private clearscope static void SetBool(String name, bool value)
	{
		let c = GetCVarForApply(name);
		if (c) c.SetBool(value);
	}

	private clearscope static void SetString(String name, String value)
	{
		let c = GetCVarForApply(name);
		if (c) c.SetString(value);
		if (name == "sss_bodycam_unit")
			SetMirrorString("sss_bodycam_unit_live", value);
	}

	clearscope static void SetAOMode(int mode, bool engineSSAO, double engineStrength)
	{
		SetInt("sss_ao_mode", mode);
		// Engine gl_ssao* cannot be set from ZScript (menu-only). Store preset targets
		// so the user can match them under RT-Lite → Engine SSAO.
		SetBool("sss_ao_engine_want", engineSSAO);
		SetFloat("sss_ao_engine_str_want", engineStrength);
	}

	clearscope static void SetBleedSource(int source)
	{
		SetInt("sss_bleed_source", source);
	}

	clearscope static void SetFluidEnhanced(double distortion, double ripple)
	{
		SetFloat("sss_fluidssr_distortion", distortion);
		SetFloat("sss_fluidssr_ripple", ripple);
	}

	clearscope static void SetDepthProxy(bool on, double strength)
	{
		SetBool("sss_depth_proxy", on);
		SetFloat("sss_depth_proxy_strength", strength);
	}

	clearscope static void SetAtmosphere(bool haze, double hazeStr, bool rays, double raysStr, bool deband, double debandStr)
	{
		SetBool("sss_atmo_haze", haze);
		SetFloat("sss_atmo_haze_strength", hazeStr);
		SetBool("sss_atmo_godrays", rays);
		SetFloat("sss_atmo_godrays_strength", raysStr);
		SetBool("sss_atmo_deband", deband);
		SetFloat("sss_atmo_deband_strength", debandStr);
	}

	clearscope static void SetNaturalVignette(bool on, double strength, double falloff)
	{
		SetBool("dpwh_naturalVignette2", on);
		SetFloat("sss_natural_vig_strength", strength);
		SetFloat("sss_natural_vig_falloff", falloff);
	}
}

class SSSRTLiteHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!SSSPostProcessSuppressor.PostWarmupReady())
		{
			Shader.SetEnabled(p, "sss_contactao", false);
			Shader.SetEnabled(p, "sss_fluidssr", false);
			return;
		}

		if (!CVar.GetCVar("sss_post_stack", p).GetBool())
		{
			SSSPostProcessSuppressor.DisableSSSPostShaders(p);
			return;
		}

		if (SSSPostProcessSuppressor.MenuBlocksBleedAO())
		{
			Shader.SetEnabled(p, "sss_contactao", false);
			Shader.SetEnabled(p, "sss_fluidssr", false);
			return;
		}

		int visualPreset = CVar.GetCVar("sss_visual_preset", p).GetInt();
		if (visualPreset == 13)
			Shader.SetEnabled(p, "sss_contactao", false);

		double depthProxy = 0.0;
		if (CVar.GetCVar("sss_depth_proxy", p).GetBool())
			depthProxy = CVar.GetCVar("sss_depth_proxy_strength", p).GetFloat();

		int aoMode = CVar.GetCVar("sss_ao_mode", p).GetInt();
		bool contactCvar = CVar.GetCVar("sss_contactao", p).GetBool();
		double contactStr = CVar.GetCVar("sss_contactao_strength", p).GetFloat();
		double contactRad = CVar.GetCVar("sss_contactao_radius", p).GetFloat();
		double flatSoften = CVar.GetCVar("sss_pp_flat_soften", p).GetFloat();
		if (contactStr > 0.28)
			flatSoften = max(flatSoften, 0.70 + (contactStr - 0.28) * 1.25);
		bool engineSSAO = CVar.GetCVar("gl_ssao", p).GetInt() > 0;

		bool enableContact = false;
		if (visualPreset != 13)
		{
			if (aoMode == 2 || aoMode == 4)
				enableContact = contactCvar && contactStr > 0.0;
			else if (aoMode == 3)
			{
				// Hybrid: when engine SSAO is on, do not stack custom contact AO (GPU blowout / white screen).
				enableContact = contactCvar && contactStr > 0.0 && !engineSSAO;
			}
		}

		if (enableContact)
		{
			Shader.SetUniform1f(p, "sss_contactao", "sss_contactao_strength", contactStr);
			Shader.SetUniform1f(p, "sss_contactao", "sss_contactao_radius", contactRad);
			Shader.SetUniform1f(p, "sss_contactao", "sss_pp_flat_soften", flatSoften);
			Shader.SetUniform1f(p, "sss_contactao", "sss_depth_proxy", depthProxy);
			Shader.SetEnabled(p, "sss_contactao", true);
		}
		else
			Shader.SetEnabled(p, "sss_contactao", false);

		bool fluidOn = CVar.GetCVar("sss_fluidssr", p).GetBool();
		double fluidStr = CVar.GetCVar("sss_fluidssr_strength", p).GetFloat();
		bool fluid = fluidOn && fluidStr > 0.0 && visualPreset != 12
			&& SSSReflectionHelper.PlayerOnFluidFlat(p);
		if (fluid)
		{
			Shader.SetUniform1f(p, "sss_fluidssr", "sss_fluidssr_strength", fluidStr);
			Shader.SetUniform1f(p, "sss_fluidssr", "sss_fluidssr_distortion", CVar.GetCVar("sss_fluidssr_distortion", p).GetFloat());
			Shader.SetUniform1f(p, "sss_fluidssr", "sss_fluidssr_ripple", CVar.GetCVar("sss_fluidssr_ripple", p).GetFloat());
			Shader.SetUniform1f(p, "sss_fluidssr", "sss_fluidssr_time", gametic + e.FracTic);
			Shader.SetUniform1f(p, "sss_fluidssr", "sss_depth_proxy", depthProxy);
			Shader.SetEnabled(p, "sss_fluidssr", true);
		}
		else
			Shader.SetEnabled(p, "sss_fluidssr", false);
	}
}

class SSSVisualPresetHandler : EventHandler
{
	// Matches MENUDEF OptionValue "SSSVisualPresets" (skips Custom / removed Stream Safe).
	static const int PresetCycleOrder[] =
	{
		1, 2, 14, 13, 3, 4, 6, 20, 5, 7, 8, 9, 10, 11, 12,
		15, 16, 17, 22, 23, 24, 25, 26, 27, 28, 29, 18, 19
	};

	transient int HintExpireMapTime;
	transient String HintPresetName;
	transient bool PresetApplyBusy;

	clearscope static String GetPresetShortName(int preset)
	{
		if (preset == 21)
			preset = 20;

		switch (preset)
		{
		case 1: return "Lite — Modern";
		case 2: return "Balanced — Enhanced";
		case 14: return "Vanilla Plus — Classic Enhanced";
		case 13: return "Modern — RT Enhanced";
		case 3: return "Cinematic";
		case 4: return "Ultra — RT-Lite";
		case 6: return "Arena — Competitive";
		case 20: return "Co-op Ready";
		case 5: return "Tactical — Operator";
		case 7: return "Neon Hell — Inferno";
		case 8: return "Cold Sector — Sci-Fi";
		case 9: return "Found Footage — Horror";
		case 10: return "Retro Terminal — CRT";
		case 11: return "Painterly — Stylized";
		case 12: return "Photoreal — HDR";
		case 15: return "Overcast Outdoor";
		case 16: return "Gothic Indoor";
		case 17: return "Noir Operator";
		case 22: return "Golden Hour";
		case 23: return "Liminal";
		case 24: return "Stormy Atmosphere";
		case 25: return "Ultraviolence";
		case 26: return "Vaporwave — Outrun";
		case 27: return "Brutal Carnage";
		case 28: return "Software Nostalgia";
		case 29: return "VR Comfort";
		case 18: return "Heretic Haven";
		case 19: return "Hexen Crypt";
		default: return "Custom (Manual)";
		}
	}

	int CycleNextPresetId(int current)
	{
		return CyclePresetIdByStep(current, 1);
	}

	int CyclePreviousPresetId(int current)
	{
		return CyclePresetIdByStep(current, -1);
	}

	int CyclePresetIdByStep(int current, int step)
	{
		if (current == 21)
			current = 20;

		int idx = -1;
		for (int i = 0; i < PresetCycleOrder.Size(); i++)
		{
			if (PresetCycleOrder[i] == current)
			{
				idx = i;
				break;
			}
		}

		if (idx < 0)
			return step < 0 ? PresetCycleOrder[PresetCycleOrder.Size() - 1] : PresetCycleOrder[0];

		int nextIdx = (idx + step + PresetCycleOrder.Size()) % PresetCycleOrder.Size();
		return PresetCycleOrder[nextIdx];
	}

	void QueueCycleToast(int preset)
	{
		SSSReflectionHelper.SetPresetFastApply(true);
		let toast = CVar.FindCVar("sss_preset_cycle_toast");
		if (toast)
			toast.SetInt(preset);
	}

	void ShowQueuedCycleToast()
	{
		let toast = CVar.FindCVar("sss_preset_cycle_toast");
		if (!toast)
			return;

		int preset = toast.GetInt();
		if (preset <= 0)
			return;

		toast.SetInt(0);
		HintPresetName = GetPresetShortName(preset);
		HintExpireMapTime = Level.MapTime + 105;
	}

	void CyclePreset(int direction)
	{
		if (gamestate != GS_LEVEL)
			return;

		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		int current = CVar.FindCVar("sss_visual_preset").GetInt();
		int next = direction < 0
			? CyclePreviousPresetId(current)
			: CycleNextPresetId(current);

		let uiPreset = CVar.FindCVar("sss_visual_preset");
		if (uiPreset)
			uiPreset.SetInt(next);

		TryApplyPreset(next, true, true);
		QueueCycleToast(next);
		let closeMenu = CVar.FindCVar("sss_close_menu_after_apply");
		if (closeMenu)
			closeMenu.SetBool(true);
		Level.ChangeLevel(Level.MapName, 0, CHANGELEVEL_NOINTERMISSION);
	}

	clearscope static void SyncPresetToPlayContexts(int preset)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		let playPreset = CVar.GetCVar("sss_visual_preset", p);
		if (playPreset)
			playPreset.SetInt(preset);

		let playApplied = CVar.GetCVar("sss_preset_applied", p);
		if (playApplied)
			playApplied.SetInt(preset);
	}

	clearscope static void SyncPresetMarkers(int preset)
	{
		let uiPreset = CVar.FindCVar("sss_visual_preset");
		if (uiPreset)
			uiPreset.SetInt(preset);

		let uiApplied = CVar.FindCVar("sss_preset_applied");
		if (uiApplied)
			uiApplied.SetInt(preset);

		SyncPresetToPlayContexts(preset);
	}

	override void WorldLoaded(WorldEvent e)
	{
		HintExpireMapTime = 0;
		HintPresetName = "";
		ShowQueuedCycleToast();

		let track = CVar.FindCVar("sss_ddz_track_fp");
		if (track)
			track.SetInt(-1);

		SanitizeUnsafeStackCvars();

		if (!CVar.FindCVar("sss_visual_preset_auto").GetBool())
		{
			SyncPresetAppliedMarker();
			return;
		}

		int preset = CVar.FindCVar("sss_visual_preset").GetInt();
		let applied = CVar.FindCVar("sss_preset_applied");
		if (applied && preset == applied.GetInt())
		{
			SyncPresetAppliedMarker();
			return;
		}

		TryApplyPreset(preset, true, true);
		SanitizeUnsafeStackCvars();
		SyncPresetAppliedMarker();
	}

	override void UiTick()
	{
		let closeMenu = CVar.FindCVar("sss_close_menu_after_apply");
		if (closeMenu && closeMenu.GetBool())
		{
			closeMenu.SetBool(false);
			let menu = Menu.GetCurrentMenu();
			while (menu)
			{
				menu.Close();
				menu = Menu.GetCurrentMenu();
			}
		}
	}

	void MaybeClearPresetFastApply()
	{
		if (!SSSReflectionHelper.IsPresetFastApply())
			return;
		if (Level.MapTime < 6)
			return;

		SSSLightingHandler lighting = SSSLightingHandler.FindHandler();
		if (lighting && lighting.IsLightingLoadPending())
			return;

		SSSDarkDoom_Handler ddz = SSSDarkDoom_Handler.FindHandler();
		if (ddz && ddz.IsSectorDarkenPending())
			return;

		SSSReflectionHelper.SetPresetFastApply(false);
	}

	override void WorldTick()
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		MaybeClearPresetFastApply();

		if (!CVar.GetCVar("sss_visual_preset_auto", p).GetBool())
			return;

		let pending = CVar.GetCVar("sss_preset_apply_pending", p);
		if (pending && pending.GetInt() > 0)
		{
			int pendingPreset = pending.GetInt();
			pending.SetInt(0);
			TryApplyPreset(pendingPreset, true, false);
			return;
		}

		int preset = CVar.FindCVar("sss_visual_preset").GetInt();
		let applied = CVar.GetCVar("sss_preset_applied", p);
		if (applied && preset == applied.GetInt())
			return;

		TryApplyPreset(preset, true, false);
	}

	clearscope static void SanitizeUnsafeStackCvars()
	{
		let blend = SSSVisualPresets.GetCVarForApply("mfx_lsharpblend");
		if (blend && blend.GetFloat() > 1.25)
			blend.SetFloat(0.65);

		let shift = SSSVisualPresets.GetCVarForApply("mfx_bssshiftenable");
		if (shift)
			shift.SetBool(false);

		let fluids = SSSVisualPresets.GetCVarForApply("sss_fluid_materials");
		if (fluids)
			fluids.SetBool(false);

		PlayerInfo p = players[consoleplayer];
		if (p && CVar.GetCVar("gl_ssao", p).GetInt() > 0)
		{
			let contact = CVar.GetCVar("sss_contactao", p);
			if (contact)
				contact.SetBool(false);
		}
	}

	void SyncPresetAppliedMarker()
	{
		int preset = CVar.FindCVar("sss_visual_preset").GetInt();
		SyncPresetMarkers(preset);
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_cycle_preset")
			EventHandler.SendNetworkEvent("sss_cycle_preset");
		else if (e.Name == "sss_cycle_preset_prev")
			EventHandler.SendNetworkEvent("sss_cycle_preset_prev");
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		PlayerInfo p = players[consoleplayer];

		if (e.Name == "sss_cycle_preset")
		{
			CyclePreset(1);
			return;
		}
		if (e.Name == "sss_cycle_preset_prev")
		{
			CyclePreset(-1);
			return;
		}

		if (e.Name == "sss_apply_visual_preset" || e.Name == "sss_apply_preset_return")
		{
			int preset = e.Args[0];
			if (preset <= 0)
			{
				preset = CVar.FindCVar("sss_visual_preset").GetInt();
				if (preset <= 0 && p)
					preset = CVar.GetCVar("sss_preset_menu_sel", p).GetInt();
			}
			if (preset <= 0)
				return;

			TryApplyPreset(preset, true, false);

			if (e.Name == "sss_apply_preset_return")
			{
				let close = CVar.FindCVar("sss_close_menu_after_apply");
				if (close)
					close.SetBool(true);
			}
		}
	}

	void ApplyPresetSideEffects()
	{
		SSSReflectionHelper.ApplyPlaneReflections();
		SSSDarkDoom_Handler ddz = SSSDarkDoom_Handler.FindHandler();
		if (ddz)
			ddz.ChangeLighting(false);
	}

	void TryApplyPreset(int preset, bool force, bool skipSideEffects = false)
	{
		if (preset <= 0)
			return;
		if (PresetApplyBusy)
			return;

		if (preset == 21)
			preset = 20;

		bool autoApply = CVar.FindCVar("sss_visual_preset_auto").GetBool();
		PlayerInfo p = players[consoleplayer];
		CVar applied = null;
		if (p)
			applied = CVar.GetCVar("sss_preset_applied", p);

		if (!force && !autoApply)
			return;

		if (!force && applied && preset == applied.GetInt())
			return;

		PresetApplyBusy = true;

		if (!skipSideEffects)
			SSSReflectionHelper.SetPresetFastApply(true);

		SyncPresetToPlayContexts(preset);

		if (p)
			SSSPostProcessSuppressor.FlushPresetTransition(p);

		let applyPlay = CVar.FindCVar("sss_preset_apply_play");
		if (applyPlay)
			applyPlay.SetInt(consoleplayer);
		SSSVisualPresets.Apply(preset);
		if (applyPlay)
			applyPlay.SetInt(-1);
		SanitizeUnsafeStackCvars();
		if (!skipSideEffects)
			ApplyPresetSideEffects();

		SyncPresetMarkers(preset);

		SSSBodyCamHandler bc = SSSBodyCamHandler.Get();
		if (bc && p)
			bc.SyncPresetBodyCam(p);
		EventHandler.SendNetworkEvent("sss_sync_bodycam");

		PresetApplyBusy = false;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL)
			return;
		if (Level.MapTime >= HintExpireMapTime || HintPresetName.Length() == 0)
			return;

		String title = StringTable.Localize("$SSS_PRESET_CYCLE_TITLE");
		String reload = StringTable.Localize("$SSS_PRESET_CYCLE_RELOAD");
		DrawPresetHintText(196, title, Font.CR_GOLD);
		DrawPresetHintText(212, HintPresetName, Font.CR_WHITE);
		DrawPresetHintText(228, reload, Font.CR_GRAY);
	}

	ui void DrawPresetHintText(int y, String text, int color)
	{
		int w = SmallFont.StringWidth(text);
		int x = max(12, 320 - w / 2);
		Screen.DrawText(SmallFont, color, x, y, text,
			DTA_VirtualWidth, 640, DTA_VirtualHeight, 480);
	}
}

// Runs after preset apply; trims expensive features before other map-load handlers.
class SSSMapScaleGuard : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		bool heavy = SSSReflectionHelper.SSS_IsHeavyMap();
		bool safe = CVar.FindCVar("sss_large_map_safe").GetBool();
		bool processSafe = CVar.FindCVar("sss_process_safe").GetBool();

		if (!heavy && !(processSafe && Level.Sectors.Size() >= 768))
			return;
		if (!safe && !processSafe)
			return;

		CVar.FindCVar("sss_bias").SetBool(false);
		CVar.FindCVar("sss_smooth_walls").SetBool(false);
		CVar.FindCVar("sss_relight_recursive").SetBool(false);
		CVar.FindCVar("sss_relight_flats").SetBool(false);
		CVar.FindCVar("sss_colorbleed").SetBool(false);
		CVar.FindCVar("sss_bleed_rg").SetBool(false);
		CVar.FindCVar("sss_shadows").SetBool(false);
		CVar.FindCVar("sss_performance").SetBool(true);
		CVar.FindCVar("sss_contactao").SetBool(false);
		CVar.FindCVar("sss_fluidssr").SetBool(false);
		let procMax = CVar.FindCVar("sss_relight_proc_max");
		if (procMax)
			procMax.SetInt(4);

		let post = CVar.FindCVar("sss_post_stack");
		if (post)
			post.SetBool(false);
	}
}
