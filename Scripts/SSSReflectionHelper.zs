// Universal reflection helpers: doom-fluid flat lists, optional name heuristics,
// planar reflection apply, and fluid-flat tests for Fluid SSR gating.

class SSSReflectionHelper
{
	clearscope static bool FlatMatchesNameToken(Name flatName, Name token)
	{
		if (flatName == token)
			return true;

		for (int i = 1; i <= 4; i++)
		{
			if (flatName == String.Format("%s%d", token, i))
				return true;
		}

		for (int i = 1; i <= 4; i++)
		{
			if (flatName == String.Format("%s%02d", token, i))
				return true;
		}

		return false;
	}

	clearscope static bool FlatMatchesHeuristicToken(Name flatName, String entry, Name token)
	{
		return entry == String.Format("%s", token) &&
			FlatMatchesNameToken(flatName, token);
	}

	clearscope static bool FlatMatchesCvarEntry(Name flatName, String entry)
	{
		if (entry.Length() == 0)
			return false;

		if (flatName == entry)
			return true;

		if (FlatMatchesHeuristicToken(flatName, entry, "NUKAGE")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FWATER")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "SWATER")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "WATER")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "LAVA")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "BLOOD")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "SLIME")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "SLIMY")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "WARP")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "OIL")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "MUCUS")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLAT5")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLTWAWA")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLTSLUD")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLTFLWW")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLTLAVA")) return true;
		if (FlatMatchesHeuristicToken(flatName, entry, "FLATHUH")) return true;
		if (entry == "X_" && FlatMatchesHexenLiquid(flatName)) return true;

		for (int i = 1; i <= 4; i++)
		{
			if (flatName == String.Format("%s%d", entry, i))
				return true;
		}

		for (int i = 1; i <= 4; i++)
		{
			if (flatName == String.Format("%s%02d", entry, i))
				return true;
		}

		return false;
	}

	clearscope static bool FlatMatchesHexenLiquid(Name flatName)
	{
		static const Name HexenLiquidFlats[] =
		{
			"X_001", "X_002", "X_003", "X_004", "X_005", "X_006",
			"X_007", "X_008", "X_009", "X_010", "X_011", "X_012",
			"X_013", "X_014", "X_015", "X_016"
		};

		for (int i = 0; i < HexenLiquidFlats.Size(); i++)
		{
			if (flatName == HexenLiquidFlats[i])
				return true;
		}
		return false;
	}

	clearscope static bool FlatNameMatchesHeuristic(Name flatName)
	{
		if (flatName == "")
			return false;

		if (FlatMatchesNameToken(flatName, "NUKAGE")) return true;
		if (FlatMatchesNameToken(flatName, "FWATER")) return true;
		if (FlatMatchesNameToken(flatName, "SWATER")) return true;
		if (FlatMatchesNameToken(flatName, "WATER")) return true;
		if (FlatMatchesNameToken(flatName, "LAVA")) return true;
		if (FlatMatchesNameToken(flatName, "BLOOD")) return true;
		if (FlatMatchesNameToken(flatName, "SLIME")) return true;
		if (FlatMatchesNameToken(flatName, "SLIMY")) return true;
		if (FlatMatchesNameToken(flatName, "WARP")) return true;
		if (FlatMatchesNameToken(flatName, "OIL")) return true;
		if (FlatMatchesNameToken(flatName, "MUCUS")) return true;
		if (FlatMatchesNameToken(flatName, "FLAT5")) return true;
		if (FlatMatchesNameToken(flatName, "FLTWAWA")) return true;
		if (FlatMatchesNameToken(flatName, "FLTSLUD")) return true;
		if (FlatMatchesNameToken(flatName, "FLTFLWW")) return true;
		if (FlatMatchesNameToken(flatName, "FLTLAVA")) return true;
		if (FlatMatchesNameToken(flatName, "FLATHUH")) return true;
		if (FlatMatchesHexenLiquid(flatName)) return true;

		return false;
	}

	clearscope static bool FlatInCvarList(int dir, Name flatName)
	{
		for (int i = 1; i <= 10; i++)
		{
			String cvarName = dir == Sector.Ceiling ?
				String.Format("sss_ceil%d", i) :
				String.Format("sss_floor%d", i);
			let c = CVar.FindCVar(cvarName);
			if (!c)
				continue;

			if (FlatMatchesCvarEntry(flatName, c.GetString()))
				return true;
		}
		return false;
	}

	clearscope static bool FlatMatchesAllowlist(int dir, Name flatName)
	{
		if (flatName == "")
			return false;

		if (FlatInCvarList(dir, flatName))
			return true;

		if (!CVar.FindCVar("sss_floor_match_heuristic").GetBool())
			return false;

		return FlatNameMatchesHeuristic(flatName);
	}

	static bool SectorHasAnyTag(int tag)
	{
		let it = Level.CreateSectorTagIterator(tag);
		return it.Next() != -1;
	}

	static void ApplyPlaneReflections()
	{
		if (CVar.FindCVar("sss_floorreflections").GetBool())
		{
			int tag = CVar.FindCVar("sss_floor_tag").GetInt();
			if (SectorHasAnyTag(tag))
			{
				Sector_SetPlaneReflection(tag,
					CVar.FindCVar("sss_floorstrength").GetInt(), 0);
			}
		}

		if (CVar.FindCVar("sss_ceilreflections").GetBool())
		{
			int tag = CVar.FindCVar("sss_ceil_tag").GetInt();
			if (SectorHasAnyTag(tag))
			{
				Sector_SetPlaneReflection(tag, 0,
					CVar.FindCVar("sss_ceilstrength").GetInt());
			}
		}
	}

	clearscope static bool ActorOnFluidFlat(Actor mo)
	{
		if (!mo || !mo.floorsector)
			return false;

		Texman texture;
		Name flatName = texture.GetName(mo.floorsector.GetTexture(Sector.Floor));
		return FlatMatchesAllowlist(Sector.Floor, flatName);
	}

	clearscope static bool PlayerOnFluidFlat(PlayerInfo p)
	{
		if (!p || !p.mo)
			return false;
		return ActorOnFluidFlat(p.mo);
	}
}
