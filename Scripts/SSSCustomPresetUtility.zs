// Save/load full SSS visual stacks into Custom 1–3 string blobs.
// Note: BiasedDoom/GZDoom rejects static const String[] reliably — use Push lists.

class SSSCustomPresetUtility
{
	clearscope static void CollectSlotCVars(Array<String> names)
	{
		names.Clear();
		names.Push("sss_post_stack");
		names.Push("sss_lighting");
		names.Push("sss_bias");
		names.Push("sss_darken");
		names.Push("sss_brighten");
		names.Push("sss_additive");
		names.Push("sss_smooth_walls");
		names.Push("sss_performance");
		names.Push("sss_color_sec");
		names.Push("sss_color_walls");
		names.Push("sss_color_spr");
		names.Push("sss_flat_glow");
		names.Push("sss_wall_glow");
		names.Push("sss_flat_lights");
		names.Push("sss_flat_light_max");
		names.Push("sss_flat_light_minsize");
		names.Push("sss_floorreflections");
		names.Push("sss_floorstrength");
		names.Push("sss_ceilreflections");
		names.Push("sss_ceilstrength");
		names.Push("sss_colorbleed");
		names.Push("sss_bleeding");
		names.Push("sss_bleed_gamma");
		names.Push("sss_bleed_saturation");
		names.Push("sss_bleed_rg");
		names.Push("sss_bleed_source");
		names.Push("sss_relight_flats");
		names.Push("sss_relight_recursive");
		names.Push("sss_relight_rec_depth");
		names.Push("sss_relight_dimbleed");
		names.Push("sss_relight_smart");
		names.Push("sss_relight_window");
		names.Push("sss_relight_texture");
		names.Push("sss_relight_gldef");
		names.Push("sss_relight_polylabel");
		names.Push("sss_wall_shadows");
		names.Push("sss_relight_doors");
		names.Push("sss_relight_door_strength");
		names.Push("sss_relight_door_max");
		names.Push("sss_relight_door_interval");
		names.Push("sss_relight_proc_max");
		names.Push("sss_contactao");
		names.Push("sss_contactao_strength");
		names.Push("sss_contactao_radius");
		names.Push("sss_pp_flat_soften");
		names.Push("sss_fluidssr");
		names.Push("sss_fluidssr_strength");
		names.Push("sss_fluidssr_distortion");
		names.Push("sss_fluidssr_ripple");
		names.Push("sss_wall_bake");
		names.Push("sss_ao_mode");
		names.Push("sss_ao_hybrid_scale");
		names.Push("sss_ao_engine_want");
		names.Push("sss_ao_engine_str_want");
		names.Push("sss_depth_proxy");
		names.Push("sss_depth_proxy_strength");
		names.Push("sss_mfx_lite_single");
		names.Push("sss_atmo_haze");
		names.Push("sss_atmo_haze_strength");
		names.Push("sss_atmo_haze_tint");
		names.Push("sss_atmo_godrays");
		names.Push("sss_atmo_godrays_strength");
		names.Push("sss_atmo_deband");
		names.Push("sss_atmo_deband_strength");
		names.Push("sss_shadows");
		names.Push("sss_shadow_players");
		names.Push("sss_shadow_monsters");
		names.Push("sss_shadow_interval");
		names.Push("sss_darkdoom_relite_sync");
		names.Push("sss_darkdoom_flashlight");
		names.Push("ddz_mode");
		names.Push("ddz_preset");
		names.Push("ddz_postgain");
		names.Push("ddz_minlight");
		names.Push("gl_worldgamma_enabled");
		names.Push("gl_worldgamma");
		names.Push("gl_worldgamma_contrast");
		names.Push("gl_worldgamma_brightness");
		names.Push("gl_worldgamma_boostbloom");
		names.Push("sss_natural_vig_strength");
		names.Push("sss_natural_vig_falloff");
		names.Push("at_enabled");
		names.Push("at_aces_mode");
		names.Push("at_Crosstalk");
		names.Push("at_exposure_bias");
		names.Push("at_Saturation");
		names.Push("at_CrossSaturation");
		names.Push("at_sky_soften");
		names.Push("dpwh_filmictonemap2");
		names.Push("dsc_scene_lut2");
		names.Push("dpwh_filmgrain2");
		names.Push("dpwh_chromaticAberration2");
		names.Push("dpwh_naturalVignette2");
		names.Push("gl_bloomboost");
		names.Push("gl_bloomboost_gamma");
		names.Push("gl_bloomboost_contrast");
		names.Push("gl_bloomboost_brightness");
		names.Push("tc_pp_lensflares");
		names.Push("tc_pp_lensflares_threshold");
		names.Push("tc_pp_lensflares_amount");
		names.Push("tc_pp_lensflares_samples");
		names.Push("tc_pp_lensflares_distance");
		names.Push("tc_pp_vignette");
		names.Push("tc_pp_vignette_intensity");
		names.Push("tc_pp_vignette_falloff");
		names.Push("tc_pp_noise");
		names.Push("tc_pp_noise_amount");
		names.Push("db_softshade_enabled");
		names.Push("db_softshade_dither");
		names.Push("db_softshade_doscale");
		names.Push("gl_screem");
		names.Push("gl_screem_oldpallut");
		names.Push("gl_screem_ybias");
		names.Push("gl_screem_wide");
		names.Push("gl_screem_res_mode");
		names.Push("gl_screem_res_detail");
		names.Push("gl_screem_tonecontrols");
		names.Push("gl_screem_gamma");
		names.Push("gl_screem_brightness");
		names.Push("gl_screem_contrast");
		names.Push("gl_screem_saturation");
		names.Push("gl_screem_phosphor");
		names.Push("gl_screem_phosphor_amount");
		names.Push("gl_screem_phosphor_residue");
		names.Push("gl_screem_grillmode");
		names.Push("gl_screem_grilldepth");
		names.Push("gl_screem_tempmode");
		names.Push("gl_screem_kelvin");
		names.Push("mfx_lsharpenable");
		names.Push("mfx_lsharpradius");
		names.Push("mfx_lsharpclamp");
		names.Push("mfx_lsharpblend");
		names.Push("mfx_bssshiftenable");
		names.Push("mfx_bssblurenable");
		names.Push("mfx_bssblurradius");
		names.Push("mfx_bsssharpenable");
		names.Push("mfx_techenable");
		names.Push("mfx_techblend");
		names.Push("mfx_gradeenable");
		names.Push("mfx_gradecolfact");
		names.Push("mfx_gradesatmul");
		names.Push("mfx_gradecol_r");
		names.Push("mfx_gradecol_g");
		names.Push("mfx_gradecol_b");
		names.Push("mfx_vigenable");
		names.Push("mfx_vigmul");
		names.Push("mfx_ne");
		names.Push("mfx_ni");
		names.Push("mfx_ns");
		names.Push("mfx_cmatenable");
		names.Push("mfx_hsenable");
		names.Push("mfx_lutenable");
		names.Push("mfx_cmat_rr");
		names.Push("mfx_cmat_rg");
		names.Push("mfx_cmat_rb");
		names.Push("mfx_cmat_gr");
		names.Push("mfx_cmat_gg");
		names.Push("mfx_cmat_gb");
		names.Push("mfx_cmat_br");
		names.Push("mfx_cmat_bg");
		names.Push("mfx_cmat_bb");
		names.Push("fisheye_enabled");
		names.Push("fisheye_chromatic");
		names.Push("fisheye_strength");
		names.Push("SH_ShaderEnable");
		names.Push("SH_VHSEnable");
		names.Push("SH_CRTEnable");
		names.Push("SH_VHSLineCount");
		names.Push("SH_VHSNoiseIntensity");
		names.Push("SH_VHSNoiseQuality");
		names.Push("SH_VHSOffsetIntensity");
		names.Push("SH_VHSColorOffsetIntensity");
		names.Push("SH_VHSRange");
		names.Push("SH_VHSLineSpeed");
		names.Push("SH_VHSLineEnable");
		names.Push("sss_bodycam_mode");
		names.Push("sss_bodycam_chroma");
		names.Push("sss_bodycam_noise");
		names.Push("sss_bodycam_contrast");
		names.Push("sss_bodycam_saturation");
		names.Push("sss_bodycam_rolling");
		names.Push("sss_bodycam_overlay");
		names.Push("sss_bodycam_unit");
		names.Push("sss_bodycam_barrel");
		names.Push("sss_psxlight");
		names.Push("sss_psxlight_mode");
		names.Push("sss_psx_banding");

		names.Push("sss_floor_match_heuristic");
		for (int i = 1; i <= 10; i++)
		{
			names.Push(String.Format("sss_floor%d", i));
			names.Push(String.Format("sss_ceil%d", i));
		}

		CollectMariFXCVars(names);
	}

