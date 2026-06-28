class ColorBleedHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;

		if (!SSSPostProcessSuppressor.PostWarmupReady())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		if (SSSPostProcessSuppressor.MenuBlocksBleedAO())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		int visualPreset = CVar.GetCVar("sss_visual_preset", p).GetInt();
		if (visualPreset == 13)
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		if (!CVar.GetCVar("sss_colorbleed", p).GetBool())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		int bleedSource = CVar.GetCVar("sss_bleed_source", p).GetInt();
		if (bleedSource == 1 && CVar.GetCVar("sss_relight_recursive", p).GetBool())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}
		// Auto mode: RG post bleed is unstable when recursive was trimmed for map safety.
		if (bleedSource == 1 && CVar.GetCVar("sss_bleed_rg", p).GetBool())
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}
		if (bleedSource == 2)
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		double bleeding = CVar.GetCVar("sss_bleeding", p).GetFloat();
		double bleedGamma = CVar.GetCVar("sss_bleed_gamma", p).GetFloat();
		if (bleeding <= 0.0 && bleedGamma <= 1.001)
		{
			Shader.SetEnabled(p, "sss_colorbleed", false);
			return;
		}

		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleeding", bleeding);
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_gamma", bleedGamma);
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_saturation", CVar.GetCVar("sss_bleed_saturation", p).GetFloat());
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_rg", CVar.GetCVar("sss_bleed_rg", p).GetBool() ? 1.0 : 0.0);
		Shader.SetEnabled(p, "sss_colorbleed", true);
	}
}
