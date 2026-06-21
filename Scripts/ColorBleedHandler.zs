class ColorBleedHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if (!CVar.GetCVar("sss_colorbleed", p).GetBool())
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