	clearscope static void PushUnique(Array<String> names, String name)
	{
		if (names.Find(name) == names.Size())
			names.Push(name);
	}

	clearscope static void CollectMariFXCVars(Array<String> names)
	{
		int lump = Wads.CheckNumForFullName("CVARINFO.txt");
		if (lump < 0)
			return;

		String data = Wads.ReadLump(lump);
		data.Substitute("\r", "");
		Array<String> lines;
		data.Split(lines, "\n");
		bool inPresetVars = false;
		for (int i = 0; i < lines.Size(); i++)
		{
			if (lines[i].IndexOf("BEGIN PRESET VARS") >= 0)
			{
				inPresetVars = true;
				continue;
			}
			if (lines[i].IndexOf("END PRESET VARS") >= 0)
				break;
			if (!inPresetVars)
				continue;

			Array<String> tokens;
			lines[i].Split(tokens, " ", 0);
			for (int j = 0; j < tokens.Size(); j++)
			{
				String token = tokens[j];
				if (token.Left(4) != "mfx_")
					continue;
				int eq = token.IndexOf("=");
				if (eq >= 0)
					token = token.Left(eq);
				if (token.Left(10) != "mfx_preset")
					PushUnique(names, token);
				break;
			}
		}
	}

	// Delimited blob codec (avoids deprecated Dictionary on BiasedDoom 4.15+).
	// Format: "SSSCP1\n" then "key=value\n" lines. Values escape \, =, CR, LF.

