// Lite door / lift light spill — Relighting-inspired, runtime only on moving sectors.

class SSSDoorTrack
{
	int SecNum;
	vector2 Spot;
	double BaseFloorZ;
	double BaseCeilZ;
	int BrightLight;
	int DarkLight;
	double AimAngle;
	bool IsLift;
	sss_proplight Light;
}

class SSSDoorLightHandler : EventHandler
{
	mixin SSSGeo;

	Array<SSSDoorTrack> Tracks;
	bool Built;
	bool LastEnabled;

	static const int LiftSpecials[] = {1, 2, 3, 4, 21, 22, 23, 24, 65, 66, 67, 68, 76, 77, 197, 198, 199, 200};

	override void WorldLoaded(WorldEvent e)
	{
		Built = false;
		LastEnabled = false;
		ClearAllLights();
		Tracks.Clear();
		RebuildIfNeeded(true);
	}

	override void WorldTick()
	{
		if (!CVar.FindCVar("sss_lighting").GetBool())
		{
			if (Built && HasActiveLights())
				ClearAllLights();
			return;
		}

		if (!Built)
			RebuildIfNeeded(false);

		if (!Built || Tracks.Size() == 0)
			return;

		if (!CVar.FindCVar("sss_relight_doors").GetBool() || CVar.FindCVar("sss_performance").GetBool())
		{
			if (HasActiveLights())
				ClearAllLights();
			return;
		}

		int interval = max(1, CVar.FindCVar("sss_relight_door_interval").GetInt());
		if (Level.MapTime % interval != 0)
			return;

		UpdateTracks();
	}

	void RebuildIfNeeded(bool force)
	{
		bool enabled = CVar.FindCVar("sss_relight_doors").GetBool()
			&& CVar.FindCVar("sss_lighting").GetBool()
			&& !CVar.FindCVar("sss_performance").GetBool();

		if (!force && enabled == LastEnabled && Built)
			return;

		LastEnabled = enabled;
		ClearAllLights();
		Tracks.Clear();
		Built = false;

		if (!enabled)
			return;

		BuildTracks();
		Built = Tracks.Size() > 0;
	}

	void BuildTracks()
	{
		foreach (sec : Level.Sectors)
		{
			SSSDoorTrack track;
			if (TryRegisterDoor(sec, track))
				Tracks.Push(track);
		}
	}

	bool TryRegisterDoor(Sector sec, out SSSDoorTrack track)
	{
		if (sec.Lines.Size() < 3)
			return false;
		if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
			return false;

		vector2 spot = SectorBBoxCenter(sec);
		double fz = sec.FloorPlane.ZAtPoint(spot);
		double cz = sec.CeilingPlane.ZAtPoint(spot);
		double span = cz - fz;
		if (span < 4 || span > 192)
			return false;

		double minx = double.infinity;
		double maxx = -double.infinity;
		double miny = double.infinity;
		double maxy = -double.infinity;
		for (int i = 0; i < sec.Lines.Size(); i++)
		{
			Line lin = sec.Lines[i];
			minx = min(minx, min(lin.v1.p.x, lin.v2.p.x));
			maxx = max(maxx, max(lin.v1.p.x, lin.v2.p.x));
			miny = min(miny, min(lin.v1.p.y, lin.v2.p.y));
			maxy = max(maxy, max(lin.v1.p.y, lin.v2.p.y));
		}
		if ((maxx - minx) * (maxy - miny) > 128.0 * 160.0)
			return false;

		int brightLight = sec.LightLevel;
		int darkLight = sec.LightLevel;
		Sector brightSec = sec;
		Sector darkSec = sec;
		int twoSided = 0;

		for (int i = 0; i < sec.Lines.Size(); i++)
		{
			Sector back = BackSector(sec, sec.Lines[i]);
			if (!back)
				continue;
			twoSided++;
			if (back.LightLevel >= brightLight)
			{
				brightLight = back.LightLevel;
				brightSec = back;
			}
			if (back.LightLevel <= darkLight)
			{
				darkLight = back.LightLevel;
				darkSec = back;
			}
		}

		if (twoSided < 2 || brightLight - darkLight < 16)
			return false;

		track = new("SSSDoorTrack");
		vector2 aim = SectorBBoxCenter(darkSec != sec ? darkSec : brightSec);
		track.SecNum = sec.SectorNum;
		track.Spot = spot;
		track.BaseFloorZ = fz;
		track.BaseCeilZ = cz;
		track.BrightLight = brightLight;
		track.DarkLight = darkLight;
		track.AimAngle = VectorAngle(aim.x - spot.x, aim.y - spot.y);
		track.IsLift = IsLiftSpecial(sec.Special);
		track.Light = null;
		return true;
	}

