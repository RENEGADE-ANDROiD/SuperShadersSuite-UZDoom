// MariFX post stack — extracted from zscript.zc. Tier 1 zero-radius guards remain in enable tests.

Class MariFXHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!SSSPostProcessSuppressor.PostWarmupReady())
		{
			Shader.SetEnabled(p, "sss_mfx_lumasharp", false);
			return;
		}

		if (!CVar.GetCVar("sss_post_stack", p).GetBool())
		{
			SSSPostProcessSuppressor.DisableSSSPostShaders(p);
			return;
		}

		bool modernSafe = CVar.GetCVar("sss_visual_preset", p).GetInt() == 13;
		bool photorealSafe = CVar.GetCVar("sss_visual_preset", p).GetInt() == 12;

		bool lumaOn = !modernSafe && !photorealSafe && mfx_lsharpenable && mfx_lsharpblend > 0.0;
		bool grainOn = mfx_ne;
		bool dirtOn = mfx_dirtenable;
		bool gradeOn = mfx_gradeenable && !photorealSafe;
		bool lutOn = mfx_lutenable;
		bool techOn = mfx_techenable;
		bool cmatOn = mfx_cmatenable;
		bool hsOn = mfx_hsenable;
		bool bssBlurOn = !modernSafe && !photorealSafe && mfx_bssblurenable && mfx_bssblurradius > 0.0;
		bool bssSharpOn = !modernSafe && !photorealSafe && mfx_bsssharpenable && (mfx_bsssharpradius > 0.0 || mfx_bsssharpamount > 0.0);
		bool bssShiftOn = mfx_bssshiftenable && mfx_bssshiftradius > 0.0;
		bool bblurOn = mfx_bblurenable && mfx_bblurradius > 0.0;
		bool vigOn = mfx_vigenable;
		bool retroOn = mfx_retroenable;
		bool palOn = mfx_palenable;

		double flatSoften = CVar.GetCVar("sss_pp_flat_soften", p).GetFloat();

		Shader.SetEnabled(p, "sss_mfx_lumasharp", lumaOn);
		if (lumaOn)
		{
			double sharpBlend = mfx_lsharpblend;
			if (sharpBlend > 1.25)
				sharpBlend = 0.65;
			else
				sharpBlend = clamp(sharpBlend, 0.0, 1.0);
			Shader.SetUniform1f(p, "sss_mfx_lumasharp", "sharpradius", mfx_lsharpradius);
			Shader.SetUniform1f(p, "sss_mfx_lumasharp", "sharpclamp", mfx_lsharpclamp);
			Shader.SetUniform1f(p, "sss_mfx_lumasharp", "sharpblend", sharpBlend);
			Shader.SetUniform1f(p, "sss_mfx_lumasharp", "sss_pp_flat_soften", flatSoften);
		}

		Shader.SetEnabled(p, "mfx_grain", grainOn);
		if (grainOn)
		{
			Shader.SetUniform1f(p, "mfx_grain", "ni", mfx_ni);
			Shader.SetUniform1f(p, "mfx_grain", "ns", mfx_ns);
			Shader.SetUniform1f(p, "mfx_grain", "np", mfx_np);
			Shader.SetUniform1f(p, "mfx_grain", "bnp", mfx_bnp);
			Shader.SetUniform1i(p, "mfx_grain", "nb", mfx_nb);
			Shader.SetUniform1f(p, "mfx_grain", "Timer", (gametic + e.fractic) / 35.);
		}

		Shader.SetEnabled(p, "mfx_dirt", dirtOn);
		if (dirtOn)
		{
			Shader.SetUniform1f(p, "mfx_dirt", "dirtmc", mfx_dirtmc);
			Shader.SetUniform1f(p, "mfx_dirt", "dirtcfactor", mfx_dirtcfactor);
		}

		Shader.SetEnabled(p, "mfx_grading", gradeOn);
		if (gradeOn)
		{
			Shader.SetUniform3f(p, "mfx_grading", "grademul", (mfx_grademul_r, mfx_grademul_g, mfx_grademul_b));
			Shader.SetUniform3f(p, "mfx_grading", "gradepow", (mfx_gradepow_r, mfx_gradepow_g, mfx_gradepow_b));
			Shader.SetUniform3f(p, "mfx_grading", "gradecol", (mfx_gradecol_r, mfx_gradecol_g, mfx_gradecol_b));
			Shader.SetUniform1f(p, "mfx_grading", "gradecolfact", mfx_gradecolfact);
			Shader.SetUniform1f(p, "mfx_grading", "gradesatmul", mfx_gradesatmul);
			Shader.SetUniform1f(p, "mfx_grading", "gradesatpow", mfx_gradesatpow);
			Shader.SetUniform1f(p, "mfx_grading", "gradevalmul", mfx_gradevalmul);
			Shader.SetUniform1f(p, "mfx_grading", "gradevalpow", mfx_gradevalpow);
		}

		Shader.SetEnabled(p, "mfx_lutgrading", lutOn);
		if (lutOn)
		{
			Shader.SetUniform1i(p, "mfx_lutgrading", "lutindex", mfx_lutindex);
			Shader.SetUniform1f(p, "mfx_lutgrading", "lutblend", mfx_lutblend);
		}

		Shader.SetEnabled(p, "mfx_technicolor", techOn);
		if (techOn)
			Shader.SetUniform1f(p, "mfx_technicolor", "techblend", mfx_techblend);

		Shader.SetEnabled(p, "mfx_colormatrix", cmatOn);
		if (cmatOn)
		{
			Shader.SetUniform3f(p, "mfx_colormatrix", "redrow", (mfx_cmat_rr, mfx_cmat_rg, mfx_cmat_rb));
			Shader.SetUniform3f(p, "mfx_colormatrix", "greenrow", (mfx_cmat_gr, mfx_cmat_gg, mfx_cmat_gb));
			Shader.SetUniform3f(p, "mfx_colormatrix", "bluerow", (mfx_cmat_br, mfx_cmat_bg, mfx_cmat_bb));
		}

		Shader.SetEnabled(p, "mfx_huesaturation", hsOn);
		if (hsOn)
		{
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsover", mfx_hsover);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_a", mfx_hshue_a);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_a", mfx_hssat_a);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_a", mfx_hsval_a);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_r", mfx_hshue_r);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_r", mfx_hssat_r);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_r", mfx_hsval_r);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_y", mfx_hshue_y);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_y", mfx_hssat_y);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_y", mfx_hsval_y);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_g", mfx_hshue_g);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_g", mfx_hssat_g);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_g", mfx_hsval_g);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_c", mfx_hshue_c);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_c", mfx_hssat_c);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_c", mfx_hsval_c);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_b", mfx_hshue_b);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_b", mfx_hssat_b);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_b", mfx_hsval_b);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hshue_m", mfx_hshue_m);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hssat_m", mfx_hssat_m);
			Shader.SetUniform1f(p, "mfx_huesaturation", "hsval_m", mfx_hsval_m);
		}

		Shader.SetEnabled(p, "mfx_bss_blur", bssBlurOn);
		if (bssBlurOn)
			Shader.SetUniform1f(p, "mfx_bss_blur", "bssblurradius", mfx_bssblurradius);

		Shader.SetEnabled(p, "sss_mfx_bss_sharp", bssSharpOn);
		if (bssSharpOn)
		{
			Shader.SetUniform1f(p, "sss_mfx_bss_sharp", "bsssharpradius", mfx_bsssharpradius);
			Shader.SetUniform1f(p, "sss_mfx_bss_sharp", "bsssharpamount", mfx_bsssharpamount);
			Shader.SetUniform1f(p, "sss_mfx_bss_sharp", "sss_pp_flat_soften", flatSoften);
		}

		Shader.SetEnabled(p, "mfx_bss_shift", bssShiftOn);
		if (bssShiftOn)
			Shader.SetUniform1f(p, "mfx_bss_shift", "bssshiftradius", mfx_bssshiftradius);

		Shader.SetEnabled(p, "mfx_borderblur", bblurOn);
		if (bblurOn)
		{
			Shader.SetUniform1f(p, "mfx_borderblur", "vigpow", mfx_vigpow);
			Shader.SetUniform1f(p, "mfx_borderblur", "vigmul", mfx_vigmul);
			Shader.SetUniform1f(p, "mfx_borderblur", "vigbump", mfx_vigbump);
			Shader.SetUniform1i(p, "mfx_borderblur", "vigshape", mfx_vigshape);
			Shader.SetUniform1f(p, "mfx_borderblur", "bblurpow", mfx_bblurpow);
			Shader.SetUniform1f(p, "mfx_borderblur", "bblurmul", mfx_bblurmul);
			Shader.SetUniform1f(p, "mfx_borderblur", "bblurbump", mfx_bblurbump);
			Shader.SetUniform1f(p, "mfx_borderblur", "bblurradius", mfx_bblurradius);
		}

		Shader.SetEnabled(p, "mfx_vignette", vigOn);
		if (vigOn)
		{
			Shader.SetUniform3f(p, "mfx_vignette", "vigcolor", (mfx_vigcolor_r, mfx_vigcolor_g, mfx_vigcolor_b));
			Shader.SetUniform1f(p, "mfx_vignette", "vigpow", mfx_vigpow);
			Shader.SetUniform1f(p, "mfx_vignette", "vigmul", mfx_vigmul);
			Shader.SetUniform1f(p, "mfx_vignette", "vigbump", mfx_vigbump);
			Shader.SetUniform1i(p, "mfx_vignette", "vigshape", mfx_vigshape);
			Shader.SetUniform1i(p, "mfx_vignette", "vigmode", mfx_vigmode);
		}

		Vector2 rresl = (Screen.GetWidth(), Screen.GetHeight());
		Vector2 bresl = rresl;
		switch (mfx_retroscalemode)
		{
		case 0:
			bresl = (CleanWidth, CleanHeight);
			break;
		case 1:
			bresl = (CleanWidth_1, CleanHeight_1);
			break;
		case 2:
			bresl = (max(1, rresl.x * mfx_bscl_x), max(1, rresl.y * mfx_bscl_y));
			break;
		case 3:
			bresl = (clamp(mfx_bres_x, 1, rresl.x), clamp(mfx_bres_y, 1, rresl.y));
			break;
		}

		Shader.SetEnabled(p, "mfx_retrofx", retroOn);
		if (retroOn)
			Shader.SetUniform2f(p, "mfx_retrofx", "bresl", bresl);

		Shader.SetEnabled(p, "mfx_palette", palOn);
		if (palOn)
		{
			Shader.SetUniform2f(p, "mfx_palette", "sfact", retroOn ? bresl : rresl);
			Shader.SetUniform1f(p, "mfx_palette", "palsat", mfx_palsat);
			Shader.SetUniform1f(p, "mfx_palette", "palpow", mfx_palpow);
			Shader.SetUniform1i(p, "mfx_palette", "palnum", mfx_palnum);
			Shader.SetUniform1f(p, "mfx_palette", "paldither", mfx_paldither);
		}
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name ~== "loadmfxpreset")
		{
			int slot = clamp(mfx_presetslot, 0, 7);
			MFXPresetUtility.LoadPreset(slot);
		}
		else if (e.Name ~== "savemfxpreset")
		{
			int slot = clamp(mfx_presetslot, 0, 7);
			MFXPresetUtility.SavePreset(slot);
		}
		else if (e.Name ~== "resetmfxvars")
		{
			switch (e.args[0])
			{
			case 0:
				CVar.FindCVar('mfx_ne').ResetToDefault();
				CVar.FindCVar('mfx_ni').ResetToDefault();
				CVar.FindCVar('mfx_ns').ResetToDefault();
				CVar.FindCVar('mfx_np').ResetToDefault();
				CVar.FindCVar('mfx_bnp').ResetToDefault();
				CVar.FindCVar('mfx_nb').ResetToDefault();
				break;
			case 1:
				CVar.FindCVar('mfx_dirtenable').ResetToDefault();
				CVar.FindCVar('mfx_dirtmc').ResetToDefault();
				CVar.FindCVar('mfx_dirtcfactor').ResetToDefault();
				break;
			case 2:
				CVar.FindCVar('mfx_gradeenable').ResetToDefault();
				CVar.FindCVar('mfx_grademul_r').ResetToDefault();
				CVar.FindCVar('mfx_grademul_g').ResetToDefault();
				CVar.FindCVar('mfx_grademul_b').ResetToDefault();
				CVar.FindCVar('mfx_gradepow_r').ResetToDefault();
				CVar.FindCVar('mfx_gradepow_g').ResetToDefault();
				CVar.FindCVar('mfx_gradepow_b').ResetToDefault();
				CVar.FindCVar('mfx_gradecol_r').ResetToDefault();
				CVar.FindCVar('mfx_gradecol_g').ResetToDefault();
				CVar.FindCVar('mfx_gradecol_b').ResetToDefault();
				CVar.FindCVar('mfx_gradecolfact').ResetToDefault();
				CVar.FindCVar('mfx_gradesatmul').ResetToDefault();
				CVar.FindCVar('mfx_gradesatpow').ResetToDefault();
				CVar.FindCVar('mfx_gradevalmul').ResetToDefault();
				CVar.FindCVar('mfx_gradevalpow').ResetToDefault();
				break;
			case 3:
				CVar.FindCVar('mfx_cmatenable').ResetToDefault();
				CVar.FindCVar('mfx_cmat_rr').ResetToDefault();
				CVar.FindCVar('mfx_cmat_rg').ResetToDefault();
				CVar.FindCVar('mfx_cmat_rb').ResetToDefault();
				CVar.FindCVar('mfx_cmat_gr').ResetToDefault();
				CVar.FindCVar('mfx_cmat_gg').ResetToDefault();
				CVar.FindCVar('mfx_cmat_gb').ResetToDefault();
				CVar.FindCVar('mfx_cmat_br').ResetToDefault();
				CVar.FindCVar('mfx_cmat_bg').ResetToDefault();
				CVar.FindCVar('mfx_cmat_bb').ResetToDefault();
				break;
			case 4:
				CVar.FindCVar('mfx_hsenable').ResetToDefault();
				CVar.FindCVar('mfx_hsover').ResetToDefault();
				CVar.FindCVar('mfx_hshue_a').ResetToDefault();
				CVar.FindCVar('mfx_hssat_a').ResetToDefault();
				CVar.FindCVar('mfx_hsval_a').ResetToDefault();
				CVar.FindCVar('mfx_hshue_r').ResetToDefault();
				CVar.FindCVar('mfx_hssat_r').ResetToDefault();
				CVar.FindCVar('mfx_hsval_r').ResetToDefault();
				CVar.FindCVar('mfx_hshue_y').ResetToDefault();
				CVar.FindCVar('mfx_hssat_y').ResetToDefault();
				CVar.FindCVar('mfx_hsval_y').ResetToDefault();
				CVar.FindCVar('mfx_hshue_g').ResetToDefault();
				CVar.FindCVar('mfx_hssat_g').ResetToDefault();
				CVar.FindCVar('mfx_hsval_g').ResetToDefault();
				CVar.FindCVar('mfx_hshue_c').ResetToDefault();
				CVar.FindCVar('mfx_hssat_c').ResetToDefault();
				CVar.FindCVar('mfx_hsval_c').ResetToDefault();
				CVar.FindCVar('mfx_hshue_b').ResetToDefault();
				CVar.FindCVar('mfx_hssat_b').ResetToDefault();
				CVar.FindCVar('mfx_hsval_b').ResetToDefault();
				CVar.FindCVar('mfx_hshue_m').ResetToDefault();
				CVar.FindCVar('mfx_hssat_m').ResetToDefault();
				CVar.FindCVar('mfx_hsval_m').ResetToDefault();
				break;
			case 5:
				CVar.FindCVar('mfx_bssblurenable').ResetToDefault();
				CVar.FindCVar('mfx_bssblurradius').ResetToDefault();
				CVar.FindCVar('mfx_bsssharpenable').ResetToDefault();
				CVar.FindCVar('mfx_bsssharpradius').ResetToDefault();
				CVar.FindCVar('mfx_bsssharpamount').ResetToDefault();
				CVar.FindCVar('mfx_bssshiftenable').ResetToDefault();
				CVar.FindCVar('mfx_bssshiftradius').ResetToDefault();
				break;
			case 6:
				CVar.FindCVar('mfx_bblurenable').ResetToDefault();
				CVar.FindCVar('mfx_bblurpow').ResetToDefault();
				CVar.FindCVar('mfx_bblurmul').ResetToDefault();
				CVar.FindCVar('mfx_bblurbump').ResetToDefault();
				CVar.FindCVar('mfx_bblurradius').ResetToDefault();
				CVar.FindCVar('mfx_vigenable').ResetToDefault();
				CVar.FindCVar('mfx_vigcolor_r').ResetToDefault();
				CVar.FindCVar('mfx_vigcolor_g').ResetToDefault();
				CVar.FindCVar('mfx_vigcolor_b').ResetToDefault();
				CVar.FindCVar('mfx_vigpow').ResetToDefault();
				CVar.FindCVar('mfx_vigmul').ResetToDefault();
				CVar.FindCVar('mfx_vigbump').ResetToDefault();
				CVar.FindCVar('mfx_vigshape').ResetToDefault();
				CVar.FindCVar('mfx_vigmode').ResetToDefault();
				break;
			case 7:
				CVar.FindCVar('mfx_retroenable').ResetToDefault();
				CVar.FindCVar('mfx_retroscalemode').ResetToDefault();
				CVar.FindCVar('mfx_bres_x').ResetToDefault();
				CVar.FindCVar('mfx_bres_y').ResetToDefault();
				CVar.FindCVar('mfx_bscl_x').ResetToDefault();
				CVar.FindCVar('mfx_bscl_y').ResetToDefault();
				CVar.FindCVar('mfx_palenable').ResetToDefault();
				CVar.FindCVar('mfx_palnum').ResetToDefault();
				CVar.FindCVar('mfx_palsat').ResetToDefault();
				CVar.FindCVar('mfx_palpow').ResetToDefault();
				CVar.FindCVar('mfx_paldither').ResetToDefault();
				break;
			case 8:
				CVar.FindCVar('mfx_lsharpenable').ResetToDefault();
				CVar.FindCVar('mfx_lsharpradius').ResetToDefault();
				CVar.FindCVar('mfx_lsharpclamp').ResetToDefault();
				CVar.FindCVar('mfx_lsharpblend').ResetToDefault();
				break;
			case 9:
				CVar.FindCVar('mfx_lutenable').ResetToDefault();
				CVar.FindCVar('mfx_lutindex').ResetToDefault();
				CVar.FindCVar('mfx_lutblend').ResetToDefault();
				break;
			case 10:
				CVar.FindCVar('mfx_techenable').ResetToDefault();
				CVar.FindCVar('mfx_techblend').ResetToDefault();
				break;
			}
		}
	}
}