	clearscope static String SlotCVarName(int slot)
	{
		return "sss_custom_preset" .. slot;
	}

	clearscope static String EscapeValue(String s)
	{
		String result = "";
		for (uint i = 0; i < s.Length(); i++)
		{
			int c = s.ByteAt(i);
			if (c == 92)
				result = result .. String.Format("%c%c", 92, 92);
			else if (c == 10)
				result = result .. String.Format("%cn", 92);
			else if (c == 13)
				result = result .. String.Format("%cr", 92);
			else if (c == 61)
				result = result .. String.Format("%c=", 92);
			else
				result = result .. s.Mid(i, 1);
		}
		return result;
	}

	clearscope static String UnescapeValue(String s)
	{
		String result = "";
		for (uint i = 0; i < s.Length(); i++)
		{
			int c = s.ByteAt(i);
			if (c == 92 && i + 1 < s.Length())
			{
				int n = s.ByteAt(i + 1);
				if (n == 92)
					result = result .. String.Format("%c", 92);
				else if (n == 110)
					result = result .. "\n";
				else if (n == 114)
					result = result .. "\r";
				else if (n == 61)
					result = result .. "=";
				else
					result = result .. s.Mid(i + 1, 1);
				i++;
			}
			else
				result = result .. s.Mid(i, 1);
		}
		return result;
	}

	clearscope static bool LooksLikeBlob(String blob)
	{
		// Magic header "SSSCP1" followed by newline.
		if (blob.Length() < 7)
			return false;
		if (blob.Left(6) != "SSSCP1")
			return false;
		int next = blob.ByteAt(6);
		return next == 10 || next == 13;
	}

	clearscope static bool BlobHasKnownSetting(String blob)
	{
		Array<String> names;
		CollectSlotCVars(names);
		for (int i = 0; i < names.Size(); i++)
		{
			if (blob.IndexOf("\n" .. names[i] .. "=") >= 0)
				return true;
		}
		return false;
	}

