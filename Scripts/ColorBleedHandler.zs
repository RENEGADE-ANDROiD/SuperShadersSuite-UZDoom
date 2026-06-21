class ColorBleedHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		bool enabled = CVar.GetCVar("sss_colorbleed", p).GetBool();

		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleeding", CVar.GetCVar("sss_bleeding", p).GetFloat());
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_gamma", CVar.GetCVar("sss_bleed_gamma", p).GetFloat());
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_saturation", CVar.GetCVar("sss_bleed_saturation", p).GetFloat());
		Shader.SetUniform1f(p, "sss_colorbleed", "sss_bleed_rg", CVar.GetCVar("sss_bleed_rg", p).GetBool() ? 1.0 : 0.0);
		Shader.SetEnabled(p, "sss_colorbleed", enabled);
	}
}
