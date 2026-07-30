// BodyCam visual toggle — dedicated digital shader or legacy analog VHS + fisheye.

class SSSBodyCamHandler : StaticEventHandler
{
	double PrevYaw;
	double PrevPitch;
	bool AnglesInit;
	double RollSkewX;
	double RollSkewY;

	clearscope static SSSBodyCamHandler Get()
	{
		return SSSBodyCamHandler(StaticEventHandler.Find('SSSBodyCamHandler'));
	}

	override void WorldLoaded(WorldEvent e)
	{
		AnglesInit = false;
		PlayerInfo p = players[consoleplayer];
		if (p && IsActiveNow())
			SyncPresetBodyCam(p);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_bodycam")
			Toggle();
		else if (e.Name == "sss_sync_bodycam")
		{
			PlayerInfo p = players[consoleplayer];
			if (p)
				SyncPresetBodyCam(p);
		}
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_bodycam")
			EventHandler.SendNetworkEvent("sss_toggle_bodycam");
		else if (e.Name == "sss_sync_bodycam")
			EventHandler.SendNetworkEvent("sss_sync_bodycam");
	}

	void PlayTick()
	{
		PlayerInfo p = players[consoleplayer];
		if (!p || !p.mo)
			return;

		if (!IsActiveNow())
			return;

		PushRuntimeFromPlay(p);

		if (GetModeLive() == 1)
			ApplyAnalogValues(p);
		else
			ApplyDigitalValues(p);

		if (GetModeLive() == 0)
			UpdateRollingShutter(p);
	}

	void PushRuntimeFromPlay(PlayerInfo p)
	{
		let ml = CVar.FindCVar("sss_bodycam_mode_live");
		if (ml)
			ml.SetInt(GetInt(p, "sss_bodycam_mode"));

		double fish = GetFloat(p, "fisheye_strength");
		if (fish < 0.001)
			fish = GetLiveFloat("sss_bodycam_fish_live", 0.022);
		let fl = CVar.FindCVar("sss_bodycam_fish_live");
		if (fl)
			fl.SetFloat(fish);

		if (GetInt(p, "sss_bodycam_mode") == 1)
		{
			let vn = CVar.FindCVar("sss_bodycam_vhs_noise_live");
			if (vn) vn.SetFloat(GetFloat(p, "SH_VHSNoiseIntensity"));
			let vo = CVar.FindCVar("sss_bodycam_vhs_offset_live");
			if (vo) vo.SetFloat(GetFloat(p, "SH_VHSOffsetIntensity"));
			let vl = CVar.FindCVar("sss_bodycam_vhs_lines_live");
			if (vl) vl.SetFloat(GetFloat(p, "SH_VHSLineCount"));
			let vr = CVar.FindCVar("sss_bodycam_vhs_range_live");
			if (vr) vr.SetFloat(GetFloat(p, "SH_VHSRange"));
		}
		else
		{
			SetMirrorFloat("sss_bodycam_chroma_live", GetFloat(p, "sss_bodycam_chroma"));
			SetMirrorFloat("sss_bodycam_noise_live", GetFloat(p, "sss_bodycam_noise"));
			SetMirrorFloat("sss_bodycam_contrast_live", GetFloat(p, "sss_bodycam_contrast"));
			SetMirrorFloat("sss_bodycam_saturation_live", GetFloat(p, "sss_bodycam_saturation"));
			SetMirrorFloat("sss_bodycam_rolling_live", GetFloat(p, "sss_bodycam_rolling"));
			double barrel = GetFloat(p, "sss_bodycam_barrel");
			if (barrel < 0.01)
				barrel = GetFloat(p, "fisheye_strength") / 0.85;
			let fl = CVar.FindCVar("sss_bodycam_fish_live");
			if (fl) fl.SetFloat(clamp(barrel * 0.85, 0.012, 0.12));
			let ol = CVar.FindCVar("sss_bodycam_overlay_live");
			if (ol) ol.SetBool(GetBool(p, "sss_bodycam_overlay"));
			let ul = CVar.FindCVar("sss_bodycam_unit_live");
			if (ul)
			{
				String u = CVar.GetCVar("sss_bodycam_unit", p).GetString();
				if (u.Length() > 0)
					ul.SetString(u);
			}
		}
	}

