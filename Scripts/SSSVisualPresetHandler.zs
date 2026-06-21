// Unified visual presets + RT-lite post-process handlers

class SSSVisualPresets
{
	clearscope static void Apply(int preset)
	{
		if (preset <= 0)
			return;

		SetSpecialtyOff();

		int p = clamp(preset, 1, 13);

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
		}

		ApplyRelightPresetTier(p);
	}

	clearscope static void ApplyRelightPresetTier(int preset)
	{
		switch (preset)
		{
		case 1:
			SetRelightEnhance(false, false, 1, false, false, false, false, false, false, false, false, 0);
			SetBleedGrade(1.0, 1.0, false);
			break;
		case 2:
			SetRelightEnhance(true, true, 2, false, true, false, false, false, false, false, false, 8);
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
			SetRelightEnhance(true, true, 3, true, true, true, true, false, true, false, true, 10);
			SetBleedGrade(0.96, 1.04, false);
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
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.0);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.48);
		SetFloat("sss_brighten", 0.52);
		SetFloat("sss_additive", 0.22);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.68);
		SetFloat("sss_wall_glow", 0.38);
		SetFloat("sss_flat_lights", 0.48);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 20);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetBool("sss_shadows", false);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.042);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXLite(true);
		SetPostFX(false, 0.0);
		SetFilmGrain(false);
	}

	clearscope static void ApplyBalanced()
	{
		SetRTLite(true, 0.28, 2.5, true, 0.38);
		SetWallBake(0.28);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.54);
		SetFloat("sss_brighten", 0.46);
		SetFloat("sss_additive", 0.28);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.82);
		SetFloat("sss_wall_glow", 0.44);
		SetFloat("sss_flat_lights", 0.62);
		SetInt("sss_flat_light_max", 16);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 26);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetBool("sss_shadows", true);
		SetBool("sss_shadow_players", true);
		SetBool("sss_shadow_monsters", false);
		SetInt("sss_shadow_interval", 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.062);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACES(false);
		SetMariFXLite(true);
		SetPostFX(false, 0.0);
		SetFilmGrain(false);
	}

	clearscope static void ApplyModern()
	{
		SetRTLite(true, 0.36, 2.8, true, 0.46);
		SetWallBake(0.34);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.56);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.30);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.84);
		SetFloat("sss_wall_glow", 0.46);
		SetFloat("sss_flat_lights", 0.66);
		SetInt("sss_flat_light_max", 17);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 30);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.074);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 0, 3.2, 1.32, 1.0);
		SetMariFXModern();
		SetPostFXEx(false, 0.0, true, 12.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 100.0, 0.0);
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

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapCemetery");
		SetACES(false);
		SetMariFXCinematic();
		SetPostFX(true, 0.12);
		SetFilmGrain(true);
	}

	clearscope static void ApplyUltra()
	{
		SetFilmGrain(false);

		SetRTLite(true, 0.48, 3.2, true, 0.58);
		SetWallBake(0.42);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.62);
		SetFloat("sss_brighten", 0.38);
		SetFloat("sss_additive", 0.36);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", true);
		SetFloat("sss_flat_glow", 0.98);
		SetFloat("sss_wall_glow", 0.54);
		SetFloat("sss_flat_lights", 0.78);
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

		SetBalancedDarkDoom();
		SetFilmic(true, "TonemapTide");
		SetACES(false);
		SetMariFXUltra();
		SetPostFX(true, 0.18);
	}

	clearscope static void ApplyTactical()
	{
		SetRTLite(true, 0.32, 2.8, false, 0.0);
		SetWallBake(0.34);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.56);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.26);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.75);
		SetFloat("sss_wall_glow", 0.42);
		SetFloat("sss_flat_lights", 0.55);
		SetInt("sss_flat_light_max", 14);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 24);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.048);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 0, 3.0, 1.30, 0.98);
		SetMariFXTactical();
		SetPostFXEx(false, 0.0, true, 14.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 100.0, 0.0);
	}

	clearscope static void ApplyArena()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.0);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.46);
		SetFloat("sss_brighten", 0.54);
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
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 18);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", false);
		SetFloat("sss_bleeding", 0.0);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapArena");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXLite(true);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
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
		SetPostFXEx(true, 0.14, true, 24.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 0.95, 110.0, 2.0);
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
	}

	clearscope static void ApplyFoundFootage()
	{
		SetRTLite(true, 0.22, 2.2, false, 0.0);
		SetWallBake(0.38);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.64);
		SetFloat("sss_brighten", 0.36);
		SetFloat("sss_additive", 0.38);
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
		SetFloat("sss_bleeding", 0.055);

		SetDarkDoom(2, 4, true);
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetMariFXFoundFootage();
		SetPostFXEx(false, 0.0, true, 28.0);
		SetFilmGrain(false);
		SetBool("dpwh_chromaticAberration2", true);
		SetBool("fisheye_enabled", true);
		SetFloat("fisheye_strength", 0.012);
		SetBloomBoost(false, 1.0, 100.0, 0.0);
	}

	clearscope static void ApplyRetroTerminal()
	{
		SetRTLite(false, 0.0, 2.0, false, 0.0);
		SetWallBake(0.0);

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
		SetFloat("sss_flat_glow", 0.72);
		SetFloat("sss_wall_glow", 0.40);
		SetFloat("sss_flat_lights", 0.50);
		SetInt("sss_flat_light_max", 12);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 22);
		SetBool("sss_ceilreflections", false);
		SetBool("sss_material_reflect", true);
		SetShadows(false, false, false, 4);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.045);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(false, 1, 6.0, 1.8, 1.0);
		SetScreenMRetro();
		SetSoftShade(true, 0.06);
		SetMariFXLite(true);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.10, 100.0, 0.0);
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
	}

	clearscope static void ApplyPhotoreal()
	{
		SetRTLite(true, 0.46, 3.0, true, 0.56);
		SetWallBake(0.44);

		SetBool("sss_lighting", true);
		SetBool("sss_bias", true);
		SetFloat("sss_darken", 0.56);
		SetFloat("sss_brighten", 0.44);
		SetFloat("sss_additive", 0.24);
		SetBool("sss_smooth_walls", true);
		SetBool("sss_performance", false);
		SetBool("sss_color_sec", true);
		SetBool("sss_color_walls", true);
		SetBool("sss_color_spr", false);
		SetFloat("sss_flat_glow", 0.88);
		SetFloat("sss_wall_glow", 0.46);
		SetFloat("sss_flat_lights", 0.68);
		SetInt("sss_flat_light_max", 18);
		SetBool("sss_floorreflections", true);
		SetInt("sss_floorstrength", 34);
		SetBool("sss_ceilreflections", true);
		SetInt("sss_ceilstrength", 12);
		SetBool("sss_material_reflect", true);
		SetShadows(true, true, false, 3);
		SetBool("sss_colorbleed", true);
		SetFloat("sss_bleeding", 0.045);

		SetBalancedDarkDoom();
		SetFilmic(false, "TonemapDefault");
		SetACESConfig(true, 0, 3.5, 1.50, 1.0);
		SetMariFXLite(true);
		SetPostFXEx(false, 0.0, false, 0.0);
		SetFilmGrain(false);
		SetBloomBoost(true, 1.0, 108.0, 0.0);
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

	// All visual presets share the same Dark Doom baseline (Clamp + Dismal). Scene
	// darkness can still be tuned separately in Options -> Dark Doom.
	clearscope static void SetBalancedDarkDoom()
	{
		SetDarkDoom(3, 3, true);
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
		SetBool("mfx_bssblurenable", on);
		SetFloat("mfx_bssblurradius", 0.12);
		SetBool("mfx_bsssharpenable", on);
		SetBool("mfx_techenable", false);
		SetBool("mfx_gradeenable", false);
		SetBool("mfx_vigenable", false);
		SetBool("mfx_ne", false);
	}

	clearscope static void SetMariFXModern()
	{
		SetMariFXLite(true);
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.06);
		SetFloat("mfx_gradesatmul", 1.0);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.28);
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

	clearscope static void SetPostFX(bool lens, double lensAmount)
	{
		SetPostFXEx(lens, lensAmount, lens, lens ? 22.0 : 0.0);
	}

	clearscope static void SetPostFXEx(bool lens, double lensAmount, bool vig, double vigIntensity)
	{
		SetBool("tc_pp_lensflares", lens);
		SetFloat("tc_pp_lensflares_amount", lensAmount);
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

	clearscope static void SetSpecialtyOff()
	{
		SetBool("gl_screem", false);
		SetSoftShade(false, 0.05);
		SetBool("dpwh_chromaticAberration2", false);
		SetBool("dpwh_naturalVignette2", false);
		SetBool("fisheye_enabled", false);
		SetBool("SH_VHSEnable", false);
		SetBool("SH_ShaderEnable", false);
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
		SetBool("mfx_gradeenable", true);
		SetFloat("mfx_gradecolfact", 0.05);
		SetFloat("mfx_gradesatmul", 0.94);
		SetFloat("mfx_gradecol_r", 0.0);
		SetFloat("mfx_gradecol_g", 0.0);
		SetFloat("mfx_gradecol_b", 0.0);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.22);
		SetBool("mfx_ne", false);
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
		SetFloat("mfx_gradesatmul", 0.78);
		SetBool("mfx_vigenable", true);
		SetFloat("mfx_vigmul", 0.42);
		SetBool("mfx_ne", true);
		SetFloat("mfx_ni", 0.08);
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

	private clearscope static void SetFloat(String name, double value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetFloat(value);
	}

	private clearscope static void SetInt(String name, int value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetInt(value);
	}

	private clearscope static void SetBool(String name, bool value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetBool(value);
	}

	private clearscope static void SetString(String name, String value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetString(value);
	}
}

class SSSRTLiteHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];

		bool contact = CVar.GetCVar("sss_contactao", p).GetBool();
		double contactStr = CVar.GetCVar("sss_contactao_strength", p).GetFloat();
		double contactRad = CVar.GetCVar("sss_contactao_radius", p).GetFloat();
		Shader.SetUniform1f(p, "sss_contactao", "sss_contactao_strength", contactStr);
		Shader.SetUniform1f(p, "sss_contactao", "sss_contactao_radius", contactRad);
		Shader.SetEnabled(p, "sss_contactao", contact);

		bool fluid = CVar.GetCVar("sss_fluidssr", p).GetBool()
			&& SSSReflectionHelper.PlayerOnFluidFlat(p);
		double fluidStr = CVar.GetCVar("sss_fluidssr_strength", p).GetFloat();
		Shader.SetUniform1f(p, "sss_fluidssr", "sss_fluidssr_strength", fluidStr);
		Shader.SetEnabled(p, "sss_fluidssr", fluid);
	}
}

class SSSVisualPresetHandler : EventHandler
{
	int OldPreset;
	bool OldAuto;

	override void WorldLoaded(WorldEvent e)
	{
		OldPreset = -1;
		if (CVar.FindCVar("sss_visual_preset_auto").GetBool())
			TryApplyPreset(true);
	}

	override void UiTick()
	{
		if (!CVar.FindCVar("sss_visual_preset_auto").GetBool())
			return;

		int preset = CVar.FindCVar("sss_visual_preset").GetInt();
		bool autoApply = CVar.FindCVar("sss_visual_preset_auto").GetBool();
		if (preset == OldPreset && autoApply == OldAuto)
			return;

		EventHandler.SendNetworkEvent("sss_apply_visual_preset");
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_apply_visual_preset")
			TryApplyPreset(true);
	}

	void TryApplyPreset(bool force)
	{
		int preset = CVar.FindCVar("sss_visual_preset").GetInt();
		bool autoApply = CVar.FindCVar("sss_visual_preset_auto").GetBool();

		if (!force && !autoApply)
			return;

		if (!force && preset == OldPreset && autoApply == OldAuto)
			return;

		if (preset > 0)
		{
			SSSVisualPresets.Apply(preset);
			EventHandler.SendNetworkEvent("SSSUpdateDarkDoom");
			EventHandler.SendNetworkEvent("sss_apply_reflections");
		}

		OldPreset = preset;
		OldAuto = autoApply;
	}
}
