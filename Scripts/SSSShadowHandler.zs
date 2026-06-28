class sss_floorshadow : Actor
{
	int lifespan;
	Default
	{
		RenderStyle "Stencil";
		StencilColor "Black";
		+FLATSPRITE
		+NOINTERACTION
		+NOTONAUTOMAP
		+NOBLOCKMAP
		+DONTSPLASH
	}
	States
	{
	Spawn:
		SSSH A -1;
		Stop;
	}
	override void Tick()
	{
		Super.Tick();
		if (lifespan > 0 && --lifespan <= 0)
			Destroy();
	}
}

class sss_shade : CustomInventory
{
	Default
	{
		+Inventory.AutoActivate
		Inventory.MaxAmount 1;
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (Owner && !Owner.FindInventory("sss_shadowthinker"))
			Owner.A_GiveInventory("sss_shadowthinker", 1);
		self.Destroy();
	}
	States
	{
	Use:
		TNT1 A 0;
		Stop;
	}
}

class sss_shadowthinker : CustomInventory
{
	Default
	{
		+Inventory.Undroppable
		+Inventory.KeepDepleted
		Inventory.MaxAmount 1;
	}
	States
	{
	Use:
		TNT1 A 0;
		Stop;
	}
}

class SSSShadowHandler : EventHandler
{
	static const int MaxFloorShadows[] = {8};
	static const int MaxWallShadows[] = {2};
	static const int MaxScanActors[] = {24};

	override void WorldThingSpawned(WorldEvent e)
	{
		if (!CVar.FindCVar("sss_shadows").GetBool() || !e.thing)
			return;

		if (e.thing.bInvisible || e.thing.bNoBlockMap || e.thing.bNoClip)
			return;

		bool players = CVar.FindCVar("sss_shadow_players").GetBool();
		bool monsters = CVar.FindCVar("sss_shadow_monsters").GetBool();

		if (e.thing.player && players)
		{
			e.thing.A_GiveInventory("sss_shade", 1);
			return;
		}

		if (monsters && e.thing.CountsAsKill() && e.thing.health > 0 && e.thing.height >= 16)
			e.thing.A_GiveInventory("sss_shade", 1);
	}

	override void WorldTick()
	{
		if (!CVar.FindCVar("sss_shadows").GetBool())
			return;

		if (CVar.FindCVar("sss_performance").GetBool())
			return;

		int interval = max(2, CVar.FindCVar("sss_shadow_interval").GetInt());
		if (Level.MapTime % interval != 0)
			return;

		bool wallShadows = CVar.FindCVar("sss_wall_shadows").GetBool();
		double maxDist = 640.0;
		PlayerInfo viewer = players[consoleplayer];
		if (!viewer || !viewer.mo)
			return;

		BlockThingsIterator it = BlockThingsIterator.Create(viewer.mo, maxDist);
		int floorCount = 0;
		int wallCount = 0;
		int scanned = 0;

		while (it.Next())
		{
			if (++scanned > MaxScanActors[0])
				break;

			Actor mo = it.thing;
			if (!mo || !mo.health)
				continue;
			if (!mo.FindInventory("sss_shadowthinker"))
				continue;
			if (mo.bInvisible || mo.bNoClip)
				continue;
			if (mo.Distance2D(viewer.mo) > maxDist)
				continue;

			if (floorCount < MaxFloorShadows[0])
			{
				double floorz = mo.floorz;
				if (floorz >= mo.pos.z - 4)
					floorz = mo.pos.z - mo.height * 0.05;

				let shadow = sss_floorshadow(Actor.Spawn("sss_floorshadow", (mo.pos.x, mo.pos.y, floorz + 0.5), NO_REPLACE));
				if (shadow)
				{
					double s = clamp(mo.radius / 24.0, 0.35, 1.4);
					shadow.scale = (s, s * 0.55);
					shadow.spriteAngle = mo.angle + 180;
					shadow.lifespan = interval + 2;
					shadow.SetStateLabel("Spawn");
					floorCount++;
				}
			}

			if (wallShadows && wallCount < MaxWallShadows[0])
			{
				if (SpawnWallShadowLite(mo, viewer.mo, interval, int(maxDist)))
					wallCount++;
			}
		}
	}

	bool SpawnWallShadowLite(Actor mo, Actor viewer, int interval, int maxDist)
	{
		double away = mo.AngleTo(viewer) + 180.0;
		FLineTraceData tr;
		if (!mo.LineTrace(away, min(maxDist, 320), 0, 0, mo.height * 0.35, 0, 0, tr))
			return false;
		if (tr.HitType != FLineTraceData.TRACE_HitWall)
			return false;

		let ws = sss_wallshadow(Actor.Spawn("sss_wallshadow", tr.HitLocation, NO_REPLACE));
		if (!ws)
			return false;

		double s = clamp(mo.radius / 24.0, 0.35, 1.2);
		ws.scale = (s * 0.9, s * 0.55);
		ws.spriteAngle = away;
		ws.alpha = 0.35;
		ws.lifespan = interval + 2;
		ws.SetStateLabel("Spawn");
		return true;
	}
}