	clearscope static String BuildBlob(Array<String> names)
	{
		String blob = "SSSCP1\n";
		for (int i = 0; i < names.Size(); i++)
		{
			CVar v = SSSVisualPresets.GetCVarForApply(names[i]);
			if (!v)
				continue;
			blob = blob .. names[i] .. "=" .. EscapeValue(v.GetString()) .. "\n";
		}
		return blob;
	}

	clearscope static bool ApplyBlob(String blob)
	{
		Array<String> lines;
		blob.Split(lines, "\n");
		if (lines.Size() < 2)
			return false;

		String magic = lines[0];
		if (magic.Length() > 0 && magic.ByteAt(magic.Length() - 1) == 13)
			magic = magic.Left(magic.Length() - 1);
		if (magic != "SSSCP1")
			return false;

		int applied = 0;
		for (int i = 1; i < lines.Size(); i++)
		{
			String line = lines[i];
			if (line.Length() == 0)
				continue;
			// Drop trailing CR from Windows-style line endings.
			if (line.ByteAt(line.Length() - 1) == 13)
				line = line.Left(line.Length() - 1);
			if (line.Length() == 0)
				continue;

			int eq = -1;
			for (uint j = 0; j < line.Length(); j++)
			{
				if (line.ByteAt(j) != 61)
					continue;
				// Unescaped '=' (not preceded by odd number of backslashes).
				int bs = 0;
				for (int k = int(j) - 1; k >= 0 && line.ByteAt(k) == 92; k--)
					bs++;
				if ((bs % 2) == 0)
				{
					eq = j;
					break;
				}
			}
			if (eq <= 0)
				continue;

			String key = line.Left(eq);
			String val = UnescapeValue(line.Mid(eq + 1));
			CVar playCvar = SSSVisualPresets.GetCVarForApply(key);
			CVar uiCvar = CVar.FindCVar(key);
			if (!playCvar && !uiCvar)
				continue;
			SSSVisualPresets.ApplyCVarString(key, val);
			applied++;
		}
		return applied > 0;
	}

	clearscope static void SaveSlot(int slot)
	{
		if (slot < 1 || slot > 3)
			return;

		Array<String> names;
		CollectSlotCVars(names);

		String blob = BuildBlob(names);
		if (blob.Length() > 12000)
		{
			Console.Printf(StringTable.Localize("$SSS_CUSTOM_TOO_LARGE"), slot, blob.Length(), 12000);
			return;
		}

		CVar store = CVar.FindCVar(SlotCVarName(slot));
		if (!store)
			return;
		store.SetString(blob);
		Console.Printf(StringTable.Localize("$SSS_CUSTOM_SAVED"), slot);
	}

	clearscope static bool LoadSlot(int slot, bool cleanBaseline = false)
	{
		if (slot < 1 || slot > 3)
			return false;

		CVar store = CVar.FindCVar(SlotCVarName(slot));
		if (!store)
			return false;

		String blob = store.GetString();
		if (blob == "" || blob.Length() < 2)
		{
			Console.Printf(StringTable.Localize("$SSS_CUSTOM_EMPTY"), slot);
			return false;
		}

		if (blob.Length() > 12000 || !LooksLikeBlob(blob) || !BlobHasKnownSetting(blob))
		{
			Console.Printf(StringTable.Localize("$SSS_CUSTOM_CORRUPT"), slot);
			return false;
		}

		if (cleanBaseline)
			SSSVisualPresets.SetSpecialtyOff();

		if (!ApplyBlob(blob))
		{
			Console.Printf(StringTable.Localize("$SSS_CUSTOM_CORRUPT"), slot);
			return false;
		}
		Console.Printf(StringTable.Localize("$SSS_CUSTOM_LOADED"), slot);
		return true;
	}

	clearscope static bool SlotHasData(int slot)
	{
		if (slot < 1 || slot > 3)
			return false;
		CVar store = CVar.FindCVar(SlotCVarName(slot));
		return store && store.GetString() != "";
	}
}
