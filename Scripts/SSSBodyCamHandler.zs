// BodyCam visual toggle — dedicated digital shader or legacy analog VHS + fisheye.

class SSSBodyCamHandler : StaticEventHandler
{
	double PrevYaw;
	double PrevPitch;
	bool AnglesInit;

	override void WorldLoaded(WorldEvent e)
	{
		AnglesInit = false;
		if (IsActive())
		{
			SetSessionStart(Level.MapTime);
			ReapplyActive(players[consoleplayer]);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_bodycam")
			Toggle();
	}

	override void WorldTick()
	{
		if (!IsActive())
			return;

		PlayerInfo p = players[consoleplayer];
		if (!p || !p.mo)
			return;

		if (GetInt(p, "sss_bodycam_mode") != 0)
			return;

		SyncDigitalFisheye(p);
		UpdateRollingShutter(p);
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

		let active = CVar.FindCVar("sss_bodycam_active");
		if (!active || !active.GetBool())
		{
			Shader.SetEnabled(p, "sss_bodycam", false);
			return;
		}

		if (CVar.GetCVar("sss_bodycam_mode", p).GetInt() == 1)
		{
			Shader.SetEnabled(p, "sss_bodycam", false);
		}
		else
		{
			let rollX = CVar.FindCVar("sss_bodycam_roll_x");
			let rollY = CVar.FindCVar("sss_bodycam_roll_y");
			double t = (gametic + e.FracTic) / 35.0;

			Shader.SetUniform1f(p, "sss_bodycam", "iTime", t);
			Shader.SetUniform1f(p, "sss_bodycam", "chromaStrength", CVar.GetCVar("sss_bodycam_chroma", p).GetFloat());
			Shader.SetUniform1f(p, "sss_bodycam", "noiseStrength", CVar.GetCVar("sss_bodycam_noise", p).GetFloat());
			Shader.SetUniform1f(p, "sss_bodycam", "contrast", CVar.GetCVar("sss_bodycam_contrast", p).GetFloat());
			Shader.SetUniform1f(p, "sss_bodycam", "saturation", CVar.GetCVar("sss_bodycam_saturation", p).GetFloat());
			Shader.SetUniform1f(p, "sss_bodycam", "rollSkewX", rollX ? rollX.GetFloat() : 0.0);
			Shader.SetUniform1f(p, "sss_bodycam", "rollSkewY", rollY ? rollY.GetFloat() : 0.0);
			Shader.SetUniform1f(p, "sss_bodycam", "rollStrength", CVar.GetCVar("sss_bodycam_rolling", p).GetFloat());
			Shader.SetEnabled(p, "sss_bodycam", true);

			SyncDigitalFisheyeUi(p);
		}

		if (CVar.GetCVar("sss_bodycam_overlay", p).GetBool())
			DrawOverlayUi(p);
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

		String unit = CVar.GetCVar("sss_bodycam_unit", p).GetString();
		if (unit.Length() == 0)
			unit = "BWC-01";

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

		if (!IsActive())
			Enable(p);
		else
			Disable(p);
	}

	bool IsActive()
	{
		let c = CVar.FindCVar("sss_bodycam_active");
		return c && c.GetBool();
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

		SetSessionStart(Level.MapTime);
		SetRollSkew(0, 0);
		AnglesInit = false;

		if (GetInt(p, "sss_bodycam_mode") == 1)
			ApplyAnalogValues(p);
		else
			ApplyDigitalValues(p);

		SetSessionBool("sss_bodycam_active", true);
	}

	void Disable(PlayerInfo p)
	{
		if (HasSave())
			RestoreSaved(p);
		else
			ResetShaderDefaults(p);

		SetSessionBool("sss_bodycam_active", false);
		SetSessionBool("sss_bodycam_has_save", false);
	}

	void ReapplyActive(PlayerInfo p)
	{
		if (!p)
			return;

		if (GetInt(p, "sss_bodycam_mode") == 1)
			ApplyAnalogValues(p);
		else
			ApplyDigitalValues(p);
	}

	ui void SyncDigitalFisheyeUi(PlayerInfo p)
	{
		double barrel = CVar.GetCVar("sss_bodycam_barrel", p).GetFloat();
		double fishStr = clamp(barrel * 0.85, 0.012, 0.12);
		bool chroma = CVar.GetCVar("sss_bodycam_chroma", p).GetFloat() > 0.001;

		Shader.SetUniform1f(p, "fisheyeshader", "strength", fishStr);
		Shader.SetUniform1i(p, "fisheyeshader", "chromo", chroma ? 1 : 0);
		Shader.SetEnabled(p, "fisheyeshader", true);
	}

	void SyncDigitalFisheye(PlayerInfo p)
	{
		double barrel = GetFloat(p, "sss_bodycam_barrel");
		SetFloat(p, "fisheye_strength", clamp(barrel * 0.85, 0.012, 0.12));
		SetBool(p, "fisheye_chromatic", GetFloat(p, "sss_bodycam_chroma") > 0.001);
		SetBool(p, "fisheye_enabled", true);
	}

	void ApplyDigitalValues(PlayerInfo p)
	{
		SetBool(p, "SH_ShaderEnable", false);
		SetBool(p, "SH_VHSEnable", false);
		SyncDigitalFisheye(p);
	}

	void ApplyAnalogValues(PlayerInfo p)
	{
		SetBool(p, "SH_ShaderEnable", true);
		SetBool(p, "SH_VHSEnable", true);
		SetFloat(p, "SH_VHSLineCount", 371.875);
		SetFloat(p, "SH_VHSNoiseIntensity", 0.00103125);
		SetFloat(p, "SH_VHSNoiseQuality", 500.0);
		SetFloat(p, "SH_VHSOffsetIntensity", 0.0221875);
		SetFloat(p, "SH_VHSRange", 0.05);
		SetBool(p, "fisheye_chromatic", true);
		SetBool(p, "fisheye_enabled", true);
		SetFloat(p, "fisheye_strength", 0.035);
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

		double smoothX = GetSessionFloat("sss_bodycam_roll_x");
		double smoothY = GetSessionFloat("sss_bodycam_roll_y");
		smoothX = smoothX * 0.50 + dYaw * 0.00085 * 0.50;
		smoothY = smoothY * 0.50 + dPitch * 0.00060 * 0.50;
		SetRollSkew(smoothX, smoothY);
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
