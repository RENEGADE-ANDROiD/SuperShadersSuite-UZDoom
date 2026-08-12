// RT-Relight enhancements — Relighting-inspired world lighting (performance-tiered).
// Flat/palette sector color, recursive bleed, procedural lights, polylabel placement.

class SSSRelightEnhance
{
	Array<Color> FlatColors;
	Array<Name> FlatNames;
	Array<String> GldefClasses;
	Array<Color> GldefColors;
	Array<bool> BledSectorMarks;
	double IndoorLightAvg;
	double SkyLightAvg;
	Color SkySampleColor;
	static const int GldefObjectCap[] = { 96 };

	play void RunApplyAll()
	{
		RunApplySectorPasses();
		RunApplyProcLights();
	}

	// Flats / recursive / dim / smart — no procedural light spawns.
	play void RunApplySectorPasses()
	{
		if (!CVar.FindCVar("sss_lighting").GetBool())
			return;

		bool perf = CVar.FindCVar("sss_performance").GetBool();
		int mapTier = SSSReflectionHelper.MapTier();
		if (mapTier >= 2)
			return;

		bool flats = CVar.FindCVar("sss_relight_flats").GetBool();
		bool recursive = CVar.FindCVar("sss_relight_recursive").GetBool() && mapTier == 0;
		bool dimBleed = CVar.FindCVar("sss_relight_dimbleed").GetBool() && !perf;
		bool smart = CVar.FindCVar("sss_relight_smart").GetBool();
		bool window = CVar.FindCVar("sss_relight_window").GetBool() && !perf;
		bool texture = CVar.FindCVar("sss_relight_texture").GetBool() && !perf;
		bool gldef = CVar.FindCVar("sss_relight_gldef").GetBool() && !perf && mapTier == 0;
		if (gldef && ShouldSkipGldefLights())
			gldef = false;

		if (!flats && !recursive && !dimBleed && !smart && !window && !texture && !gldef)
			return;

		FlatNames.Clear();
		FlatColors.Clear();
		GldefClasses.Clear();
		GldefColors.Clear();
		ClearBledSectorMarks();

		if (smart || window || texture)
			ComputeLightAverages();

		if (flats || dimBleed || recursive)
		{
			BuildFlatColorCache();
			SampleSkyColor();
		}

		if (gldef)
			BuildGldefLightCache();

		if (flats)
			ApplyFlatSectorColors();

		if (recursive && CVar.FindCVar("sss_color_sec").GetBool())
			ApplyRecursiveColorBleed();

		if (dimBleed)
			ApplyDimnessBleed();

		if (smart)
			ApplySmartVolumeAdjust();
	}

	// Window / texture / GLDEF procedural lights (same instance keeps sector-pass caches).
	play void RunApplyProcLights()
	{
		if (!CVar.FindCVar("sss_lighting").GetBool())
			return;

		bool perf = CVar.FindCVar("sss_performance").GetBool();
		int mapTier = SSSReflectionHelper.MapTier();
		if (mapTier >= 2)
			return;

		bool window = CVar.FindCVar("sss_relight_window").GetBool() && !perf;
		bool texture = CVar.FindCVar("sss_relight_texture").GetBool() && !perf;
		bool gldef = CVar.FindCVar("sss_relight_gldef").GetBool() && !perf && mapTier == 0;
		if (gldef && ShouldSkipGldefLights())
			gldef = false;

		if (!window && !texture && !gldef)
			return;

		if ((window || texture) && IndoorLightAvg == 0.0 && SkyLightAvg == 0.0)
			ComputeLightAverages();
		if (gldef && GldefClasses.Size() == 0)
			BuildGldefLightCache();

		int procMax = CVar.FindCVar("sss_relight_proc_max").GetInt();
		if (perf || mapTier >= 1)
			procMax = min(procMax, 6);

		int spawned = 0;
		if (window)
			spawned = SpawnWindowLights(procMax);
		if (texture && spawned < procMax)
			spawned += SpawnTextureLights(procMax - spawned);
		if (gldef && spawned < procMax)
			SpawnGldefMapLights(procMax - spawned);
	}

