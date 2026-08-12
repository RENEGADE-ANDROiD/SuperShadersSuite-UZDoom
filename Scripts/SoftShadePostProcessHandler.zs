class Db_SoftShadeHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consolePlayer];
		if (!p)
			return;

		if (!CVar.GetCVar("sss_post_stack", p).GetBool()
			|| !SSSPostProcessSuppressor.PostWarmupReady()
			|| SSSPostProcessSuppressor.MenuBlocksScreenFX())
		{
			Shader.SetEnabled(p, "db_softshade", false);
			return;
		}

		let enabled = CVar.GetCVar("db_softshade_enabled", p);
		if (!enabled || !enabled.GetBool())
		{
			Shader.SetEnabled(p, "db_softshade", false);
			return;
		}

		Shader.SetUniform1f(p, "db_softshade", "resscalefac", 1);

		let doScale = CVar.GetCVar("db_softshade_doscale", p);
		if (doScale && doScale.GetBool())
			Shader.SetUniform1f(p, "db_softshade", "resscalefac", Screen.GetHeight() / 1080.0);

		let dither = CVar.GetCVar("db_softshade_dither", p);
		Shader.SetUniform1f(p, "db_softshade", "paldither", dither ? dither.GetFloat() : 0.0);
		Shader.SetEnabled(p, "db_softshade", true);
	}
}