	void SetMirrorFloat(String name, double value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetFloat(value);
	}

	void SyncPresetBodyCam(PlayerInfo p)
	{
		if (!p)
			return;

		SetSessionBool("sss_bodycam_has_save", false);

		if (!IsActiveNow())
		{
			SetBool(p, "SH_VHSEnable", false);
			SetBool(p, "SH_ShaderEnable", false);
			SetBool(p, "fisheye_enabled", false);
			return;
		}

		PushRuntimeFromPlay(p);
		AnglesInit = false;
		if (GetInt(p, "sss_bodycam_mode") == 1)
			ApplyAnalogValues(p);
		else
			ApplyDigitalValues(p);
	}

	override void WorldTick()
	{
		PlayTick();
	}

	override void RenderOverlay(RenderEvent e)
	{
		BodyCamOverlay(e);
	}

	ui void BodyCamOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p || !p.mo)
			return;

		if (!CVar.GetCVar("sss_post_stack", p).GetBool())
		{
			Shader.SetEnabled(p, "sss_bodycam", false);
			Shader.SetEnabled(p, "fisheyeshader", false);
			Shader.SetEnabled(p, "VHSCRTShader", false);
			return;
		}

		if (!IsActiveNow())
		{
			Shader.SetEnabled(p, "sss_bodycam", false);
			Shader.SetEnabled(p, "fisheyeshader", false);
			Shader.SetEnabled(p, "VHSCRTShader", false);
			return;
		}

		int mode = GetModeLive();
		if (mode == 1)
		{
			Shader.SetEnabled(p, "sss_bodycam", false);
			SyncAnalogFisheyeUi(p);
			SyncAnalogVhsUi(p, e);
		}
		else
		{
			let rollX = CVar.FindCVar("sss_bodycam_roll_x");
			let rollY = CVar.FindCVar("sss_bodycam_roll_y");
			double t = (gametic + e.FracTic) / 35.0;
			double skewX = rollX ? rollX.GetFloat() : 0.0;
			double skewY = rollY ? rollY.GetFloat() : 0.0;

			Shader.SetUniform1f(p, "sss_bodycam", "iTime", t);
			Shader.SetUniform1f(p, "sss_bodycam", "chromaStrength", GetLiveFloat("sss_bodycam_chroma_live", 0.005));
			Shader.SetUniform1f(p, "sss_bodycam", "noiseStrength", GetLiveFloat("sss_bodycam_noise_live", 0.035));
			Shader.SetUniform1f(p, "sss_bodycam", "contrast", GetLiveFloat("sss_bodycam_contrast_live", 1.0));
			Shader.SetUniform1f(p, "sss_bodycam", "saturation", GetLiveFloat("sss_bodycam_saturation_live", 0.9));
			Shader.SetUniform1f(p, "sss_bodycam", "rollSkewX", skewX);
			Shader.SetUniform1f(p, "sss_bodycam", "rollSkewY", skewY);
			Shader.SetUniform1f(p, "sss_bodycam", "rollStrength", GetLiveFloat("sss_bodycam_rolling_live", 0.2));
			Shader.SetEnabled(p, "sss_bodycam", true);

			SyncDigitalFisheyeUi(p);
		}

		let overlay = CVar.FindCVar("sss_bodycam_overlay_live");
		if (overlay && overlay.GetBool())
			DrawOverlayUi(p);

		SyncBodyCamVignetteUi(p);
	}

	ui void SyncBodyCamVignetteUi(PlayerInfo p)
	{
		double strength = GetLiveFloat("sss_bodycam_vig_live", 0.34);
		double falloff = GetLiveFloat("sss_bodycam_vig_fall_live", 0.64);
		if (strength <= 0.001)
			return;

		Shader.SetUniform1f(p, "NaturalVignette", "sss_natural_vig_strength", strength);
		Shader.SetUniform1f(p, "NaturalVignette", "sss_natural_vig_falloff", falloff);
		Shader.SetEnabled(p, "NaturalVignette", true);
	}

	ui void SyncAnalogFisheyeUi(PlayerInfo p)
	{
		double strength = GetLiveFloat("sss_bodycam_fish_live", 0.022);
		bool chroma = CVar.GetCVar("fisheye_chromatic", p).GetBool();
		Shader.SetUniform1f(p, "fisheyeshader", "strength", strength);
		Shader.SetUniform1i(p, "fisheyeshader", "chromo", chroma ? 1 : 0);
		Shader.SetEnabled(p, "fisheyeshader", true);
	}

	ui void SyncAnalogVhsUi(PlayerInfo p, RenderEvent e)
	{
		Shader.SetUniform1f(p, "VHSCRTShader", "iTime", (gametic + e.FracTic) / 35.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "VHSEnable", 1.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "CRTEnable", 0.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "range", GetLiveFloat("sss_bodycam_vhs_range_live", 0.05));
		Shader.SetUniform1f(p, "VHSCRTShader", "noiseQuality", 300.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "noiseIntensity", GetLiveFloat("sss_bodycam_vhs_noise_live", 0.001));
		Shader.SetUniform1f(p, "VHSCRTShader", "offsetIntensity", GetLiveFloat("sss_bodycam_vhs_offset_live", 0.002));
		Shader.SetUniform1f(p, "VHSCRTShader", "colorOffsetIntensity", 0.03);
		Shader.SetUniform1f(p, "VHSCRTShader", "lineCount", GetLiveFloat("sss_bodycam_vhs_lines_live", 250.0));
		Shader.SetUniform1f(p, "VHSCRTShader", "lineSpeed", 1.2);
		Shader.SetUniform1f(p, "VHSCRTShader", "lineEnable", 0.22);
		Shader.SetUniform1f(p, "VHSCRTShader", "CRThardScan", 0.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "warpEnable", 0.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "warpMultX", 1.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "warpMultY", 1.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "grainIntensity", 0.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "contrast", 1.0);
		Shader.SetUniform1f(p, "VHSCRTShader", "saturation", 1.0);
		Shader.SetEnabled(p, "VHSCRTShader", true);
	}

	ui void DrawOverlayUi(PlayerInfo p)
	{
		let session = CVar.FindCVar("sss_bodycam_session_start");
		int sessionStart = session ? session.GetInt() : 0;
		int tics = max(0, Level.MapTime - sessionStart);
		int secs = tics / 35;
		int hrs = secs / 3600;
		int mins = (secs % 3600) / 60;
		int sec = secs % 60;

		String unit = "BWC-01";
		let unitLive = CVar.FindCVar("sss_bodycam_unit_live");
		if (unitLive && unitLive.GetString().Length() > 0)
			unit = unitLive.GetString();

		String timeStr = String.Format("%02d:%02d:%02d", hrs, mins, sec);
		String line1 = "REC  " .. unit;
		String line2 = Level.MapName .. "  " .. timeStr;

		int blink = (gametic / 18) % 2;
		int recColor = blink ? Font.CR_RED : Font.CR_BROWN;

		Screen.DrawText(SmallFont, recColor, 10, 8, line1,
			DTA_VirtualWidth, 640, DTA_VirtualHeight, 480);
		Screen.DrawText(SmallFont, Font.CR_GRAY, 10, 18, line2,
			DTA_VirtualWidth, 640, DTA_VirtualHeight, 480);
	}

	void Toggle()
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!IsActiveNow())
			Enable(p);
		else
			Disable(p);
	}

	clearscope static bool IsActiveNow()
	{
		let c = CVar.FindCVar("sss_bodycam_active");
		return c && c.GetBool();
	}

	clearscope static int GetModeLive()
	{
		let c = CVar.FindCVar("sss_bodycam_mode_live");
		return c ? c.GetInt() : 0;
	}

	clearscope static double GetLiveFloat(String name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	void SetActive(bool on)
	{
		let c = CVar.FindCVar("sss_bodycam_active");
		if (c)
			c.SetBool(on);
	}

	bool HasSave()
	{
		let c = CVar.FindCVar("sss_bodycam_has_save");
		return c && c.GetBool();
	}

	void Enable(PlayerInfo p)
	{
		if (!HasSave())
			SaveCurrent(p);

		PushRuntimeFromPlay(p);
		SetSessionStart(Level.MapTime);
		SetRollSkew(0, 0);
		AnglesInit = false;

		if (GetInt(p, "sss_bodycam_mode") == 1)
			ApplyAnalogValues(p);
		else
			ApplyDigitalValues(p);

		let vig = CVar.FindCVar("sss_bodycam_vig_live");
		if (vig && vig.GetFloat() < 0.001)
			vig.SetFloat(0.34);
		let vigF = CVar.FindCVar("sss_bodycam_vig_fall_live");
		if (vigF && vigF.GetFloat() < 0.55)
			vigF.SetFloat(0.64);

		SetActive(true);
	}

	void Disable(PlayerInfo p)
	{
		if (HasSave())
			RestoreSaved(p);
		else
			ResetShaderDefaults(p);

		SetActive(false);
		let ml = CVar.FindCVar("sss_bodycam_mode_live");
		if (ml) ml.SetInt(0);
		SetSessionBool("sss_bodycam_has_save", false);
	}

	ui void SyncDigitalFisheyeUi(PlayerInfo p)
	{
		double fishStr = clamp(GetLiveFloat("sss_bodycam_fish_live", 0.068), 0.012, 0.12);
		let barrel = CVar.GetCVar("sss_bodycam_barrel", p);
		if (barrel && barrel.GetFloat() >= 0.01)
			fishStr = clamp(barrel.GetFloat() * 0.85, 0.012, 0.12);
		bool chroma = GetLiveFloat("sss_bodycam_chroma_live", 0.005) > 0.001;

		Shader.SetUniform1f(p, "fisheyeshader", "strength", fishStr);
		Shader.SetUniform1f(p, "fisheyeshader", "chromo", chroma ? 1 : 0);
		Shader.SetEnabled(p, "fisheyeshader", true);
	}

	void ApplyDigitalValues(PlayerInfo p)
	{
		SetBool(p, "SH_ShaderEnable", false);
		SetBool(p, "SH_VHSEnable", false);
		SetBool(p, "fisheye_enabled", true);
		RollSkewX = 0;
		RollSkewY = 0;
	}

	void ApplyAnalogValues(PlayerInfo p)
	{
		SetBool(p, "SH_ShaderEnable", true);
		SetBool(p, "SH_VHSEnable", true);
		SetBool(p, "fisheye_chromatic", true);
		SetBool(p, "fisheye_enabled", true);
		double fishStr = GetFloat(p, "fisheye_strength");
		if (fishStr < 0.001)
			SetFloat(p, "fisheye_strength", 0.015);
	}

	void UpdateRollingShutter(PlayerInfo p)
	{
		let mo = p.mo;
		double yaw = mo.angle;
		double pitch = mo.pitch;

		if (!AnglesInit)
		{
			PrevYaw = yaw;
			PrevPitch = pitch;
			AnglesInit = true;
			return;
		}

		double dYaw = yaw - PrevYaw;
		while (dYaw > 180.0) dYaw -= 360.0;
		while (dYaw < -180.0) dYaw += 360.0;

		double dPitch = pitch - PrevPitch;
		PrevYaw = yaw;
		PrevPitch = pitch;

		double smoothX = RollSkewX * 0.50 + dYaw * 0.00085 * 0.50;
		double smoothY = RollSkewY * 0.50 + dPitch * 0.00060 * 0.50;
		RollSkewX = smoothX;
		RollSkewY = smoothY;
		SetSessionFloat("sss_bodycam_roll_x", smoothX);
		SetSessionFloat("sss_bodycam_roll_y", smoothY);
	}

	void SaveCurrent(PlayerInfo p)
	{
		SetSessionBool("sss_bodycam_save_shader", GetBool(p, "SH_ShaderEnable"));
		SetSessionBool("sss_bodycam_save_vhs", GetBool(p, "SH_VHSEnable"));
		SetSessionFloat("sss_bodycam_save_linecount", GetFloat(p, "SH_VHSLineCount"));
		SetSessionFloat("sss_bodycam_save_noiseint", GetFloat(p, "SH_VHSNoiseIntensity"));
		SetSessionFloat("sss_bodycam_save_noisequal", GetFloat(p, "SH_VHSNoiseQuality"));
		SetSessionFloat("sss_bodycam_save_offint", GetFloat(p, "SH_VHSOffsetIntensity"));
		SetSessionFloat("sss_bodycam_save_range", GetFloat(p, "SH_VHSRange"));
		SetSessionBool("sss_bodycam_save_fish_chrom", GetBool(p, "fisheye_chromatic"));
		SetSessionBool("sss_bodycam_save_fish_en", GetBool(p, "fisheye_enabled"));
		SetSessionFloat("sss_bodycam_save_fish_str", GetFloat(p, "fisheye_strength"));
		SetSessionBool("sss_bodycam_has_save", true);
	}

	void RestoreSaved(PlayerInfo p)
	{
		SetBool(p, "SH_ShaderEnable", GetSessionBool("sss_bodycam_save_shader"));
		SetBool(p, "SH_VHSEnable", GetSessionBool("sss_bodycam_save_vhs"));
		SetFloat(p, "SH_VHSLineCount", GetSessionFloat("sss_bodycam_save_linecount"));
		SetFloat(p, "SH_VHSNoiseIntensity", GetSessionFloat("sss_bodycam_save_noiseint"));
		SetFloat(p, "SH_VHSNoiseQuality", GetSessionFloat("sss_bodycam_save_noisequal"));
		SetFloat(p, "SH_VHSOffsetIntensity", GetSessionFloat("sss_bodycam_save_offint"));
		SetFloat(p, "SH_VHSRange", GetSessionFloat("sss_bodycam_save_range"));
		SetBool(p, "fisheye_chromatic", GetSessionBool("sss_bodycam_save_fish_chrom"));
		SetBool(p, "fisheye_enabled", GetSessionBool("sss_bodycam_save_fish_en"));
		SetFloat(p, "fisheye_strength", GetSessionFloat("sss_bodycam_save_fish_str"));
	}

	void ResetShaderDefaults(PlayerInfo p)
	{
		ResetCVar(p, "SH_ShaderEnable");
		ResetCVar(p, "SH_VHSEnable");
		ResetCVar(p, "SH_VHSLineCount");
		ResetCVar(p, "SH_VHSNoiseIntensity");
		ResetCVar(p, "SH_VHSNoiseQuality");
		ResetCVar(p, "SH_VHSOffsetIntensity");
		ResetCVar(p, "SH_VHSRange");
		ResetCVar(p, "fisheye_chromatic");
		ResetCVar(p, "fisheye_enabled");
		ResetCVar(p, "fisheye_strength");
	}

	void SetRollSkew(double x, double y)
	{
		RollSkewX = x;
		RollSkewY = y;
		SetSessionFloat("sss_bodycam_roll_x", x);
		SetSessionFloat("sss_bodycam_roll_y", y);
	}

	void SetSessionStart(int tick)
	{
		let c = CVar.FindCVar("sss_bodycam_session_start");
		if (c) c.SetInt(tick);
	}

	bool GetSessionBool(String name)
	{
		let c = CVar.FindCVar(name);
		return c && c.GetBool();
	}

	int GetSessionInt(String name)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetInt() : 0;
	}

	double GetSessionFloat(String name)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : 0.0;
	}

	void SetSessionBool(String name, bool value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetBool(value);
	}

	void SetSessionFloat(String name, double value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetFloat(value);
	}

	bool GetBool(PlayerInfo p, String name)
	{
		let c = CVar.GetCVar(name, p);
		return c ? c.GetBool() : false;
	}

	int GetInt(PlayerInfo p, String name)
	{
		let c = CVar.GetCVar(name, p);
		return c ? c.GetInt() : 0;
	}

	double GetFloat(PlayerInfo p, String name)
	{
		let c = CVar.GetCVar(name, p);
		return c ? c.GetFloat() : 0.0;
	}

	void SetBool(PlayerInfo p, String name, bool value)
	{
		let c = CVar.GetCVar(name, p);
		if (c) c.SetBool(value);
	}

	void SetFloat(PlayerInfo p, String name, double value)
	{
		let c = CVar.GetCVar(name, p);
		if (c) c.SetFloat(value);
	}

	void ResetCVar(PlayerInfo p, String name)
	{
		let c = CVar.GetCVar(name, p);
		if (c) c.ResetToDefault();
	}
}
