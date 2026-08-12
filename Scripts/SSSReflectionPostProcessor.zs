// LevelPostProcessor is the only runtime API allowed to add sector tags.
// Tag every allowlisted plane up front so later preset changes can enable it.
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
