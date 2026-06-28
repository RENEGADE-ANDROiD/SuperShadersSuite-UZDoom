class SSSSectorRec
{
	int sec;
	int light;
}

class SSSFluidCandidate
{
	int secnum;
	double area;
	int flatIndex;
}

class SSSLightingHandler : EventHandler
{
	mixin SSSGeo;

	static const int SideTypes[] = {Side.Top, Side.Mid, Side.Bottom};
	static const int LiftSpecials[] = {1, 2, 3, 4, 21, 22, 23, 24, 65, 66, 67, 68, 76, 77, 197, 198, 199, 200};
	const LEFT = 0;
	const RIGHT = 1;

	Array<Sector> biasVisited;
	Array<SSSSectorRec> sectorRecords;
	Array<int> vertexLineStart;
	Array<int> lineFlat;

	bool LightingLoadPending;
	int LightingLoadPhase;
	bool LightingLoadSmoothWalls;
	bool LightingLoadRecursiveRelight;
	bool LightingLoadPerf;
	bool DeferDarkDoomFinish;

	static SSSLightingHandler FindHandler()
	{
		return SSSLightingHandler(EventHandler.Find("SSSLightingHandler"));
	}

	void CompleteMapLoadDarkDoom()
	{
		SSSDarkDoom_Handler ddz = SSSDarkDoom_Handler.FindHandler();
		if (!ddz)
			return;
		ddz.RefreshBaseLightLevelsFromMap();
		ddz.FinishMapLoadLighting();
	}

	override void WorldLoaded(WorldEvent e)
	{
		LightingLoadPending = false;
		LightingLoadPhase = 0;
		DeferDarkDoomFinish = false;

		if (!CVar.FindCVar("sss_lighting").GetBool())
			return;

		bool heavyMap = SSSReflectionHelper.SSS_IsHeavyMap();
		bool mediumMap = SSSReflectionHelper.SSS_IsMediumMap();
		bool mapSafe = CVar.FindCVar("sss_large_map_safe").GetBool();

		if (heavyMap && mapSafe)
		{
			// Synchronous map-load lighting can hard-freeze UZDoom on large maps.
			SSSReflectionHelper.ApplyPlaneReflections();
			return;
		}

		if (heavyMap)
		{
			CVar.FindCVar("sss_relight_recursive").SetBool(false);
			CVar.FindCVar("sss_smooth_walls").SetBool(false);
			CVar.FindCVar("sss_bleed_rg").SetBool(false);
			let procMax = CVar.FindCVar("sss_relight_proc_max");
			if (procMax && procMax.GetInt() > 6)
				procMax.SetInt(6);
		}
		else if (mediumMap && mapSafe)
		{
			CVar.FindCVar("sss_relight_recursive").SetBool(false);
			CVar.FindCVar("sss_smooth_walls").SetBool(false);
			CVar.FindCVar("sss_bleed_rg").SetBool(false);
		}

		LightingLoadPerf = CVar.FindCVar("sss_performance").GetBool() || heavyMap;
		LightingLoadSmoothWalls = CVar.FindCVar("sss_smooth_walls").GetBool()
			&& !LightingLoadPerf;
		LightingLoadRecursiveRelight = CVar.FindCVar("sss_relight_recursive").GetBool();

		// Spread map-load work across ticks when safe mode is on.
		bool fastApply = SSSReflectionHelper.IsPresetFastApply();
		if (mapSafe && fastApply && !heavyMap && Level.Sectors.Size() < 512)
			RunLightingLoadSync();
		else if (mapSafe)
			QueueChunkedLightingLoad();
		else
			RunLightingLoadSync();
	}

	bool IsLightingLoadPending()
	{
		return LightingLoadPending;
	}

	void QueueChunkedLightingLoad()
	{
		LightingLoadPhase = 0;
		LightingLoadPending = true;
	}

	void RunLightingLoadSync()
	{
		if (CVar.FindCVar("sss_bias").GetBool())
			BiasLighting();

		if (LightingLoadSmoothWalls)
		{
			PrepareSectors();
			BuildVertexLineMap();
			SmoothWallLights();
		}

		if (!LightingLoadPerf)
		{
			if (!LightingLoadRecursiveRelight)
				ApplySectorColorBleed();
			ApplyWallColorization();
		}

		SSSRelightEnhance enh = new("SSSRelightEnhance");
		enh.RunApplyAll();
		ApplyFluidLighting();
		SSSReflectionHelper.ApplyPlaneReflections();
	}

