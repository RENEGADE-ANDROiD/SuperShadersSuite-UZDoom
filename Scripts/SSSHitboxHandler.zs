// Hitbox healthbar — crosshair HP overlay (no particles; safe on heavy TCs).

class SSSHitboxHandler : StaticEventHandler
{
	static const int WarmupTics[] = {105};
	static const int MinUpdateInterval[] = {8};

	transient bool OverlayActive;
	transient int OverlayHealth;
	transient int OverlayMaxHealth;
	transient int OverlayFontColor;

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_hitbox")
			ToggleDebug();
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_hitbox")
			EventHandler.SendNetworkEvent("sss_toggle_hitbox");
	}

	override void WorldLoaded(WorldEvent e)
	{
		ClearOverlay();
	}

	override void PlayerEntered(PlayerEvent e)
	{
		if (e.PlayerNumber == consoleplayer)
			ClearOverlay();
	}

	override void WorldTick()
	{
		OverlayActive = false;

		PlayerInfo pl = players[consoleplayer];
		if (!pl || !pl.mo)
			return;

		if (!GetPlayDebugEnabled(pl))
			return;

		if (Level.MapTime < WarmupTics[0])
			return;

		if (!GetBool("sss_hitbox_wire3d", pl))
			return;

		int interval = max(MinUpdateInterval[0], GetInt("sss_hitbox_interval", pl));
		if ((Level.MapTime % interval) != 0)
			return;

		int maxDist = max(256, GetInt("sss_hitbox_maxdist", pl));
		Actor target = FindCrosshairTarget(pl.mo, maxDist, pl);
		if (!target)
			return;

		OverlayHealth = target.health;
		OverlayMaxHealth = GetMaxHealth(target);
		OverlayFontColor = HealthHudColorFromRatio(OverlayHealth, OverlayMaxHealth);
		OverlayActive = true;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (!OverlayActive)
			return;

		let dbg = CVar.FindCVar("sss_hitbox_debug");
		if (!dbg || !dbg.GetBool())
			return;

		int x = 360;
		int y = 72;
		int lh = 10;
		String hpLine = String.Format("HP: %d / %d", OverlayHealth, OverlayMaxHealth);

		DrawHudText(x, y, hpLine, OverlayFontColor);
		DrawHudText(x, y + lh, HealthBandLabel(OverlayHealth, OverlayMaxHealth), OverlayFontColor);
	}

	ui void DrawHudText(int x, int y, String text, int fontColor)
	{
		Screen.DrawText(SmallFont, fontColor, x, y, text,
			DTA_VirtualWidth, 640, DTA_VirtualHeight, 480);
	}

	ui String HealthBandLabel(int health, int maxHealth)
	{
		double ratio = clamp(double(health) / max(1, maxHealth), 0.0, 1.0);
		if (ratio >= 0.875)
			return "STATUS: HEALTHY";
		if (ratio >= 0.625)
			return "STATUS: WOUNDED";
		if (ratio >= 0.375)
			return "STATUS: INJURED";
		if (ratio >= 0.125)
			return "STATUS: CRITICAL";
		return "STATUS: NEAR DEATH";
	}

	ui int HealthHudColor(int health, int maxHealth)
	{
		return HealthHudColorFromRatio(health, maxHealth);
	}

	clearscope static int HealthHudColorFromRatio(int health, int maxHealth)
	{
		double ratio = clamp(double(health) / max(1, maxHealth), 0.0, 1.0);
		if (ratio >= 0.875)
			return Font.CR_GREEN;
		if (ratio >= 0.625)
			return Font.CR_YELLOW;
		if (ratio >= 0.375)
			return Font.CR_ORANGE;
		if (ratio >= 0.125)
			return Font.CR_RED;
		return Font.CR_PURPLE;
	}

	void ClearOverlay()
	{
		OverlayActive = false;
		OverlayHealth = 0;
		OverlayMaxHealth = 0;
		OverlayFontColor = Font.CR_GREEN;
	}

	void ToggleDebug()
	{
		PlayerInfo pl = players[consoleplayer];
		if (!pl)
			return;

		bool next = !GetPlayDebugEnabled(pl);
		let playCvar = CVar.GetCVar("sss_hitbox_debug", pl);
		if (playCvar)
			playCvar.SetBool(next);
		let uiCvar = CVar.FindCVar("sss_hitbox_debug");
		if (uiCvar)
			uiCvar.SetBool(next);

		let active = CVar.FindCVar("sss_hitbox_active");
		if (active)
			active.SetBool(next);

		if (!next)
			ClearOverlay();
	}

	clearscope static bool GetPlayDebugEnabled(PlayerInfo pl)
	{
		if (!pl)
			return false;
		let c = CVar.GetCVar("sss_hitbox_debug", pl);
		return c && c.GetBool();
	}

	bool GetBool(String name, PlayerInfo pl)
	{
		let c = CVar.GetCVar(name, pl);
		return c && c.GetBool();
	}

	int GetInt(String name, PlayerInfo pl)
	{
		let c = CVar.GetCVar(name, pl);
		return c ? c.GetInt() : 0;
	}

	bool IsValidTarget(Actor mo, Actor viewer, int maxDist, PlayerInfo pl)
	{
		if (!mo || !viewer)
			return false;
		if (mo == viewer)
			return false;
		if (!mo.bIsMonster)
			return false;
		if (mo.health <= 0)
			return false;
		if (mo.bInvisible || mo.bNoClip || mo.bNoBlockMap)
			return false;
		if (!mo.bShootable)
			return false;
		if (!GetBool("sss_hitbox_gibs", pl) && IsGoreOrGibActor(mo))
			return false;
		if (mo.height < 4 || mo.radius < 1)
			return false;
		if (mo.Distance2D(viewer) > maxDist)
			return false;
		return true;
	}

	bool IsGoreOrGibActor(Actor mo)
	{
		if (!mo)
			return false;

		String cn = mo.GetClassName();
		if (cn.IndexOf("Gib") >= 0 || cn.IndexOf("GIB") >= 0 || cn.IndexOf("gib") >= 0)
			return true;
		if (cn.IndexOf("Gore") >= 0 || cn.IndexOf("GORE") >= 0 || cn.IndexOf("gore") >= 0)
			return true;
		if (cn.IndexOf("Meat") >= 0 || cn.IndexOf("Chunk") >= 0 || cn.IndexOf("Ragdoll") >= 0)
			return true;
		if (cn.IndexOf("Corpse") >= 0 || cn.IndexOf("Debris") >= 0)
			return true;
		return false;
	}

	Actor FindCrosshairTarget(Actor viewer, int maxDist, PlayerInfo pl)
	{
		if (!viewer || !pl)
			return null;

		FLineTraceData tr;
		double zOff = viewer.height * 0.5;
		if (viewer.floorclip > 0)
			zOff -= viewer.floorclip;

		if (viewer.LineTrace(viewer.angle, maxDist, viewer.pitch, 0, zOff, 0, 0, tr))
		{
			if (tr.HitType == FLineTraceData.TRACE_HitActor && tr.HitActor)
			{
				if (IsValidTarget(tr.HitActor, viewer, maxDist, pl))
					return tr.HitActor;
			}
		}

		return null;
	}

	int GetMaxHealth(Actor mo)
	{
		if (mo.StartHealth > 0)
			return mo.StartHealth;
		return max(mo.health, 1);
	}
}
