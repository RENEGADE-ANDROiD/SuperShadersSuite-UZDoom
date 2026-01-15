class FishEyePostProcessHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		FishEye(e);
	}

	ui void FishEye(RenderEvent e)
	{
		PlayerInfo	plr = players[consoleplayer];
		
		if(plr && plr.mo && CVar.GetCVar("fisheye_enabled", plr).GetBool())
		{
			float strength_val;
			bool chromatic_val;
			
			strength_val = CVar.GetCvar("fisheye_strength", plr).GetFloat();
			chromatic_val = CVar.GetCvar("fisheye_chromatic", plr).GetBool();
			
			Shader.SetUniform1f(plr, "fisheyeshader", "strength", strength_val);
			Shader.SetUniform1i(plr,"fisheyeshader", "chromo", chromatic_val);
			
			Shader.SetEnabled(plr, "fisheyeshader", true);
		}
		else if(plr && plr.mo)
		{
			Shader.SetEnabled(plr, "fisheyeshader", false);
		}
	}
}
