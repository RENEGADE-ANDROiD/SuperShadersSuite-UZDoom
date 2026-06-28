// Atmospheric post stack — haze, light shafts, shadow deband.

class SSSAtmosphereHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (SSSPostProcessSuppressor.MenuBlocksScreenFX())
		{
			Shader.SetEnabled(p, "sss_atmo_haze", false);
			Shader.SetEnabled(p, "sss_atmo_godrays", false);
			Shader.SetEnabled(p, "sss_atmo_deband", false);
			return;
		}

		bool hazeOn = CVar.GetCVar("sss_atmo_haze", p).GetBool();
		double hazeStr = CVar.GetCVar("sss_atmo_haze_strength", p).GetFloat();
		if (hazeOn && hazeStr > 0.0)
		{
			Shader.SetUniform1f(p, "sss_atmo_haze", "sss_atmo_haze_strength", hazeStr);
			Shader.SetUniform1f(p, "sss_atmo_haze", "sss_atmo_haze_tint", CVar.GetCVar("sss_atmo_haze_tint", p).GetFloat());
			Shader.SetEnabled(p, "sss_atmo_haze", true);
		}
		else
			Shader.SetEnabled(p, "sss_atmo_haze", false);

		bool raysOn = CVar.GetCVar("sss_atmo_godrays", p).GetBool();
		double raysStr = CVar.GetCVar("sss_atmo_godrays_strength", p).GetFloat();
		if (raysOn && raysStr > 0.0)
		{
			Shader.SetUniform1f(p, "sss_atmo_godrays", "sss_atmo_godrays_strength", raysStr);
			Shader.SetEnabled(p, "sss_atmo_godrays", true);
		}
		else
			Shader.SetEnabled(p, "sss_atmo_godrays", false);

		bool debandOn = CVar.GetCVar("sss_atmo_deband", p).GetBool();
		double debandStr = CVar.GetCVar("sss_atmo_deband_strength", p).GetFloat();
		if (debandOn && debandStr > 0.0)
		{
			Shader.SetUniform1f(p, "sss_atmo_deband", "sss_atmo_deband_strength", debandStr);
			Shader.SetEnabled(p, "sss_atmo_deband", true);
		}
		else
			Shader.SetEnabled(p, "sss_atmo_deband", false);
	}
}
