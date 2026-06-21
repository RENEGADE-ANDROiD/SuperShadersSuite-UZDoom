mixin class SSSGeo
{
	vector2 GetMiddle(Line lin)
	{
		return ((lin.V1.P.x + lin.V2.P.x) * 0.5, (lin.V1.P.y + lin.V2.P.y) * 0.5);
	}

	Sector BackSector(Sector sec, Line lin)
	{
		if (lin.Flags & Line.ML_TWOSIDED)
		{
			if (lin.BackSector != sec) return lin.BackSector;
			if (lin.FrontSector != sec) return lin.FrontSector;
		}
		return null;
	}
}