	bool IsLiftSpecial(int special)
	{
		for (int i = 0; i < LiftSpecials.Size(); i++)
		{
			if (LiftSpecials[i] == special)
				return true;
		}
		return false;
	}

	vector2 SectorBBoxCenter(Sector sec)
	{
		double minx = double.infinity;
		double maxx = -double.infinity;
		double miny = double.infinity;
		double maxy = -double.infinity;
		for (int i = 0; i < sec.Lines.Size(); i++)
		{
			Line lin = sec.Lines[i];
			minx = min(minx, min(lin.v1.p.x, lin.v2.p.x));
			maxx = max(maxx, max(lin.v1.p.x, lin.v2.p.x));
			miny = min(miny, min(lin.v1.p.y, lin.v2.p.y));
			maxy = max(maxy, max(lin.v1.p.y, lin.v2.p.y));
		}
		return ((minx + maxx) * 0.5, (miny + maxy) * 0.5);
	}

	double ComputeOpenness(Sector sec, SSSDoorTrack track)
	{
		double curFloor = sec.FloorPlane.ZAtPoint(track.Spot);
		double curCeil = sec.CeilingPlane.ZAtPoint(track.Spot);
		double floorDelta = curFloor - track.BaseFloorZ;
		double ceilDelta = track.BaseCeilZ - curCeil;

		if (track.IsLift && abs(floorDelta - ceilDelta) < 4.0 && abs(floorDelta) > 6.0)
			return clamp(abs(floorDelta) / 128.0, 0.0, 1.0);

		double span = track.BaseCeilZ - track.BaseFloorZ;
		if (span < 4)
			return 0;

		return clamp(max(floorDelta / span, ceilDelta / span), 0.0, 1.0);
	}

	void UpdateTracks()
	{
		PlayerInfo view = players[consoleplayer];
		Actor viewer = view ? view.mo : null;
		double strength = CVar.FindCVar("sss_relight_door_strength").GetFloat();
		int maxActive = max(1, CVar.FindCVar("sss_relight_door_max").GetInt());
		int active = 0;

		for (int i = 0; i < Tracks.Size(); i++)
		{
			Sector sec = Level.Sectors[Tracks[i].SecNum];
			if (!sec)
			{
				DestroyTrackLight(Tracks[i]);
				continue;
			}

			if (viewer)
			{
				double dx = viewer.pos.x - Tracks[i].Spot.x;
				double dy = viewer.pos.y - Tracks[i].Spot.y;
				if (dx * dx + dy * dy > 802816.0)
				{
					DestroyTrackLight(Tracks[i]);
					continue;
				}
			}

			double openness = ComputeOpenness(sec, Tracks[i]);
			if (openness < 0.06 || active >= maxActive)
			{
				DestroyTrackLight(Tracks[i]);
				continue;
			}

			double curFloor = sec.FloorPlane.ZAtPoint(Tracks[i].Spot);
			double curCeil = sec.CeilingPlane.ZAtPoint(Tracks[i].Spot);
			double z = curFloor + (curCeil - curFloor) * (0.35 + openness * 0.35);

			if (!Tracks[i].Light)
			{
				Tracks[i].Light = sss_proplight(Actor.Spawn("sss_proplight", (Tracks[i].Spot.x, Tracks[i].Spot.y, z), NO_REPLACE));
				if (!Tracks[i].Light)
					continue;
			}
			else
			{
				Tracks[i].Light.SetOrigin((Tracks[i].Spot.x, Tracks[i].Spot.y, z), false);
			}

			Tracks[i].Light.ConfigureDoor(Tracks[i].BrightLight, openness, strength, Tracks[i].AimAngle, 78.0);
			active++;
		}
	}

	void DestroyTrackLight(SSSDoorTrack track)
	{
		if (track.Light)
		{
			track.Light.Destroy();
			track.Light = null;
		}
	}

	bool HasActiveLights()
	{
		for (int i = 0; i < Tracks.Size(); i++)
		{
			if (Tracks[i].Light)
				return true;
		}
		return false;
	}

	void ClearAllLights()
	{
		for (int i = 0; i < Tracks.Size(); i++)
			DestroyTrackLight(Tracks[i]);
	}
}