	clearscope static vector2 SectorLightSpot(Sector sec)
	{
		if (!CVar.FindCVar("sss_relight_polylabel").GetBool())
			return SectorBBoxCenter(sec);

		if (sec.Lines.Size() == 3)
		{
			double sx, sy;
			int n = 0;
			foreach (lin : sec.Lines)
			{
				sx += lin.v1.p.x + lin.v2.p.x;
				sy += lin.v1.p.y + lin.v2.p.y;
				n += 2;
			}
			return (sx / n, sy / n);
		}

		double minx = double.infinity, miny = double.infinity;
		double maxx = -double.infinity, maxy = -double.infinity;
		foreach (lin : sec.Lines)
		{
			minx = min(minx, min(lin.v1.p.x, lin.v2.p.x));
			miny = min(miny, min(lin.v1.p.y, lin.v2.p.y));
			maxx = max(maxx, max(lin.v1.p.x, lin.v2.p.x));
			maxy = max(maxy, max(lin.v1.p.y, lin.v2.p.y));
		}

		vector2 best = sec.CenterSpot;
		double bestDist = -1.0;
		for (int gx = 1; gx <= 4; gx++)
		{
			for (int gy = 1; gy <= 4; gy++)
			{
				vector2 p = (
					minx + (maxx - minx) * gx / 5.0,
					miny + (maxy - miny) * gy / 5.0);
				if (Level.PointInSector(p) != sec)
					continue;
				double d = SectorInteriorDist(sec, p);
				if (d > bestDist)
				{
					bestDist = d;
					best = p;
				}
			}
		}
		return best;
	}

