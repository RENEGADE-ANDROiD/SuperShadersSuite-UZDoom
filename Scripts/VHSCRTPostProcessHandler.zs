class VHSCRTPostProcessHandler : StaticEventHandler 
{
	clearscope static bool BodyCamOwnsVhs()
	{
		let active = CVar.FindCVar("sss_bodycam_active");
		if (!active || !active.GetBool())
			return false;
		let mode = CVar.FindCVar("sss_bodycam_mode_live");
		return mode && mode.GetInt() == 1;
	}

	override void RenderOverlay(RenderEvent e) 
	{
		PlayerInfo p = players[consoleplayer];
		if (!p || BodyCamOwnsVhs())
			return;

		if (!CVar.GetCVar("sss_post_stack", p).GetBool()
			|| !CVar.GetCVar("SH_ShaderEnable", p).GetBool())
		{
			Shader.SetEnabled(p, "VHSCRTShader", false);
			return;
		}

		ApplyVhsUniforms(p, e);
		Shader.SetEnabled(p, "VHSCRTShader", true);
	}

	ui void ApplyVhsUniforms(PlayerInfo p, RenderEvent e)
	{
		Shader.SetUniform1f(p, "VHSCRTShader", "iTime", (gametic + e.FracTic) / 35);

		int VHSEnable 		= int(CVar.GetCVar("SH_VHSEnable", p).GetBool());
		int CRTEnable 		= int(CVar.GetCVar("SH_CRTEnable", p).GetBool());

		float Range 				= CVar.GetCVar("SH_VHSRange", p).GetFloat();
		float NoiseQuality 			= CVar.GetCVar("SH_VHSNoiseQuality", p).GetFloat();
		float NoiseIntensity 		= CVar.GetCVar("SH_VHSNoiseIntensity", p).GetFloat();
		float OffsetIntensity 		= CVar.GetCVar("SH_VHSOffsetIntensity", p).GetFloat();
		float ColorOffsetIntensity 	= CVar.GetCVar("SH_VHSColorOffsetIntensity", p).GetFloat();
		float LineCount 			= CVar.GetCVar("SH_VHSLineCount", p).GetFloat();
		float LineSpeed 			= CVar.GetCVar("SH_VHSLineSpeed", p).GetFloat();
		int LineEnable 				= int(CVar.GetCVar("SH_VHSLineEnable", p).GetBool());
		int CRThardScan 			= CVar.GetCVar("SH_CRTHardScan", p).GetInt();
		int warpEnable 				= int(CVar.GetCVar("SH_WarpEnable", p).GetBool());
		int warpMultX 				= CVar.GetCVar("SH_WarpMultX", p).GetInt();
		int warpMultY 				= CVar.GetCVar("SH_WarpMultY", p).GetInt();
		float grainIntensity 		= CVar.GetCVar("SH_GrainIntensity", p).GetFloat();
		float contrast			 	= CVar.GetCVar("SH_Contrast", p).GetFloat();
		float saturation 			= CVar.GetCVar("SH_Saturation", p).GetFloat();

		if (warpMultX <= 0) warpMultX = 1;
		if (warpMultY <= 0) warpMultY = 1;
		if (contrast < 0.1) contrast = 0.1;

		Shader.SetUniform1i(p, "VHSCRTShader", "VHSEnable", 			VHSEnable);
		Shader.SetUniform1i(p, "VHSCRTShader", "CRTEnable", 			CRTEnable);
		Shader.SetUniform1f(p, "VHSCRTShader", "range", 				Range);
		Shader.SetUniform1f(p, "VHSCRTShader", "noiseQuality", 			NoiseQuality);
		Shader.SetUniform1f(p, "VHSCRTShader", "noiseIntensity", 		NoiseIntensity);
		Shader.SetUniform1f(p, "VHSCRTShader", "offsetIntensity", 		OffsetIntensity);
		Shader.SetUniform1f(p, "VHSCRTShader", "colorOffsetIntensity", 	ColorOffsetIntensity);
		Shader.SetUniform1f(p, "VHSCRTShader", "lineCount", 			LineCount);
		Shader.SetUniform1f(p, "VHSCRTShader", "lineSpeed", 			LineSpeed);
		Shader.SetUniform1i(p, "VHSCRTShader", "lineEnable", 			LineEnable);
		Shader.SetUniform1i(p, "VHSCRTShader", "CRThardScan", 			CRThardScan);
		Shader.SetUniform1i(p, "VHSCRTShader", "warpEnable", 			warpEnable);
		Shader.SetUniform1i(p, "VHSCRTShader", "warpMultX", 			warpMultX);
		Shader.SetUniform1i(p, "VHSCRTShader", "warpMultY", 			warpMultY);
		Shader.SetUniform1f(p, "VHSCRTShader", "grainIntensity", 		grainIntensity);
		Shader.SetUniform1f(p, "VHSCRTShader", "contrast", 				contrast);
		Shader.SetUniform1f(p, "VHSCRTShader", "saturation", 			saturation);
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "sha_reset_to_default"))
			return;

		ResetCVar("SH_ShaderEnable");
		ResetCVar("SH_VHSEnable");
		ResetCVar("SH_VHSRange");
		ResetCVar("SH_VHSNoiseQuality");
		ResetCVar("SH_VHSNoiseIntensity");
		ResetCVar("SH_VHSOffsetIntensity");
		ResetCVar("SH_VHSColorOffsetIntensity");
		ResetCVar("SH_VHSLineCount");
		ResetCVar("SH_VHSLineSpeed");
		ResetCVar("SH_VHSLineEnable");
		ResetCVar("SH_CRTEnable");
		ResetCVar("SH_CRTHardScan");
		ResetCVar("SH_WarpEnable");
		ResetCVar("SH_WarpMultX");
		ResetCVar("SH_WarpMultY");
		ResetCVar("SH_GrainIntensity");
		ResetCVar("SH_Contrast");
		ResetCVar("SH_Saturation");
	}

	clearscope static void ResetCVar(String name)
	{
		let uiCvar = CVar.FindCVar(name);
		if (uiCvar)
			uiCvar.ResetToDefault();

		PlayerInfo p = players[consoleplayer];
		if (p)
		{
			let playCvar = CVar.GetCVar(name, p);
			if (playCvar && playCvar != uiCvar)
				playCvar.ResetToDefault();
		}
	}
}