	void AdvanceLightingLoadOnePhase()
	{
		switch (LightingLoadPhase)
		{
		case 0:
			if (CVar.FindCVar("sss_bias").GetBool())
				BiasLighting();
			LightingLoadPhase = 1;
			break;

		case 1:
			if (LightingLoadSmoothWalls)
			{
				PrepareSectors();
				BuildVertexLineMap();
				SmoothWallLights();
			}
			LightingLoadPhase = 2;
			break;

		case 2:
			if (!LightingLoadPerf)
			{
				if (!LightingLoadRecursiveRelight)
					ApplySectorColorBleed();
				ApplyWallColorization();
			}
			LightingLoadPhase = 3;
			break;

		case 3:
			{
				SSSRelightEnhance enh = new("SSSRelightEnhance");
				enh.RunApplyAll();
			}
			LightingLoadPhase = 4;
			break;

		case 4:
			ApplyFluidLighting();
			SSSReflectionHelper.ApplyPlaneReflections();
			LightingLoadPending = false;
			if (DeferDarkDoomFinish)
			{
				DeferDarkDoomFinish = false;
				CompleteMapLoadDarkDoom();
			}
			break;
		}
	}

	override void WorldTick()
	{
		if (!LightingLoadPending)
			return;

		int steps = SSSReflectionHelper.IsPresetFastApply() ? 2 : 1;
		for (int i = 0; i < steps && LightingLoadPending; i++)
			AdvanceLightingLoadOnePhase();
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "sss_apply_reflections")
			SSSReflectionHelper.ApplyPlaneReflections();
	}

	bool IsWhiteColor(Color c)
	{
		return c.r > 248 && c.g > 248 && c.b > 248;
	}

	double GetHue(Color c)
	{
		double r = c.r / 255.0;
		double g = c.g / 255.0;
		double b = c.b / 255.0;
		double minc = min(min(r, g), b);
		double maxc = max(max(r, g), b);
		if (minc == maxc)
			return 0;
		double hue = maxc == r ? (g - b) / (maxc - minc) :
			(maxc == g ? 2.0 + (b - r) / (maxc - minc) : 4.0 + (r - g) / (maxc - minc));
		hue *= 60;
		if (hue < 0)
			hue += 360;
		return hue;
	}

	Color BlendColors(Color c1, Color c2)
	{
		int r = int(sqrt((c1.r * c1.r + c2.r * c2.r) * 0.5));
		int g = int(sqrt((c1.g * c1.g + c2.g * c2.g) * 0.5));
		int b = int(sqrt((c1.b * c1.b + c2.b * c2.b) * 0.5));
		return Color(r, g, b);
	}

	Color SaturateColor(Color c, double amount)
	{
		double hue = GetHue(c);
		double sat = clamp(amount, 0, 1);
		double val = max(max(c.r, c.g), c.b) / 255.0;
		int r, g, b;
		[r, g, b] = HsvToRgb(hue, sat * 100, val * 100);
		return Color(r, g, b);
	}

	int, int, int HsvToRgb(double h, double s, double v)
	{
		h /= 360;
		s /= 100;
		v /= 100;
		double r, g, b, i, f, p, q, t;
		i = int(h * 6);
		f = h * 6 - i;
		p = v * (1 - s);
		q = v * (1 - f * s);
		t = v * (1 - (1 - f) * s);
		switch (i % 6)
		{
			case 0: r = v; g = t; b = p; break;
			case 1: r = q; g = v; b = p; break;
			case 2: r = p; g = v; b = t; break;
			case 3: r = p; g = q; b = v; break;
			case 4: r = t; g = p; b = v; break;
			default: r = v; g = p; b = q; break;
		}
		return int(r * 255 + 0.5), int(g * 255 + 0.5), int(b * 255 + 0.5);
	}

	void ApplySectorColorBleed()
	{
		if (!CVar.FindCVar("sss_color_sec").GetBool())
			return;

		bool colorSprites = CVar.FindCVar("sss_color_spr").GetBool();

		foreach (sec : Level.Sectors)
		{
			Color src = sec.ColorMap.LightColor;
			if (IsWhiteColor(src))
				continue;

			foreach (lin : sec.Lines)
			{
				if (lin.delta.length() < 16)
					continue;

				Sector bsec = BackSector(sec, lin);
				if (!bsec)
					continue;

				vector2 mid = GetMiddle(lin);
				if (sec.CeilingPlane.ZAtPoint(mid) < bsec.CeilingPlane.ZAtPoint(mid))
					continue;

				double hue = GetHue(src);
				if (hue >= 210 && hue <= 270)
					continue;

				Color dst = bsec.ColorMap.LightColor;
				Color outc = IsWhiteColor(dst) ? src : BlendColors(dst, src);
				bsec.SetColor(SaturateColor(outc, bsec.LightLevel / 1280.0));

				if (colorSprites)
					bsec.SetSpecialColor(Sector.sprites, SaturateColor(outc, bsec.LightLevel / 320.0));
			}
		}
	}

	void ApplyWallColorization()
	{
		if (!CVar.FindCVar("sss_color_walls").GetBool())
			return;

		Texman texture;

		foreach (sec : Level.Sectors)
		{
			Color c = sec.ColorMap.LightColor;
			if (IsWhiteColor(c))
				continue;

			double hue = GetHue(c);
			int deg = int(hue / 5.0 + 0.5) * 5;
			if (deg >= 360)
				deg = 0;
			String colorName = String.Format("deg%d", deg);

			foreach (lin : sec.Lines)
			{
				int fside = (lin.FrontSector != sec) ? Line.Back : Line.Front;
				Side wall = lin.Sidedef[fside];
				if (!wall)
					continue;

				foreach (sid : SideTypes)
				{
					if (texture.GetName(wall.GetTexture(sid)) != "")
						wall.SetColorization(sid, colorName);
				}
			}
		}
	}

	void BiasLighting()
	{
		double darken = CVar.FindCVar("sss_darken").GetFloat();
		double brighten = CVar.FindCVar("sss_brighten").GetFloat();
		biasVisited.Clear();

		foreach (sec : Level.Sectors)
		{
			if (biasVisited.Find(sec) != biasVisited.Size())
				continue;

			foreach (lin : sec.Lines)
			{
				if (!(lin.Flags & Line.ML_TWOSIDED))
					continue;

				Sector bsec = BackSector(sec, lin);
				if (!bsec || biasVisited.Find(bsec) != biasVisited.Size())
					continue;

				vector2 mid = GetMiddle(lin);
				double diff = abs(sec.FloorPlane.ZAtPoint(mid) - bsec.FloorPlane.ZAtPoint(mid));
				if (diff >= 96.0)
					continue;

				biasVisited.Push(bsec);
				if (bsec.LightLevel == sec.LightLevel)
					continue;

				double weight = bsec.LightLevel > sec.LightLevel ? darken :
					(bsec.LightLevel < sec.LightLevel ? brighten : 0.5);
				bsec.LightLevel = int((bsec.LightLevel + sec.LightLevel) * weight);
			}
		}
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

	bool IsDarkDoomSectorDarkeningActive()
	{
		int mode = CVar.FindCVar("ddz_mode").GetInt();
		if (mode == 0)
			return false;
		if (mode >= 10)
			return true;
		return CVar.FindCVar("ddz_preset").GetInt() != 0;
	}

	void PrepareSectors()
	{
		double additive = CVar.FindCVar("sss_additive").GetFloat();
		double wallBake = CVar.FindCVar("sss_wall_bake").GetFloat();
		bool skipLightCut = IsDarkDoomSectorDarkeningActive();
		Texman texture;
		sectorRecords.Clear();

		foreach (sec : Level.Sectors)
		{
			if (sec.Lines.Size() < 3)
				continue;

			let rec = new("SSSSectorRec");
			rec.sec = sec.SectorNum;
			rec.light = sec.LightLevel;
			sectorRecords.Push(rec);

			if (IsLiftSpecial(sec.Special))
				continue;

			sec.SetPlaneLight(Sector.Floor, -int(sec.LightLevel * (1.0 - additive) * 0.2));
			sec.SetPlaneLight(Sector.Ceiling, -int(sec.LightLevel * (1.0 - additive) * 0.2));
			if (!skipLightCut)
				sec.LightLevel = clamp(sec.LightLevel - int(sec.LightLevel * additive), 0, 255);

			int wlight = int(sec.LightLevel * additive);
			int wallBakeRelief = int(wlight * wallBake * 0.70);
			int wallBakeFill = int(sec.LightLevel * wallBake * 0.10);
			foreach (lin : sec.Lines)
			{
				int fside = (lin.FrontSector != sec) ? Line.Back : Line.Front;
				Side wall = lin.Sidedef[fside];
				if (!wall)
					continue;

				int parts = 0;
				foreach (sid : SideTypes)
				{
					if (texture.GetName(wall.GetTexture(sid)) != "")
						parts++;
				}
				if (parts == 0)
					continue;

				wall.flags = wall.flags | Side.WALLF_SMOOTHLIGHTING | Side.WALLF_NOFAKECONTRAST;
				wall.Light -= max(0, wlight - wallBakeRelief);
				wall.Light += wallBakeFill;
			}
		}
	}

	void BuildVertexLineMap()
	{
		lineFlat.Clear();
		vertexLineStart.Clear();

		int n = Level.Vertexes.Size();
		if (n < 1)
			return;

		vertexLineStart.Resize(n + 1);
		for (int i = 0; i <= n; i++)
			vertexLineStart[i] = 0;

		foreach (lin : Level.Lines)
		{
			int i1 = lin.v1.Index();
			int i2 = lin.v2.Index();
			if (i1 >= 0 && i1 < n) vertexLineStart[i1]++;
			if (i2 >= 0 && i2 < n) vertexLineStart[i2]++;
		}

		int sum = 0;
		for (int i = 0; i < n; i++)
		{
			int c = vertexLineStart[i];
			vertexLineStart[i] = sum;
			sum += c;
		}
		vertexLineStart[n] = sum;

		lineFlat.Resize(sum);
		Array<int> vtxCursor;
		vtxCursor.Resize(n);
		for (int i = 0; i < n; i++)
			vtxCursor[i] = vertexLineStart[i];

		foreach (lin : Level.Lines)
		{
			int li = lin.Index();
			int i1 = lin.v1.Index();
			int i2 = lin.v2.Index();
			if (i1 >= 0 && i1 < n) lineFlat[vtxCursor[i1]++] = li;
			if (i2 >= 0 && i2 < n) lineFlat[vtxCursor[i2]++] = li;
		}
	}

	Line FindAdjacent(Line lin, int dir)
	{
		double linAngle = VectorAngle(lin.delta.x, lin.delta.y);
		Line result = null;
		Array<Line> adjLines;
		Vertex pivot = dir == LEFT ? lin.v1 : lin.v2;
		int vi = pivot.Index();
		int vn = vertexLineStart.Size() > 0 ? vertexLineStart.Size() - 1 : 0;

		if (vi >= 0 && vi < vn)
		{
			int a = vertexLineStart[vi];
			int b = vertexLineStart[vi + 1];
			for (int k = a; k < b; k++)
			{
				Line slin = Level.Lines[lineFlat[k]];
				if (slin == lin)
					continue;
				if (dir == LEFT && slin.v2 == pivot)
					adjLines.Push(slin);
				if (dir == RIGHT && slin.v1 == pivot)
					adjLines.Push(slin);
			}
		}

		double diff = double.infinity;
		foreach (slin : adjLines)
		{
			double angleDiff = Actor.AbsAngle(VectorAngle(slin.delta.x, slin.delta.y), linAngle);
			if (angleDiff < diff)
			{
				diff = angleDiff;
				if (diff < 45)
				{
					result = slin;
					break;
				}
			}
		}
		return result;
	}

	int, int FindAdjacentLight(Line lin, Sector sec)
	{
		Sector frontSec = lin.FrontSector;
		if (frontSec == sec)
		{
			Side wall = lin.Sidedef[Line.Front];
			return wall.index(), wall.Light;
		}

		foreach (slin : frontSec.Lines)
		{
			if (slin == lin)
				continue;
			if (!(slin.Flags & Line.ML_TWOSIDED))
				continue;

			Sector bsec = BackSector(frontSec, slin);
			if (bsec == sec)
			{
				Side wall = lin.Sidedef[Line.Front];
				return wall.index(), wall.Light;
			}
		}

		Side backWall = lin.Sidedef[Line.Back];
		if (backWall)
			return backWall.index(), backWall.Light;

		return -1, 666;
	}

	void SmoothWallLights()
	{
		Texman texture;

		foreach (rec : sectorRecords)
		{
			if (rec.light == 0)
				continue;

			Sector sec = Level.Sectors[rec.sec];
			foreach (lin : sec.Lines)
			{
				if (lin.delta.length() < 4)
					continue;

				int fside = (lin.FrontSector != sec) ? Line.Back : Line.Front;
				Side wall = lin.Sidedef[fside];
				if (!wall)
					continue;

				int parts = 0;
				foreach (sid : SideTypes)
				{
					if (texture.GetName(wall.GetTexture(sid)) != "")
						parts++;
				}
				if (parts == 0)
					continue;

				int leftLight = 666;
				int rightLight = 666;
				Line adj = FindAdjacent(lin, LEFT);
				if (adj && adj.delta.length() > 4)
				{
					int unusedSide;
					[unusedSide, leftLight] = FindAdjacentLight(adj, sec);
				}

				adj = FindAdjacent(lin, RIGHT);
				if (adj && adj.delta.length() > 4)
				{
					int unusedSide;
					[unusedSide, rightLight] = FindAdjacentLight(adj, sec);
				}

				if (leftLight != 666 && rightLight != 666)
					wall.Light = int((wall.Light + leftLight + rightLight) * 0.333);
				else if (leftLight == 666 && rightLight != 666)
					wall.Light = int((wall.Light + rightLight) * 0.5);
				else if (leftLight != 666 && rightLight == 666)
					wall.Light = int((wall.Light + leftLight) * 0.5);
			}
		}
	}

	static const Name FluidFlats[] =
	{
		"NUKAGE", "SLIME01", "SLIME02", "SLIME03", "SLIME04",
		"FWATER1", "FWATER2", "FWATER3", "FWATER4",
		"LAVA1", "LAVA2", "LAVA3", "LAVA4",
		"BLOOD1", "BLOOD2", "BLOOD3",
		"FLTWAWA1", "FLTSLUD1", "FLTFLWW1", "FLTLAVA1", "FLATHUH1",
		"X_001", "X_002", "X_003", "X_004"
	};

	static const Color FluidColors[] =
	{
		Color(0, 200, 0), Color(0, 180, 0), Color(0, 160, 0), Color(0, 140, 0), Color(0, 120, 0),
		Color(0, 80, 200), Color(0, 90, 210), Color(0, 100, 220), Color(0, 110, 230),
		Color(255, 120, 0), Color(255, 100, 0), Color(255, 80, 0), Color(255, 60, 0),
		Color(180, 0, 0), Color(160, 0, 0), Color(140, 0, 0),
		Color(0, 90, 210), Color(80, 120, 60), Color(0, 100, 220), Color(255, 90, 0), Color(255, 110, 20),
		Color(0, 85, 205), Color(0, 95, 215), Color(255, 85, 0), Color(200, 40, 0)
	};

	int FindFluidFlatIndex(Name flatName)
	{
		for (int i = 0; i < FluidFlats.Size(); i++)
		{
			if (flatName == FluidFlats[i])
				return i;
		}
		return -1;
	}

	vector2 SectorCenter(Sector sec)
	{
		return SSSRelightEnhance.SectorLightSpot(sec);
	}

	double SectorBBoxArea(Sector sec)
	{
		double minx = double.infinity, miny = double.infinity;
		double maxx = -double.infinity, maxy = -double.infinity;
		foreach (lin : sec.Lines)
		{
			minx = min(minx, min(lin.v1.p.x, lin.v2.p.x));
			miny = min(miny, min(lin.v1.p.y, lin.v2.p.y));
			maxx = max(maxx, max(lin.v1.p.x, lin.v2.p.x));
			maxy = max(maxy, max(lin.v1.p.y, lin.v2.p.y));
		}
		return (maxx - minx) * (maxy - miny);
	}

	void ApplyFluidLighting()
	{
		double glowStrength = CVar.FindCVar("sss_flat_glow").GetFloat();
		double wallBoost = CVar.FindCVar("sss_wall_glow").GetFloat();
		double lightStrength = CVar.FindCVar("sss_flat_lights").GetFloat();
		if (glowStrength <= 0 && wallBoost <= 0 && lightStrength <= 0)
			return;

		bool perf = CVar.FindCVar("sss_performance").GetBool();
		int glowBudget = perf ? 48 : 128;
		int lightMax = CVar.FindCVar("sss_flat_light_max").GetInt();
		if (perf)
			lightMax = min(lightMax, 8);
		double minLightSize = CVar.FindCVar("sss_flat_light_minsize").GetFloat();
		double minLightArea = minLightSize * minLightSize;
		double minGlowArea = 28.0 * 28.0;

		int glowCount = 0;
		Texman texture;
		Array<SSSFluidCandidate> lightCandidates;

		foreach (sec : Level.Sectors)
		{
			Name floorName = texture.GetName(sec.GetTexture(Sector.Floor));
			int fidx = FindFluidFlatIndex(floorName);
			if (fidx < 0)
				continue;

			double area = SectorBBoxArea(sec);
			if (area < minGlowArea)
				continue;

			if (glowCount < glowBudget && (glowStrength > 0 || wallBoost > 0))
			{
				glowCount++;
				Color fc = FluidColors[fidx];
				vector2 center = SectorCenter(sec);
				double ceilZ = sec.CeilingPlane.ZAtPoint(center);
				double floorZ = sec.FloorPlane.ZAtPoint(center);
				double height = max(8.0, ceilZ - floorZ);

				if (glowStrength > 0)
				{
					sec.SetGlowColor(Sector.Floor, fc);
					sec.SetGlowHeight(Sector.Floor, min(72.0, height * 0.3) * glowStrength);
					int boost = int(24.0 * glowStrength * (sec.LightLevel / 255.0));
					sec.SetPlaneLight(Sector.Floor, sec.GetFloorLight() + boost);
				}

				if (wallBoost > 0)
				{
					int addLight = int(16.0 * wallBoost);
					foreach (lin : sec.Lines)
					{
						for (int s = 0; s < 2; s++)
						{
							Side wall = lin.Sidedef[s];
							if (!wall)
								continue;
							wall.Light = clamp(wall.Light + addLight, 0, 255);
						}
					}
				}
			}

			if (lightStrength > 0 && lightMax > 0 && area >= minLightArea)
			{
				let cand = new("SSSFluidCandidate");
				cand.secnum = sec.SectorNum;
				cand.area = area;
				cand.flatIndex = fidx;
				lightCandidates.Push(cand);
			}
		}

		SpawnFluidPointLights(lightCandidates, lightMax, lightStrength, perf);
	}

	Color FluidLightColor(Color base, int lightLevel, double strength)
	{
		double scale = clamp(strength * (lightLevel / 255.0), 0.15, 1.25);
		return Color(
			clamp(int(base.r * 0.55 * scale + 24), 0, 255),
			clamp(int(base.g * 0.55 * scale + 24), 0, 255),
			clamp(int(base.b * 0.55 * scale + 24), 0, 255));
	}

	void SpawnFluidPointLights(Array<SSSFluidCandidate> candidates, int lightMax, double strength, bool perf)
	{
		if (candidates.Size() == 0 || lightMax <= 0 || strength <= 0)
			return;

		int spawnCount = min(lightMax, candidates.Size());
		for (int n = 0; n < spawnCount; n++)
		{
			int best = 0;
			for (int i = 1; i < candidates.Size(); i++)
			{
				if (candidates[i].area > candidates[best].area)
					best = i;
			}

			SSSFluidCandidate cand = candidates[best];
			candidates.Delete(best);

			Sector sec = Level.Sectors[cand.secnum];
			vector2 center = SectorCenter(sec);
			double floorZ = sec.FloorPlane.ZAtPoint(center);
			Color lc = FluidLightColor(FluidColors[cand.flatIndex], sec.LightLevel, strength);

			let anchor = sss_lightanchor(Actor.Spawn("sss_lightanchor", (center.x, center.y, floorZ + 12.0), NO_REPLACE));
			if (!anchor)
				continue;

			double side = sqrt(cand.area);
			double outer = clamp((48.0 + side * 0.22) * strength, 40.0, perf ? 112.0 : 144.0);

			anchor.A_AttachLight("sss_fluid",
				DynamicLight.SectorLight,
				lc,
				0,
				0,
				DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_SPOT | DYNAMICLIGHT.LF_DONTLIGHTACTORS,
				spoti: 14.0 * strength + 8.0,
				spoto: outer,
				spotp: 88.0);
		}
	}
}
