class Db_SoftShadeHandler : StaticEventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        PlayerInfo p = players[consolePlayer];

        Shader.SetUniform1f(p, "db_softshade", "resscalefac", 1);

        let doScale = CVar.GetCVar('db_softshade_doscale', p);
        if (doScale && doScale.GetBool())
        {
            Shader.SetUniform1f(p, "db_softshade", "resscalefac", Screen.GetHeight() / 1080.0);
        }

        Shader.SetUniform1f(p, "db_softshade", "paldither", db_softshade_dither);
        Shader.SetEnabled(p, "db_softshade", db_softshade_enabled);
    }
}