	private static vector2 SectorBBoxCenter(Sector sec)
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
		return ((minx + maxx) * 0.5, (miny + maxy) * 0.5);
	}

	private static double SectorInteriorDist(Sector sec, vector2 p)
	{
		double minDist = double.infinity;
		foreach (lin : sec.Lines)
		{
			vector2 a = lin.v1.p;
			vector2 b = lin.v2.p;
			vector2 ab = b - a;
			double t = clamp(((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / max(0.001, ab dot ab), 0.0, 1.0);
			vector2 q = a + ab * t;
			vector2 d = p - q;
			double dist = d.length();
			if (dist < minDist)
				minDist = dist;
		}
		return minDist;
	}

	private play void ComputeLightAverages()
	{
		double inSum = 0;
		int inCount = 0;
		double skySum = 0;
		int skyCount = 0;
		foreach (sec : Level.Sectors)
		{
			if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
			{
				skySum += sec.LightLevel;
				skyCount++;
			}
			else if (sec.Lines.Size() >= 3)
			{
				inSum += sec.LightLevel;
				inCount++;
			}
		}
		IndoorLightAvg = inCount > 0 ? inSum / inCount : 128.0;
		SkyLightAvg = skyCount > 0 ? skySum / skyCount : 160.0;
	}

	private play void BuildFlatColorCache()
	{
		Texman texture;
		Array<Color> palette;
		Map<Name, bool> FlatSeen;

		int palLump = Wads.FindLump("PLAYPAL", 0, Wads.ANYNAMESPACE);
		if (palLump >= 0)
		{
			String lump = Wads.ReadLump(palLump);
			for (uint i = 0; i + 2 < lump.Length() && i < 768; i += 3)
				palette.Push(Color(lump.ByteAt(i), lump.ByteAt(i + 1), lump.ByteAt(i + 2)));
		}

		foreach (sec : Level.Sectors)
		{
			Name fn = texture.GetName(sec.GetTexture(Sector.Floor));
			if (!FlatSeen.CheckKey(fn))
			{
				FlatSeen.Insert(fn, true);
				FlatNames.Push(fn);
			}
			Name cn = texture.GetName(sec.GetTexture(Sector.Ceiling));
			if (!FlatSeen.CheckKey(cn))
			{
				FlatSeen.Insert(cn, true);
				FlatNames.Push(cn);
			}
		}

		for (int i = 0; i < FlatNames.Size(); i++)
		{
			Color c = SampleFlatAverage(FlatNames[i], palette);
			FlatColors.Push(c);
		}
	}

	private play void EnsureBledSectorMarks()
	{
		if (BledSectorMarks.Size() != Level.Sectors.Size())
			BledSectorMarks.Resize(Level.Sectors.Size());
	}

	private play void ClearBledSectorMarks()
	{
		EnsureBledSectorMarks();
		for (int i = 0; i < BledSectorMarks.Size(); i++)
			BledSectorMarks[i] = false;
	}

	private play bool IsSectorBled(int secNum)
	{
		if (secNum < 0 || secNum >= BledSectorMarks.Size())
			return false;
		return BledSectorMarks[secNum];
	}

	private play void MarkSectorBled(int secNum)
	{
		if (secNum >= 0 && secNum < BledSectorMarks.Size())
			BledSectorMarks[secNum] = true;
	}

	private play Color SampleFlatAverage(Name flatName, Array<Color> palette)
	{
		String flatStr = flatName;
		if (flatStr.IndexOf("SKY") >= 0)
			return SkySampleColor;

		int lump = Wads.FindLump(flatName, 0, Wads.ANYNAMESPACE);
		if (lump < 0)
			return Color(255, 255, 255);

		String data = Wads.ReadLump(lump);
		if (data.Length() < 64)
			return Color(255, 255, 255);

		int step = max(4, data.Length() / 512);
		int n = 0, r = 0, g = 0, b = 0;
		for (uint i = 0; i < data.Length(); i += step)
		{
			int idx = data.ByteAt(i);
			Color px = palette.Size() > idx ? palette[idx] : Color(idx, idx, idx);
			bool keep;
			int pr, hr, hg, hb;
			[keep, pr, hr, hg, hb] = KeepTheColor(px);
			if (keep)
			{
				r += px.r;
				g += px.g;
				b += px.b;
				n++;
			}
		}
		if (n <= 0)
			return Color(255, 255, 255);
		return Color(r / n, g / n, b / n);
	}

	private play void SampleSkyColor()
	{
		Texman texture;
		SkySampleColor = Color(120, 140, 180);
		Name skyName = texture.GetName(Level.SkyTexture1);
		int lump = Wads.FindLump(skyName, 0, Wads.ANYNAMESPACE);
		if (lump < 0)
			return;

		String data = Wads.ReadLump(lump);
		if (data.Length() < 16)
			return;

		Array<Color> palette;
		int palLump = Wads.FindLump("PLAYPAL", 0, Wads.ANYNAMESPACE);
		if (palLump >= 0)
		{
			String pl = Wads.ReadLump(palLump);
			for (uint i = 0; i + 2 < pl.Length() && i < 768; i += 3)
				palette.Push(Color(pl.ByteAt(i), pl.ByteAt(i + 1), pl.ByteAt(i + 2)));
		}

		int n = 0, r = 0, g = 0, b = 0;
		for (uint i = 8; i + 1 < data.Length(); i += 8)
		{
			int idx = data.ByteAt(i);
			if (palette.Size() > idx)
			{
				Color px = palette[idx];
				bool keep;
				int pr, hr, hg, hb;
				[keep, pr, hr, hg, hb] = KeepTheColor(px);
				if (keep)
				{
					r += px.r;
					g += px.g;
					b += px.b;
					n++;
				}
			}
		}
		if (n > 0)
			SkySampleColor = Color(r / n, g / n, b / n);
	}

	private play Color LookupFlatColor(Name flatName)
	{
		int idx = FlatNames.Find(flatName);
		if (idx >= 0 && idx < FlatColors.Size())
			return FlatColors[idx];
		return Color(255, 255, 255);
	}

	private play void ApplyFlatSectorColors()
	{
		Texman texture;
		foreach (sec : Level.Sectors)
		{
			bool sky = sec.GetTexture(Sector.Ceiling) == skyflatnum;
			Color c;
			if (sky)
			{
				c = SkySampleColor;
			}
			else
			{
				Color cc = LookupFlatColor(texture.GetName(sec.GetTexture(Sector.Ceiling)));
				Color fc = LookupFlatColor(texture.GetName(sec.GetTexture(Sector.Floor)));
				if (cc.r + cc.g + cc.b > 0)
					c = cc;
				else if (fc.r + fc.g + fc.b > 0)
					c = fc;
				else
					continue;
			}

			bool keep;
			int pr, hr, hg, hb;
			[keep, pr, hr, hg, hb] = KeepTheColor(c);
			if (!keep && !sky)
				continue;

			sec.SetColor(TintColor(c, sky ? -0.15 : -0.25));
			if (pr > 160)
				sec.SetFade(TintColor(c, -0.35));
		}
	}

	private play void ApplyRecursiveColorBleed()
	{
		int maxDepth = clamp(CVar.FindCVar("sss_relight_rec_depth").GetInt(), 1, 4);
		ClearBledSectorMarks();

		foreach (sec : Level.Sectors)
		{
			Color c = sec.ColorMap.LightColor;
			bool keep;
			int pr, hr, hg, hb;
			[keep, pr, hr, hg, hb] = KeepTheColor(c);
			if (!keep)
				continue;
			MarkSectorBled(sec.SectorNum);
			BleedColorRecursive(sec, c, maxDepth, 0);
		}
	}

	private play void BleedColorRecursive(Sector sec, Color src, int maxDepth, int depth)
	{
		if (depth >= maxDepth)
			return;

		foreach (lin : sec.Lines)
		{
			if (!(lin.Flags & Line.ML_TWOSIDED))
				continue;

			Sector back = lin.BackSector != sec ? lin.BackSector : lin.FrontSector;
			if (!back || back == sec)
				continue;
			if (IsSectorBled(back.SectorNum))
				continue;

			Color bc = back.ColorMap.LightColor;
			bool bkeep;
			int bpr, bhr, bhg, bhb;
			[bkeep, bpr, bhr, bhg, bhb] = KeepTheColor(bc);

			bool srcKeep;
			int spr, shr, shg, shb;
			[srcKeep, spr, shr, shg, shb] = KeepTheColor(src);

			if (srcKeep && (shr > bhr || shg > bhg))
			{
				MarkSectorBled(back.SectorNum);
				back.SetColor(TintColor(src, -0.30));
				BleedColorRecursive(back, back.ColorMap.LightColor, maxDepth, depth + 1);
			}
		}
	}

	private play void ApplyDimnessBleed()
	{
		double dimMin = 0.85;
		int lightMin = 128;
		ClearBledSectorMarks();

		foreach (sec : Level.Sectors)
		{
			if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
				continue;
			if (sec.LightLevel <= int(lightMin * dimMin))
				continue;
			MarkSectorBled(sec.SectorNum);
			BleedDimnessRecursive(sec, dimMin, lightMin, 0, 2);
		}
	}

	private play void BleedDimnessRecursive(Sector sec, double dimMin, int lightMin, int depth, int maxDepth)
	{
		if (depth >= maxDepth)
			return;

		foreach (lin : sec.Lines)
		{
			if (!(lin.Flags & Line.ML_TWOSIDED))
				continue;

			Sector back = lin.BackSector != sec ? lin.BackSector : lin.FrontSector;
			if (!back || back == sec || back.GetTexture(Sector.Ceiling) == skyflatnum)
				continue;
			if (IsSectorBled(back.SectorNum))
				continue;

			if (sec.LightLevel < back.LightLevel && back.LightLevel < lightMin)
			{
				MarkSectorBled(back.SectorNum);
				int floor = int(back.LightLevel * dimMin);
				int newLight = back.LightLevel - int(sec.LightLevel * (1.0 - dimMin));
				back.LightLevel = max(floor, newLight);
				BleedDimnessRecursive(back, dimMin, lightMin, depth + 1, maxDepth);
			}
		}
	}

	private play void ApplySmartVolumeAdjust()
	{
		foreach (sec : Level.Sectors)
		{
			if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
				continue;
			if (sec.Lines.Size() < 3)
				continue;

			double area = SectorBBoxArea(sec);
			if (area < 28.0 * 28.0)
				continue;

			if (area > 120.0 * 120.0 && sec.LightLevel < IndoorLightAvg * 0.65)
			{
				sec.LightLevel = clamp(sec.LightLevel - int(sec.LightLevel * 0.08), 0, 255);
			}
			else if (area < 64.0 * 64.0 && sec.LightLevel > IndoorLightAvg * 1.15)
			{
				sec.LightLevel = clamp(sec.LightLevel + int((sec.LightLevel - IndoorLightAvg) * 0.06), 0, 255);
			}
		}
	}

	private play int SpawnWindowLights(int budget)
	{
		if (budget <= 0)
			return 0;

		int count = 0;
		double threshold = CVar.FindCVar("sss_relight_smart").GetBool() ?
			IndoorLightAvg * 0.55 : 96.0;

		foreach (sec : Level.Sectors)
		{
			if (count >= budget)
				break;
			if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
				continue;
			if (sec.Lines.Size() < 4 || sec.Lines.Size() > 8)
				continue;

			double area = SectorBBoxArea(sec);
			if (area > 128.0 * 128.0 || area < 24.0 * 24.0)
				continue;

			int outside = 0;
			int raised = 0;
			for (int i = 0; i < sec.Lines.Size(); i++)
			{
				Line lin = sec.Lines[i];
				if (lin.delta.length() < 32)
					continue;
				vector2 mid = ((lin.v1.p.x + lin.v2.p.x) * 0.5, (lin.v1.p.y + lin.v2.p.y) * 0.5);
				Sector back = lin.BackSector != sec ? lin.BackSector : lin.FrontSector;
				if (!back)
					continue;
				if (sec.FloorPlane.ZAtPoint(mid) >= back.FloorPlane.ZAtPoint(mid))
				{
					if (back.GetTexture(Sector.Ceiling) == skyflatnum)
						outside++;
					if (sec.FloorPlane.ZAtPoint(mid) > back.FloorPlane.ZAtPoint(mid))
						raised++;
				}
			}

			if (outside < 1 || raised < 1 || sec.LightLevel < threshold)
				continue;

			vector2 spot = SectorLightSpot(sec);
			double fz = sec.FloorPlane.ZAtPoint(spot);
			double cz = sec.CeilingPlane.ZAtPoint(spot);
			let light = sss_proplight(Actor.Spawn("sss_proplight", (spot.x, spot.y, fz + (cz - fz) * 0.55), NO_REPLACE));
			if (!light)
				continue;
			light.ConfigureSpot(sec.LightLevel, Color(255, 240, 210), 0.75);
			count++;
		}
		return count;
	}

	private play int SpawnTextureLights(int budget)
	{
		if (budget <= 0)
			return 0;

		int count = 0;
		foreach (sec : Level.Sectors)
		{
			if (count >= budget)
				break;
			if (sec.GetTexture(Sector.Ceiling) == skyflatnum)
				continue;
			if (sec.Lines.Size() < 4 || sec.Lines.Size() > 6)
				continue;

			double minLen = double.infinity;
			double maxLen = 0;
			for (int i = 0; i < sec.Lines.Size(); i++)
			{
				double len = sec.Lines[i].delta.length();
				minLen = min(minLen, len);
				maxLen = max(maxLen, len);
			}
			if (maxLen < 96 || maxLen < minLen * 2.5)
				continue;

			int backLight = 0;
			int twoSided = 0;
			for (int i = 0; i < sec.Lines.Size(); i++)
			{
				Line lin = sec.Lines[i];
				if (!(lin.Flags & Line.ML_TWOSIDED))
					continue;
				Sector back = lin.BackSector != sec ? lin.BackSector : lin.FrontSector;
				if (!back)
					continue;
				twoSided++;
				backLight += back.LightLevel;
			}
			if (twoSided <= 0)
				continue;
			backLight /= twoSided;
			if (sec.LightLevel <= int(backLight * 1.05))
				continue;

			for (int i = 0; i < sec.Lines.Size() && count < budget; i++)
			{
				Line lin = sec.Lines[i];
				if (lin.delta.length() > 64 || lin.delta.length() < maxLen * 0.45)
					continue;
				vector2 mid = ((lin.v1.p.x + lin.v2.p.x) * 0.5, (lin.v1.p.y + lin.v2.p.y) * 0.5);
				double fz = sec.FloorPlane.ZAtPoint(mid);
				double cz = sec.CeilingPlane.ZAtPoint(mid);
				let light = sss_proplight(Actor.Spawn("sss_proplight", (mid.x, mid.y, fz + (cz - fz) * 0.5), NO_REPLACE));
				if (!light)
					continue;
				light.ConfigurePoint(sec.LightLevel, Color(255, 220, 180), 0.55);
				count++;
			}
		}
		return count;
	}

	private play bool ShouldSkipGldefLights()
	{
		if (CVar.FindCVar("sss_performance").GetBool())
			return true;

		if (SSSReflectionHelper.MapTier() > 0)
			return true;

		// Many GLDEFS lumps (PBR / mega-packs) make full ingest freeze UZDoom.
		int lumpCount = 0;
		int lump = -1;
		int start = 0;
		while ((lump = Wads.FindLump("GLDEFS", start, Wads.ANYNAMESPACE)) >= 0)
		{
			lumpCount++;
			if (lumpCount > 8)
				return true;
			start = lump + 1;
		}
		return false;
	}

	private play void BuildGldefLightCache()
	{
		int lump = -1;
		int start = 0;
		while ((lump = Wads.FindLump("GLDEFS", start, Wads.ANYNAMESPACE)) >= 0)
		{
			if (GldefClasses.Size() >= GldefObjectCap[0])
				break;
			ParseGldefLump(Wads.ReadLump(lump), GldefObjectCap[0]);
			start = lump + 1;
		}
	}

	private play void ParseGldefLump(String text, int objectCap)
	{
		Array<String> lines;
		text.Split(lines, "\n");
		for (int i = 0; i + 1 < lines.Size(); i++)
		{
			if (GldefClasses.Size() >= objectCap)
				return;

			String line = lines[i].MakeLower();
			line.StripLeft("\t ");
			if (line.IndexOf("object ") != 0)
				continue;
			String objLine = lines[i + 1].MakeLower();
			objLine.StripLeft("\t ");
			if (objLine.IndexOf("light ") != 0 && objLine.IndexOf("pointlight ") != 0 && objLine.IndexOf("spotlight ") != 0)
				continue;

			String objName = lines[i].Mid(7);
			objName.StripLeft("\t ");
			int brace = objName.IndexOf("{");
			if (brace >= 0)
				objName = objName.Left(brace);
			objName.StripRight("\t ");

			Array<String> parts;
			objLine.Split(parts, " ");
			if (parts.Size() < 5)
				continue;

			double r = parts[parts.Size() - 3].ToDouble();
			double g = parts[parts.Size() - 2].ToDouble();
			double b = parts[parts.Size() - 1].ToDouble();
			if (r <= 1.0 && g <= 1.0 && b <= 1.0)
			{
				r *= 255;
				g *= 255;
				b *= 255;
			}
			Color c = Color(int(r), int(g), int(b));
			GldefClasses.Push(objName.MakeLower());
			GldefColors.Push(TintColor(c, c.b > c.r ? 0.2 : -0.2));
		}
	}

	private play void SpawnGldefMapLights(int budget)
	{
		if (budget <= 0 || GldefClasses.Size() == 0)
			return;

		int count = 0;
		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor mo;
		while (mo = Actor(it.Next()))
		{
			if (count >= budget)
				break;
			if (mo.bInvisible || mo.bNoBlockMap)
				continue;

			String cname = mo.GetClassName();
			cname = cname.MakeLower();
			int idx = GldefClasses.Find(cname);
			if (idx < 0)
				continue;

			let light = sss_proplight(Actor.Spawn("sss_proplight", mo.pos, NO_REPLACE));
			if (!light)
				continue;
			light.ConfigurePoint(160, GldefColors[idx], 0.45);
			count++;
		}
	}

	private static bool, int, int, int, int KeepTheColor(Color c)
	{
		int perceived;
		if (c.g > c.r && c.g > c.b)
			perceived = int(sqrt(0.299 * c.r * c.r + 0.587 * c.g * c.g + 0.114 * c.b * c.b));
		else
			perceived = int(sqrt(0.2126 * c.r * c.r + 0.7152 * c.g * c.g + 0.0722 * c.b * c.b));

		int howred = 0;
		int howgreen = 0;
		int howblue = 0;
		if (c.r > c.g && c.r > c.b && c.r > 176) howred = 1;
		if (c.g > c.r && c.g > c.b && c.g > 128) howgreen = 1;
		if (c.b > c.r && c.b > c.g && c.b > 196) howblue = 1;

		return (perceived > 128 || howred || howgreen || howblue), perceived, howred, howgreen, howblue;
	}

	private static Color TintColor(Color c, double amount)
	{
		if (amount >= 0)
		{
			return Color(
				clamp(int(c.r + (255 - c.r) * amount), 0, 255),
				clamp(int(c.g + (255 - c.g) * amount), 0, 255),
				clamp(int(c.b + (255 - c.b) * amount), 0, 255));
		}
		double t = -amount;
		return Color(
			clamp(int(c.r * (1.0 - t)), 0, 255),
			clamp(int(c.g * (1.0 - t)), 0, 255),
			clamp(int(c.b * (1.0 - t)), 0, 255));
	}

	private static double SectorBBoxArea(Sector sec)
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
}
