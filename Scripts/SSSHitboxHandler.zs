// PB-style locational hitbox overlay: stacked zone wireframes + crosshair HUD.

enum EHitZone
{
	HZ_Legs = 0,
	HZ_Lower = 1,
	HZ_Upper = 2,
	HZ_Head = 3
}

class SSSHitboxHandler : StaticEventHandler
{
	transient bool HudActive;
	transient int HudHealth;
	transient int HudMaxHealth;
	transient String HudClassName;
	transient String HudZoneName;
	transient int HudZoneColor;
	transient int HudPainPct;
	transient double HudDistanceM;
	transient double HudRadius;
	transient double HudHeight;
	transient double HudUpperMin;
	transient double HudUpperMult;
	transient double HudMultiplier;

	transient Actor LastHitActor;
	transient double LastHitZ;
	transient bool HasLastHit;
	transient bool VisWest;
	transient bool VisEast;
	transient bool VisSouth;
	transient bool VisNorth;

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_toggle_hitbox")
			ToggleDebug();
	}

	override void WorldTick()
	{
		if (!GetDebugEnabled())
		{
			HudActive = false;
			return;
		}

		PlayerInfo pl = players[consoleplayer];
		if (!pl || !pl.mo)
			return;

		int interval = max(1, GetInt("sss_hitbox_interval", pl));
		if (Level.MapTime % interval != 0)
			return;

		int life = max(6, interval * 3 + 2);
		double step = max(1.0, GetFloat("sss_hitbox_spacing", pl));
		double psize = max(0.5, GetFloat("sss_hitbox_size", pl));
		int maxDist = max(256, GetInt("sss_hitbox_maxdist", pl));
		bool fillFaces = GetBool("sss_hitbox_fillfaces", pl);
		bool wrapVisible = GetBool("sss_hitbox_wrapvisible", pl);

		if (GetBool("sss_hitbox_all", pl))
		{
			ThinkerIterator it = ThinkerIterator.Create("Actor");
			Actor mo;
			while (mo = Actor(it.Next()))
			{
				if (!IsValidTarget(mo, pl.mo, maxDist, pl))
					continue;
				DrawHitbox(mo, pl.mo, pl, step, life, psize, fillFaces, wrapVisible);
			}
		}
		else
		{
			Actor target = GetCrosshairTarget(pl.mo, maxDist, pl);
			if (target)
				DrawHitbox(target, pl.mo, pl, step, life, psize, fillFaces, wrapVisible);
		}

		UpdateHudCache(pl, maxDist);
	}

	void UpdateHudCache(PlayerInfo pl, int maxDist)
	{
		HudActive = false;
		if (!GetBool("sss_hitbox_hud", pl))
			return;

		Actor target = GetCrosshairTarget(pl.mo, maxDist, pl);
		if (!target)
			return;

		FillHudFields(target, pl);
		HudHealth = target.health;
		HudActive = true;
	}

	void FillHudFields(Actor mo, PlayerInfo pl)
	{
		double headMin = GetFloat("sss_hitbox_head_min", pl);
		double upperMin = GetFloat("sss_hitbox_upper_min", pl);
		double lowerMin = GetFloat("sss_hitbox_lower_min", pl);
		double headMult = GetFloat("sss_hitbox_head_mult", pl);
		double upperMult = GetFloat("sss_hitbox_upper_mult", pl);
		double lowerMult = GetFloat("sss_hitbox_lower_mult", pl);
		double legsMult = GetFloat("sss_hitbox_legs_mult", pl);
		int zone;

		HudClassName = mo.GetClassName();
		HudDistanceM = mo.Distance2D(pl.mo) / 32.0;
		HudMaxHealth = GetMaxHealth(mo);
		HudRadius = mo.radius;
		HudHeight = mo.height;
		HudUpperMin = upperMin;
		HudUpperMult = upperMult;
		HudPainPct = int(round(double(mo.PainChance) / 256.0 * 100.0));

		double hitZ = mo.pos.z + mo.height * 0.65;
		if (HasLastHit && LastHitActor == mo)
			hitZ = LastHitZ;

		zone = ZoneFromHeight(mo, hitZ, headMin, upperMin, lowerMin);
		HudZoneName = ZoneName(zone);
		HudZoneColor = ZoneHudColor(zone);
		HudMultiplier = ZoneMultiplier(zone, headMult, upperMult, lowerMult, legsMult);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (!HudActive)
			return;
		DrawHudOverlay();
	}

	ui void DrawHudOverlay()
	{
		int y = 72;
		int x = 360;
		int lh = 10;
		int hpColor = HealthHudColor(HudHealth, HudMaxHealth);

		DrawHudLine(x, y, HudClassName, Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("DISTANCE: %.1f M", HudDistanceM), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("HP: %d/%d", HudHealth, HudMaxHealth), hpColor); y += lh;
		DrawHudLine(x, y, "ZONE: " .. HudZoneName, HudZoneColor); y += lh;
		DrawHudLine(x, y, String.Format("MULTIPLIER: %.2fX", HudMultiplier), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("PAIN CHANCE: %d%%", HudPainPct), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("RADIUS = %.1f", HudRadius), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("HEIGHT = %.1f", HudHeight), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("POSTORSOHB = %.2f", HudUpperMin), Font.CR_GREEN); y += lh;
		DrawHudLine(x, y, String.Format("DMGTORSOMULT = %.2f", HudUpperMult), Font.CR_GREEN);
	}

	ui void DrawHudLine(int x, int y, String text, int fontColor)
	{
		Screen.DrawText(SmallFont, fontColor, x, y, text,
			DTA_VirtualWidth, 640, DTA_VirtualHeight, 480);
	}

	ui int HealthHudColor(int health, int maxHealth)
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
		return Font.CR_BLUE;
	}

	void ToggleDebug()
	{
		PlayerInfo pl = players[consoleplayer];
		if (!pl)
			return;

		let c = CVar.GetCVar("sss_hitbox_debug", pl);
		if (c)
			c.SetBool(!c.GetBool());
	}

	bool GetDebugEnabled(PlayerInfo pl = null)
	{
		if (!pl)
			pl = players[consoleplayer];
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

	double GetFloat(String name, PlayerInfo pl)
	{
		let c = CVar.GetCVar(name, pl);
		return c ? c.GetFloat() : 0.0;
	}

	bool IsValidTarget(Actor mo, Actor viewer, int maxDist, PlayerInfo pl)
	{
		if (!mo || !viewer)
			return false;
		if (mo.bInvisible || mo.bNoClip || mo.bNoBlockMap)
			return false;
		if (!mo.bShootable && !mo.bIsMonster && !mo.CountsAsKill())
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
		if (!mo || mo.player)
			return false;

		if (mo.bIsMonster && mo.health <= 0)
			return true;

		if (mo.bShootable && !mo.bIsMonster)
			return true;

		if (mo.bShootable && !mo.CountsAsKill())
			return true;

		return ClassNameLooksLikeGore(mo.GetClassName());
	}

	bool ClassNameLooksLikeGore(String cn)
	{
		if (cn.IndexOf("Gib") >= 0)
			return true;
		if (cn.IndexOf("GIB") >= 0)
			return true;
		if (cn.IndexOf("gib") >= 0)
			return true;
		if (cn.IndexOf("Gore") >= 0)
			return true;
		if (cn.IndexOf("GORE") >= 0)
			return true;
		if (cn.IndexOf("gore") >= 0)
			return true;
		if (cn.IndexOf("Meat") >= 0)
			return true;
		if (cn.IndexOf("Chunk") >= 0)
			return true;
		if (cn.IndexOf("Ragdoll") >= 0)
			return true;
		if (cn.IndexOf("Bodypart") >= 0)
			return true;
		if (cn.IndexOf("BodyPart") >= 0)
			return true;
		if (cn.IndexOf("Corpse") >= 0)
			return true;
		if (cn.IndexOf("Organ") >= 0)
			return true;
		if (cn.IndexOf("Intestine") >= 0)
			return true;
		if (cn.IndexOf("Remains") >= 0)
			return true;
		if (cn.IndexOf("Debris") >= 0)
			return true;
		return false;
	}

	double GetTraceOffsetZ(Actor viewer)
	{
		if (viewer && viewer.player)
			return viewer.player.viewheight;
		return 41.0;
	}

	Actor GetCrosshairTarget(Actor viewer, int maxDist, PlayerInfo pl)
	{
		if (!viewer || !pl)
			return null;

		FLineTraceData tr;
		if (!viewer.LineTrace(viewer.angle, maxDist, viewer.pitch, TRF_SOLIDACTORS, GetTraceOffsetZ(viewer), 0, 0, tr))
			return null;
		if (tr.HitType != FLineTraceData.TRACE_HitActor || !tr.HitActor)
			return null;
		if (!IsValidTarget(tr.HitActor, viewer, maxDist, pl))
			return null;

		LastHitActor = tr.HitActor;
		LastHitZ = tr.HitLocation.z;
		HasLastHit = true;
		return tr.HitActor;
	}

	int GetMaxHealth(Actor mo)
	{
		if (mo.StartHealth > 0)
			return mo.StartHealth;

		int spawnHealth = mo.GetSpawnHealth();
		if (spawnHealth > 0)
			return spawnHealth;

		return max(mo.health, 1);
	}

	double HealthRatio(Actor mo)
	{
		return clamp(double(mo.health) / max(1, GetMaxHealth(mo)), 0.0, 1.0);
	}

	color HealthColor(Actor mo)
	{
		return HealthColorFromRatio(HealthRatio(mo));
	}

	clearscope color HealthColorFromRatio(double ratio)
	{
		ratio = clamp(ratio, 0.0, 1.0);
		if (ratio >= 0.875)
			return color(48, 255, 64);
		if (ratio >= 0.625)
			return color(255, 255, 48);
		if (ratio >= 0.375)
			return color(255, 140, 32);
		if (ratio >= 0.125)
			return color(255, 32, 48);
		return color(168, 32, 255);
	}

	int ZoneFromHeight(Actor mo, double hitZ, double headMin, double upperMin, double lowerMin)
	{
		double rel = clamp((hitZ - mo.pos.z) / max(1.0, mo.height), 0.0, 1.0);
		if (rel >= headMin)
			return HZ_Head;
		if (rel >= upperMin)
			return HZ_Upper;
		if (rel >= lowerMin)
			return HZ_Lower;
		return HZ_Legs;
	}

	String ZoneName(int zone)
	{
		switch (zone)
		{
		case HZ_Head: return "HEAD";
		case HZ_Upper: return "UPPER TORSO";
		case HZ_Lower: return "LOWER TORSO";
		default: return "LEGS";
		}
	}

	int ZoneHudColor(int zone)
	{
		switch (zone)
		{
		case HZ_Head: return Font.CR_RED;
		case HZ_Upper: return Font.CR_YELLOW;
		case HZ_Lower: return Font.CR_ORANGE;
		default: return Font.CR_LIGHTBLUE;
		}
	}

	clearscope color ZoneWireColor(int zone)
	{
		switch (zone)
		{
		case HZ_Head: return color(255, 48, 48);
		case HZ_Upper: return color(255, 255, 48);
		case HZ_Lower: return color(255, 48, 255);
		default: return color(48, 255, 255);
		}
	}

	double ZoneMultiplier(int zone, double head, double upper, double lower, double legs)
	{
		switch (zone)
		{
		case HZ_Head: return head;
		case HZ_Upper: return upper;
		case HZ_Lower: return lower;
		default: return legs;
		}
	}


	void UpdateFaceVisibility(Actor viewer, double cx, double cy, bool cullBack)
	{
		double toX = viewer.pos.x - cx;
		double toY = viewer.pos.y - cy;

		if (!cullBack)
		{
			VisWest = VisEast = VisSouth = VisNorth = true;
			return;
		}

		VisWest = toX < 0.0;
		VisEast = toX > 0.0;
		VisSouth = toY < 0.0;
		VisNorth = toY > 0.0;

		if (abs(toX) < 0.01)
		{
			VisWest = false;
			VisEast = false;
		}
		if (abs(toY) < 0.01)
		{
			VisSouth = false;
			VisNorth = false;
		}
	}

	void DrawHitbox(Actor mo, Actor viewer, PlayerInfo pl, double step, int life, double psize,
		bool fillFaces, bool wrapVisible)
	{
		if (GetBool("sss_hitbox_sightcull", pl) && !viewer.CheckSight(mo))
			return;

		double r = mo.radius;
		double cx = mo.pos.x;
		double cy = mo.pos.y;
		double zBase = mo.pos.z;
		double zTop = zBase + mo.height;
		bool useHealthColor = GetBool("sss_hitbox_healthcolor", pl);
		bool cullBack = GetBool("sss_hitbox_cullback", pl);

		UpdateFaceVisibility(viewer, cx, cy, cullBack);

		double edgeStep = step * 0.75;
		color healthCol = HealthColor(mo);

		if (useHealthColor)
		{
			DrawZoneBox(mo, cx, cy, r, zBase, zTop, healthCol,
				edgeStep, life, psize, VisWest, VisEast, VisSouth, VisNorth);

			if (wrapVisible)
				DrawVisibleFaceWrap(mo, cx, cy, r, zBase, zTop, edgeStep * 1.5, life, psize * 0.85,
					healthCol, VisWest, VisEast, VisSouth, VisNorth);
		}
		else
		{
			double headMin = GetFloat("sss_hitbox_head_min", pl);
			double upperMin = GetFloat("sss_hitbox_upper_min", pl);
			double lowerMin = GetFloat("sss_hitbox_lower_min", pl);
			double zLegsTop = zBase + mo.height * lowerMin;
			double zLowerTop = zBase + mo.height * upperMin;
			double zUpperTop = zBase + mo.height * headMin;

			DrawZoneBox(mo, cx, cy, r, zBase, zLegsTop, ZoneWireColor(HZ_Legs),
				edgeStep, life, psize, VisWest, VisEast, VisSouth, VisNorth);
			DrawZoneBox(mo, cx, cy, r, zLegsTop, zLowerTop, ZoneWireColor(HZ_Lower),
				edgeStep, life, psize, VisWest, VisEast, VisSouth, VisNorth);
			DrawZoneBox(mo, cx, cy, r, zLowerTop, zUpperTop, ZoneWireColor(HZ_Upper),
				edgeStep, life, psize, VisWest, VisEast, VisSouth, VisNorth);
			DrawZoneBox(mo, cx, cy, r, zUpperTop, zTop, ZoneWireColor(HZ_Head),
				edgeStep, life, psize, VisWest, VisEast, VisSouth, VisNorth);

			if (fillFaces)
				DrawZoneFaceFill(mo, cx, cy, r, zBase, zTop, edgeStep * 2.0, life, psize * 0.65,
					VisWest, VisEast, VisSouth, VisNorth, pl);
		}
	}

	void DrawVisibleFaceWrap(Actor mo, double cx, double cy, double r,
		double zBase, double zTop, double step, int life, double psize, color col,
		bool showWest, bool showEast, bool showSouth, bool showNorth)
	{
		if (zTop <= zBase || step <= 0.0)
			return;

		if (showSouth)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zTop, 0, col, step, life, psize);
		if (showNorth)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zTop, 1, col, step, life, psize);
		if (showWest)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zTop, 2, col, step, life, psize);
		if (showEast)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zTop, 3, col, step, life, psize);
	}

	void DrawZoneBox(Actor mo, double cx, double cy, double r, double z0, double z1, color col,
		double step, int life, double psize,
		bool showWest, bool showEast, bool showSouth, bool showNorth)
	{
		if (z1 <= z0 + 0.25)
			return;

		if (showWest && showSouth)
			DrawVerticalEdge(mo, cx - r, cy - r, z0, z1, col, step, life, psize);
		if (showEast && showSouth)
			DrawVerticalEdge(mo, cx + r, cy - r, z0, z1, col, step, life, psize);
		if (showEast && showNorth)
			DrawVerticalEdge(mo, cx + r, cy + r, z0, z1, col, step, life, psize);
		if (showWest && showNorth)
			DrawVerticalEdge(mo, cx - r, cy + r, z0, z1, col, step, life, psize);

		DrawHorizontalRing(mo, cx, cy, r, z0, showWest, showEast, showSouth, showNorth, col, step, life, psize);
		DrawHorizontalRing(mo, cx, cy, r, z1, showWest, showEast, showSouth, showNorth, col, step, life, psize);
	}

	void DrawZoneFaceFill(Actor mo, double cx, double cy, double r,
		double zBase, double zTop, double step, int life, double psize,
		bool showWest, bool showEast, bool showSouth, bool showNorth, PlayerInfo pl)
	{
		if (zTop <= zBase || step <= 0.0)
			return;

		double headMin = GetFloat("sss_hitbox_head_min", pl);
		double upperMin = GetFloat("sss_hitbox_upper_min", pl);
		double lowerMin = GetFloat("sss_hitbox_lower_min", pl);
		double zLegsTop = zBase + mo.height * lowerMin;
		double zLowerTop = zBase + mo.height * upperMin;
		double zUpperTop = zBase + mo.height * headMin;

		if (showSouth)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zLegsTop, 0, ZoneWireColor(HZ_Legs), step, life, psize);
		if (showNorth)
			DrawFaceGridRange(mo, cx, cy, r, zBase, zLegsTop, 1, ZoneWireColor(HZ_Legs), step, life, psize);
		if (showSouth)
			DrawFaceGridRange(mo, cx, cy, r, zLegsTop, zLowerTop, 0, ZoneWireColor(HZ_Lower), step, life, psize);
		if (showNorth)
			DrawFaceGridRange(mo, cx, cy, r, zLegsTop, zLowerTop, 1, ZoneWireColor(HZ_Lower), step, life, psize);
		if (showSouth)
			DrawFaceGridRange(mo, cx, cy, r, zLowerTop, zUpperTop, 0, ZoneWireColor(HZ_Upper), step, life, psize);
		if (showNorth)
			DrawFaceGridRange(mo, cx, cy, r, zLowerTop, zUpperTop, 1, ZoneWireColor(HZ_Upper), step, life, psize);
		if (showSouth)
			DrawFaceGridRange(mo, cx, cy, r, zUpperTop, zTop, 0, ZoneWireColor(HZ_Head), step, life, psize);
		if (showNorth)
			DrawFaceGridRange(mo, cx, cy, r, zUpperTop, zTop, 1, ZoneWireColor(HZ_Head), step, life, psize);

		if (showWest)
		{
			DrawFaceGridRange(mo, cx, cy, r, zBase, zLegsTop, 2, ZoneWireColor(HZ_Legs), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zLegsTop, zLowerTop, 2, ZoneWireColor(HZ_Lower), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zLowerTop, zUpperTop, 2, ZoneWireColor(HZ_Upper), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zUpperTop, zTop, 2, ZoneWireColor(HZ_Head), step, life, psize);
		}
		if (showEast)
		{
			DrawFaceGridRange(mo, cx, cy, r, zBase, zLegsTop, 3, ZoneWireColor(HZ_Legs), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zLegsTop, zLowerTop, 3, ZoneWireColor(HZ_Lower), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zLowerTop, zUpperTop, 3, ZoneWireColor(HZ_Upper), step, life, psize);
			DrawFaceGridRange(mo, cx, cy, r, zUpperTop, zTop, 3, ZoneWireColor(HZ_Head), step, life, psize);
		}
	}

	void DrawFaceGridRange(Actor emit, double cx, double cy, double r,
		double z0, double z1, int face, color col, double step, int life, double psize)
	{
		if (z1 <= z0)
			return;

		for (double z = z0; z <= z1; z += step)
		{
			if (face == 0)
			{
				for (double x = cx - r; x <= cx + r; x += step)
					SpawnParticleAt(emit, (x, cy - r, z), col, life, psize);
			}
			else if (face == 1)
			{
				for (double x = cx - r; x <= cx + r; x += step)
					SpawnParticleAt(emit, (x, cy + r, z), col, life, psize);
			}
			else if (face == 2)
			{
				for (double y = cy - r; y <= cy + r; y += step)
					SpawnParticleAt(emit, (cx - r, y, z), col, life, psize);
			}
			else
			{
				for (double y = cy - r; y <= cy + r; y += step)
					SpawnParticleAt(emit, (cx + r, y, z), col, life, psize);
			}
		}
	}

	void DrawVerticalEdge(Actor emit, double x, double y, double z0, double z1, color col, double step, int life, double psize)
	{
		if (z1 <= z0)
			return;
		DrawParticleLine(emit, (x, y, z0), (x, y, z1), col, step, life, psize);
	}

	void DrawHorizontalRing(Actor emit, double cx, double cy, double r, double z,
		bool showWest, bool showEast, bool showSouth, bool showNorth,
		color col, double step, int life, double psize)
	{
		if (showSouth)
			DrawParticleLine(emit, (cx - r, cy - r, z), (cx + r, cy - r, z), col, step, life, psize);
		if (showNorth)
			DrawParticleLine(emit, (cx - r, cy + r, z), (cx + r, cy + r, z), col, step, life, psize);
		if (showWest)
			DrawParticleLine(emit, (cx - r, cy - r, z), (cx - r, cy + r, z), col, step, life, psize);
		if (showEast)
			DrawParticleLine(emit, (cx + r, cy - r, z), (cx + r, cy + r, z), col, step, life, psize);
	}

	void DrawParticleLine(Actor emit, Vector3 a, Vector3 b, color col, double step, int life, double psize)
	{
		Vector3 delta = b - a;
		double len = delta.Length();
		if (len < 0.001)
		{
			SpawnParticleAt(emit, a, col, life, psize);
			return;
		}

		int steps = max(1, int(len / step));
		for (int i = 0; i <= steps; i++)
		{
			double t = double(i) / steps;
			SpawnParticleAt(emit, a + delta * t, col, life, psize);
		}
	}

	void SpawnParticleAt(Actor emit, Vector3 pos, color col, int life, double psize)
	{
		emit.A_SpawnParticle(col, SPF_FULLBRIGHT | SPF_NOTIMEFREEZE | SPF_RELPOS, life, psize, 0,
			pos.x - emit.pos.x, pos.y - emit.pos.y, pos.z - emit.pos.z);
	}
}
