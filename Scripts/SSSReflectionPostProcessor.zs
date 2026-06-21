// Tags fluid/allowlisted flats and applies planar reflection in one pass.
class SSSReflectionPostProcessor : LevelPostProcessor
{
	protected void Apply(Name checksum, String mapname)
	{
		TagReflectionSectors(Sector.Floor);
		TagReflectionSectors(Sector.Ceiling);
		SSSReflectionHelper.ApplyPlaneReflections();
	}

	protected void TagReflectionSectors(int dir)
	{
		bool enabled = dir == Sector.Ceiling ?
			CVar.FindCVar("sss_ceilreflections").GetBool() :
			CVar.FindCVar("sss_floorreflections").GetBool();
		if (!enabled)
			return;

		int tag = dir == Sector.Ceiling ?
			CVar.FindCVar("sss_ceil_tag").GetInt() :
			CVar.FindCVar("sss_floor_tag").GetInt();

		Texman texture;
		foreach (sec : Level.Sectors)
		{
			Name flatName = texture.GetName(sec.GetTexture(dir));
			if (SSSReflectionHelper.FlatMatchesAllowlist(dir, flatName))
				AddSectorTag(sec.SectorNum, tag);
		}
	}
}
