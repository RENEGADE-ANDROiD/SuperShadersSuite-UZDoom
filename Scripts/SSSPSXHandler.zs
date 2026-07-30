// PSX Classic post — 5:5:5 banding + console gamma (adapted from PSX DOOM CE).

class SSSPSXHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!CVar.GetCVar("sss_post_stack", p).GetBool())
		{
			Shader.SetEnabled(p, "sss_psxlight", false);
			return;
		}

		if (SSSPostProcessSuppressor.MenuBlocksScreenFX())
		{
			Shader.SetEnabled(p, "sss_psxlight", false);
			return;
		}

		bool enabled = CVar.GetCVar("sss_psxlight", p).GetBool();
		bool banding = CVar.GetCVar("sss_psx_banding", p).GetBool();
		int mode = CVar.GetCVar("sss_psxlight_mode", p).GetInt();

		if (!enabled && !banding)
		{
			Shader.SetEnabled(p, "sss_psxlight", false);
			return;
		}

		if (!enabled)
			mode = 0;
		else if (mode < 1)
			mode = 1;

		Shader.SetUniform1i(p, "sss_psxlight", "mode", mode);
		Shader.SetUniform1i(p, "sss_psxlight", "banding", banding ? 1 : 0);
		Shader.SetEnabled(p, "sss_psxlight", true);
	}
}
