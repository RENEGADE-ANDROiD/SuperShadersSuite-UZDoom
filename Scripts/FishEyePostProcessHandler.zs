class FishEyePostProcessHandler : StaticEventHandler
{
	ui bool BodyCamOwnsFisheye(PlayerInfo plr)
	{
		let active = CVar.FindCVar("sss_bodycam_active");
		if (!active || !active.GetBool())
			return false;
		if (CVar.GetCVar("sss_bodycam_mode", plr).GetInt() != 0)
			return false;
		return true;
	}

	ui void FishEye(RenderEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		if (!plr || !plr.mo)
			return;

		if (BodyCamOwnsFisheye(plr))
			return;

		bool enabled = CVar.GetCVar("fisheye_enabled", plr).GetBool();
		if (!enabled)
		{
			Shader.SetEnabled(plr, "fisheyeshader", false);
			return;
		}

		float strength_val = CVar.GetCvar("fisheye_strength", plr).GetFloat();
		bool chromatic_val = CVar.GetCvar("fisheye_chromatic", plr).GetBool();
		Shader.SetUniform1f(plr, "fisheyeshader", "strength", strength_val);
		Shader.SetUniform1i(plr, "fisheyeshader", "chromo", chromatic_val);
		Shader.SetEnabled(plr, "fisheyeshader", true);
	}

	override void RenderOverlay(RenderEvent e)
	{
		FishEye(e);
	}
}
