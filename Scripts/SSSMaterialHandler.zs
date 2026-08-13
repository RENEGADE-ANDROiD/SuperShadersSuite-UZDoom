// Living enemies and corpses are hidden from planar / mirror reflections (+INVISIBLEINMIRRORS)
// for performance. Fluid flats (blood pools, water, nukage) still reflect the world.

class SSSMaterialHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		if (SSSReflectionHelper.MapTier() >= 2)
			return;

		SuppressEnemyReflectionsOnMap();
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		Actor mo = e.Thing;
		if (!mo)
			return;

		// Map load scans existing corpses; runtime gore spam (combat) does not need mirror flags.
		if (!mo.bIsMonster || mo.health <= 0)
			return;

		TrySuppressActorReflection(mo);
	}

	override void WorldThingDied(WorldEvent e)
	{
		Actor mo = e.Thing;
		if (!mo || !mo.bIsMonster)
			return;

		TrySuppressActorReflection(mo);
	}

	void SuppressEnemyReflectionsOnMap()
	{
		int scanned = 0;
		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor mo;
		while (mo = Actor(it.Next()))
		{
			if (++scanned > 4096)
				break;
			TrySuppressActorReflection(mo);
		}
	}

	void TrySuppressActorReflection(Actor mo)
	{
		if (!ShouldSuppressActorReflection(mo))
			return;
		mo.bInvisibleInMirrors = true;
	}

	bool ShouldSuppressActorReflection(Actor mo)
	{
		if (!mo || mo.player)
			return false;

		if (mo.bIsMonster)
			return true;

		if (mo.CountsAsKill())
			return true;

		if (mo.bShootable && ClassNameLooksLikeCorpseOrGore(mo.GetClassName()))
			return true;

		return false;
	}

	bool ClassNameLooksLikeCorpseOrGore(String cn)
	{
		if (cn.IndexOf("Corpse") >= 0)
			return true;
		if (cn.IndexOf("Dead") >= 0)
			return true;
		if (cn.IndexOf("Ragdoll") >= 0)
			return true;
		if (cn.IndexOf("Remains") >= 0)
			return true;
		if (cn.IndexOf("Bodypart") >= 0)
			return true;
		if (cn.IndexOf("BodyPart") >= 0)
			return true;
		if (cn.IndexOf("Gib") >= 0)
			return true;
		if (cn.IndexOf("Gore") >= 0)
			return true;
		if (cn.IndexOf("Meat") >= 0)
			return true;
		if (cn.IndexOf("Chunk") >= 0)
			return true;
		if (cn.IndexOf("Organ") >= 0)
			return true;
		return false;
	}
}
