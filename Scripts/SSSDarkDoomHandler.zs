// DarkDoomZ sector darkening + flashlight, integrated with SSS enhanced lighting.
// Based on DarkDoomZ by Sterling "Caligari87" Parker (zlib license).

class SSSDarkDoom_Handler : EventHandler
{
	static SSSDarkDoom_Handler FindHandler()
	{
		return SSSDarkDoom_Handler(EventHandler.Find("SSSDarkDoom_Handler"));
	}

	// Profile tables use int storage (/1000 for most floats) — UZDoom 4.14.x rejects static const double[].
	static const int ReliteDarkenWeight[] = {0, 480, 520, 560, 620, 680, 720, 760, 780};
	static const int ReliteBrightenWeight[] = {0, 520, 480, 440, 380, 340, 300, 280, 260};
	static const int ReliteAdditiveDark[] = {0, 220, 260, 300, 360, 400, 440, 480, 500};
	static const int ReliteFlatGlow[] = {0, 680, 820, 880, 950, 1000, 1050, 1080, 1100};
	static const int ReliteWallGlow[] = {0, 360, 420, 460, 520, 560, 600, 620, 640};
	static const int ReliteFlatLights[] = {0, 480, 580, 650, 720, 780, 820, 850, 880};
	static const int ReliteBleeding[] = {0, 52, 62, 72, 85, 92, 95, 88, 80};
	static const int ReliteFloorStrength[] = {0, 19, 22, 24, 30, 30, 32, 32, 30};
	static const int ReliteFlatLightMax[] = {0, 16, 16, 16, 18, 18, 20, 20, 20};
	static const int ReliteContactAOOn[] = {0, 1, 1, 1, 1, 1, 1, 1, 1};
	static const int ReliteContactAOStrength[] = {0, 280, 180, 240, 380, 380, 440, 500, 550};
	static const int ReliteContactAORadius[] = {0, 25, 22, 25, 30, 30, 32, 34, 35};
	static const int ReliteFluidSSROn[] = {0, 1, 1, 1, 1, 1, 1, 1, 1};
	static const int ReliteFluidSSRStrength[] = {0, 380, 280, 350, 500, 500, 580, 650, 700};
	static const int ReliteWallBake[] = {0, 280, 150, 250, 420, 420, 500, 550, 600};
	static const int ReliteShadowOn[] = {0, 1, 0, 0, 1, 1, 1, 1, 1};

	void ApplyRelitePreset(int preset)
	{
		if (!CVar.FindCVar("sss_darkdoom_relite_sync").GetBool())
			return;

		if (preset <= 0)
		{
			ResetReliteDefaults();
			return;
		}

		int p = clamp(preset, 1, 8);

		double darken = ReliteDarkenWeight[p] / 1000.0;
		double brighten = ReliteBrightenWeight[p] / 1000.0;
		int visualPreset = CVar.FindCVar("sss_visual_preset").GetInt();
		if (visualPreset == 4)
		{
			darken -= 0.04;
			brighten += 0.04;
		}

		SetReliteFloat("sss_darken", darken);
		SetReliteFloat("sss_brighten", brighten);
		SetReliteFloat("sss_additive", ReliteAdditiveDark[p] / 1000.0);
		SetReliteFloat("sss_flat_glow", ReliteFlatGlow[p] / 1000.0);
		SetReliteFloat("sss_wall_glow", ReliteWallGlow[p] / 1000.0);
		SetReliteFloat("sss_flat_lights", ReliteFlatLights[p] / 1000.0);
		SetReliteFloat("sss_bleeding", ReliteBleeding[p] / 1000.0);
		SetReliteInt("sss_floorstrength", ReliteFloorStrength[p]);
		SetReliteInt("sss_flat_light_max", ReliteFlatLightMax[p]);
		SetReliteBool("sss_colorbleed", true);
		SetReliteBool("sss_color_sec", true);
		SetReliteBool("sss_color_walls", true);
		SetReliteBool("sss_lighting", true);
		SetReliteBool("sss_bias", true);
		ApplyReliteRTLite(p);
	}

	void ApplyReliteRTLite(int p)
	{
		SetReliteBool("sss_contactao", ReliteContactAOOn[p] != 0);
		SetReliteFloat("sss_contactao_strength", ReliteContactAOStrength[p] / 1000.0);
		SetReliteFloat("sss_contactao_radius", ReliteContactAORadius[p] / 10.0);
		SetReliteBool("sss_fluidssr", ReliteFluidSSROn[p] != 0);
		SetReliteFloat("sss_fluidssr_strength", ReliteFluidSSRStrength[p] / 1000.0);
		SetReliteFloat("sss_wall_bake", ReliteWallBake[p] / 1000.0);
		SetReliteBool("sss_shadows", ReliteShadowOn[p] != 0);
		if (ReliteShadowOn[p] != 0)
		{
			SetReliteBool("sss_shadow_players", true);
			int interval = 3;
			if (p == 1)
				interval = 4;
			else if (p == 4)
				interval = 2;
			else if (p >= 7)
				interval = 2;
			SetReliteInt("sss_shadow_interval", interval);
		}
	}

	void ApplyReliteClassicMode(int mode)
	{
		switch (mode)
		{
		case 10: ApplyRelitePreset(3); break;
		case 11: ApplyRelitePreset(5); break;
		case 12: ApplyRelitePreset(8); break;
		}
	}

	private void ResetReliteDefaults()
	{
		ResetReliteCVar("sss_darken");
		ResetReliteCVar("sss_brighten");
		ResetReliteCVar("sss_additive");
		ResetReliteCVar("sss_flat_glow");
		ResetReliteCVar("sss_wall_glow");
		ResetReliteCVar("sss_flat_lights");
		ResetReliteCVar("sss_bleeding");
		ResetReliteCVar("sss_floorstrength");
		ResetReliteCVar("sss_flat_light_max");
		ResetReliteCVar("sss_contactao");
		ResetReliteCVar("sss_contactao_strength");
		ResetReliteCVar("sss_contactao_radius");
		ResetReliteCVar("sss_fluidssr");
		ResetReliteCVar("sss_fluidssr_strength");
		ResetReliteCVar("sss_wall_bake");
		ResetReliteCVar("sss_shadows");
	}

	private void SetReliteFloat(String name, double value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetFloat(value);
	}

	private void SetReliteInt(String name, int value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetInt(value);
	}

	private void SetReliteBool(String name, bool value)
	{
		let c = CVar.FindCVar(name);
		if (c) c.SetBool(value);
	}

	private void ResetReliteCVar(String name)
	{
		let c = CVar.FindCVar(name);
		if (c) c.ResetToDefault();
	}

	Array<int> BaseLightLevels;
	int Mode, Preset, PreGain, PostGain, FogDensity, MinLight;
	int OldMode, OldPreset, OldPreGain, OldPostGain, OldFogDensity, OldMinLight;
	double SkyMode, OldSkyMode;
	bool OldReliteSync;
	int LastAppliedFp;
	int BaseAdjustment, FinalAdjustment;
	bool IsSky;
	bool SectorDarkenPending;
	int SectorDarkenCursor;
	static const int SectorDarkenChunk[] = {64};

	override void WorldLoaded(WorldEvent e)
	{
		LastAppliedFp = -1;
		SectorDarkenPending = false;
		SectorDarkenCursor = 0;
		BaseLightLevels.Clear();

		if (!CVar.FindCVar("ddz_lighting").GetBool())
		{
			ThinkerIterator it = ThinkerIterator.Create("Lighting");
			Lighting effect;
			while (effect = Lighting(it.Next())) { effect.Destroy(); }
		}

		// Baselines + sector pass run in SSSMapLoadHandler after enhanced lighting.
		SyncDarkDoomCvarState();

		if (e.IsReopen)
		{
			let iterator = ThinkerIterator.Create("DarkDoomZ_Spotlight");
			for (Thinker mo; (mo = iterator.Next());)
				mo.Destroy();
		}
	}

	void SyncDarkDoomCvarState()
	{
		ReadDarkDoomCvars();
		bool reliteSync = CVar.FindCVar("sss_darkdoom_relite_sync").GetBool();
		OldMode = Mode;
		OldPreset = Preset;
		OldPreGain = PreGain;
		OldPostGain = PostGain;
		OldSkyMode = SkyMode;
		OldFogDensity = FogDensity;
		OldMinLight = MinLight;
		OldReliteSync = reliteSync;
		LastAppliedFp = DarkDoomCvarFingerprint();
	}

	void RefreshBaseLightLevelsFromMap()
	{
		BaseLightLevels.Clear();
		for (int i = 0; i < Level.Sectors.Size(); i++)
			BaseLightLevels.Push(Level.Sectors[i].LightLevel);
	}

	// Called last on map load — baselines reflect SSS lighting passes, not raw IWAD levels.
	void FinishMapLoadLighting()
	{
		if (!CVar.FindCVar("ddz_lighting").GetBool())
			return;

		SyncDarkDoomCvarState();
		QueueSectorDarkening(true);
	}

	override void PlayerSpawned(PlayerEvent e)
	{
		if (!CVar.FindCVar("sss_darkdoom_flashlight").GetBool())
			return;

		PlayerInfo player = players[e.PlayerNumber];
		let FlashlightClass = (class<Inventory>)(Actor.GetReplacement("DarkDoomZ_Flashlight"));
		player.mo.GiveInventory(FlashlightClass, 1);
	}

	override void WorldTick()
	{
		if (SectorDarkenPending)
		{
			ApplySectorDarkeningChunk(SectorDarkenChunk[0]);
			return;
		}

		// Play-context only — UiTick CVAR writes can desync UI vs play and flood netevents.
		if (Level.MapTime & 3)
			return;

		int fp = DarkDoomCvarFingerprint();
		if (fp == LastAppliedFp)
			return;

		ChangeLighting(false);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "SSSUpdateDarkDoom")
			ChangeLighting(false);
		if (e.Name == "SSSReapplyDarkDoomSectors")
			QueueSectorDarkening();
		if (e.Name == "sss_apply_reflections")
			SSSReflectionHelper.ApplyPlaneReflections();
	}

	void ReadDarkDoomCvars(PlayerInfo p = null)
	{
		if (!p)
			p = players[consoleplayer];

		if (p)
		{
			Mode = CVar.GetCVar("ddz_mode", p).GetInt();
			Preset = CVar.GetCVar("ddz_preset", p).GetInt();
			PreGain = CVar.GetCVar("ddz_pregain", p).GetInt();
			PostGain = CVar.GetCVar("ddz_postgain", p).GetInt();
			SkyMode = CVar.GetCVar("ddz_skymode", p).GetFloat();
			FogDensity = CVar.GetCVar("ddz_fog", p).GetInt();
			MinLight = CVar.GetCVar("ddz_minlight", p).GetInt();
			return;
		}

		Mode = CVar.FindCVar("ddz_mode").GetInt();
		Preset = CVar.FindCVar("ddz_preset").GetInt();
		PreGain = CVar.FindCVar("ddz_pregain").GetInt();
		PostGain = CVar.FindCVar("ddz_postgain").GetInt();
		SkyMode = CVar.FindCVar("ddz_skymode").GetFloat();
		FogDensity = CVar.FindCVar("ddz_fog").GetInt();
		MinLight = CVar.FindCVar("ddz_minlight").GetInt();
	}

	void ApplyLiveLightingFromPlayCvars()
	{
		PlayerInfo p = players[consoleplayer];
		if (!p)
			return;
		ChangeLightingPlay(p, false);
	}

	void ApplyOneSectorDarkening(int i)
	{
		int BaseLightLevel = BaseLightLevels[i];
		BaseLightLevel += PreGain;

		IsSky = (Level.Sectors[i].GetTexture(0) == skyflatnum ||
				 Level.Sectors[i].GetTexture(1) == skyflatnum);

		FinalAdjustment = BaseAdjustment;
		if (IsSky)
			FinalAdjustment = int(FinalAdjustment * SkyMode);

		switch (Mode)
		{
			case 1:
				Level.Sectors[i].LightLevel = BaseLightLevel - FinalAdjustment;
				break;
			case 2:
				Level.Sectors[i].LightLevel = int(BaseLightLevel * (1.0 - FinalAdjustment / 256.0));
				break;
			case 3:
				Level.Sectors[i].LightLevel = clamp(BaseLightLevel, 0, 256 - FinalAdjustment);
				break;
			case 4:
				Level.Sectors[i].LightLevel = int((256 - (FinalAdjustment ** (FinalAdjustment / 256.0))) * (BaseLightLevel / 256.0) ** (1 + (FinalAdjustment / (33 - (FinalAdjustment / 8)))));
				break;
			case 10:
				Level.Sectors[i].LightLevel = BaseLightLevel - 96;
				break;
			case 11:
				Level.Sectors[i].LightLevel = BaseLightLevel - 128;
				break;
			case 12:
				Level.Sectors[i].LightLevel = BaseLightLevel - 256;
				break;
			default:
				Level.Sectors[i].LightLevel = BaseLightLevel;
				break;
		}

		Level.Sectors[i].LightLevel += PostGain;
		Level.Sectors[i].LightLevel = max(Level.Sectors[i].LightLevel, MinLight);

		double FinalFogDensity = FogDensity;
		if (IsSky)
			FinalFogDensity *= SkyMode;
		Level.Sectors[i].SetFogDensity(int(FinalFogDensity));
	}

	void QueueSectorDarkening(bool restart = false)
	{
		if (BaseLightLevels.Size() != Level.Sectors.Size())
			return;

		if (SectorDarkenPending && !restart)
			return;

		ReadDarkDoomCvars();
		BaseAdjustment = 32 * Preset;
		SectorDarkenCursor = 0;
		SectorDarkenPending = true;
	}

	void ApplySectorDarkeningChunk(int budget)
	{
		if (!SectorDarkenPending)
			return;
		if (BaseLightLevels.Size() != Level.Sectors.Size())
		{
			SectorDarkenPending = false;
			return;
		}

		int end = min(SectorDarkenCursor + max(1, budget), BaseLightLevels.Size());
		for (int i = SectorDarkenCursor; i < end; i++)
			ApplyOneSectorDarkening(i);

		SectorDarkenCursor = end;
		if (SectorDarkenCursor >= BaseLightLevels.Size())
			SectorDarkenPending = false;
	}

	void ApplySectorDarkening()
	{
		QueueSectorDarkening();
	}

	void ChangeLighting(bool forceRelite)
	{
		ChangeLightingPlay(players[consoleplayer], forceRelite);
	}

	void ChangeLightingPlay(PlayerInfo p, bool forceRelite)
	{
		ReadDarkDoomCvars(p);
		bool reliteSync = p
			? CVar.GetCVar("sss_darkdoom_relite_sync", p).GetBool()
			: CVar.FindCVar("sss_darkdoom_relite_sync").GetBool();

		bool changed = forceRelite || (
			OldMode != Mode ||
			OldPreset != Preset ||
			OldPreGain != PreGain ||
			OldPostGain != PostGain ||
			OldSkyMode != SkyMode ||
			OldFogDensity != FogDensity ||
			OldMinLight != MinLight ||
			OldReliteSync != reliteSync);

		if (changed)
		{
			bool visualPresetOwnsRelite = reliteSync && p
				&& CVar.GetCVar("sss_visual_preset_auto", p).GetBool()
				&& CVar.GetCVar("sss_visual_preset", p).GetInt() > 0;

			if (!visualPresetOwnsRelite)
			{
				if (Mode >= 10)
					ApplyReliteClassicMode(Mode);
				else if (Mode == 0 || Preset == 0)
					ApplyRelitePreset(0);
				else
					ApplyRelitePreset(Preset);
			}

			QueueSectorDarkening(true);
		}

		OldMode = Mode;
		OldPreset = Preset;
		OldPreGain = PreGain;
		OldPostGain = PostGain;
		OldSkyMode = SkyMode;
		OldFogDensity = FogDensity;
		OldMinLight = MinLight;
		OldReliteSync = reliteSync;

		if (changed)
			SSSReflectionHelper.ApplyPlaneReflections();

		LastAppliedFp = DarkDoomCvarFingerprint(p);
	}

	clearscope static int DarkDoomCvarFingerprint(PlayerInfo p = null)
	{
		if (!p)
			p = players[consoleplayer];
		if (!p)
			return 0;

		int fp = CVar.GetCVar("ddz_mode", p).GetInt();
		fp = fp * 31 + CVar.GetCVar("ddz_preset", p).GetInt();
		fp = fp * 31 + CVar.GetCVar("ddz_pregain", p).GetInt();
		fp = fp * 31 + CVar.GetCVar("ddz_postgain", p).GetInt();
		fp = fp * 31 + int(CVar.GetCVar("ddz_skymode", p).GetFloat() * 1000.0);
		fp = fp * 31 + CVar.GetCVar("ddz_fog", p).GetInt();
		fp = fp * 31 + CVar.GetCVar("ddz_minlight", p).GetInt();
		fp = fp * 31 + (CVar.GetCVar("sss_darkdoom_relite_sync", p).GetBool() ? 1 : 0);
		return fp;
	}
}

class DarkDoomZ_Flashlight : CustomInventory
{
	DarkDoomZ_Spotlight SelfLight1, SelfLight2;
	bool Active;
	int Quality, OldQuality;
	int Type, OldType;
	int Mount, OldMount;
	int R, G, B;
	int beamInner, beamOuter, beamRadius;
	int spillInner, spillOuter, spillRadius;
	double offsetAngle, offsetZ;
	int inertia;
	double spring, damping;

	default
	{
		+INVENTORY.PERSISTENTPOWER;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		Quality = CVar.FindCVar("ddz_fl_quality").GetInt();
		Type = CVar.FindCVar("ddz_fl_type").GetInt();
		Mount = CVar.FindCVar("ddz_fl_pos").GetInt();
		if (Active)
		{
			if (Quality != OldQuality ||
				Type != OldType ||
				Mount != OldMount)
			{
				if (SelfLight1) { SelfLight1.Destroy(); }
				if (SelfLight2) { SelfLight2.Destroy(); }
			}

			switch (Type)
			{
				case 0:
					R = 255; G = 214; B = 170;
					beamInner = 0; beamOuter = 25; beamRadius = 384;
					spillInner = 15; spillOuter = 45; spillRadius = 128;
					break;
				case 1:
					R = 255; G = 241; B = 224;
					beamInner = 0; beamOuter = 20; beamRadius = 512;
					spillInner = 10; spillOuter = 60; spillRadius = 384;
					break;
				case 2:
					R = 248; G = 255; B = 255;
					beamInner = 0; beamOuter = 15; beamRadius = 640;
					spillInner = 15; spillOuter = 75; spillRadius = 256;
					break;
				case 3:
					R = 192; G = 36; B = 34;
					beamInner = 0; beamOuter = 20; beamRadius = 256;
					spillInner = 10; spillOuter = 60; spillRadius = 128;
					break;
			}

			switch (Mount)
			{
				case 0:
					spring = 0.25; damping = 0.2; inertia = 4;
					offsetAngle = 0; offsetZ = -13;
					break;
				case 1:
					spring = 0.35; damping = 0.75; inertia = 2;
					offsetAngle = 80; offsetZ = -5;
					break;
				case 2:
					spring = 0.35; damping = 0.75; inertia = 2;
					offsetAngle = -80; offsetZ = -5;
					break;
				case 3:
					spring = 1; damping = 1; inertia = 1;
					offsetAngle = 0; offsetZ = 4;
					break;
			}

			switch (Quality)
			{
				case 0:
					if (!SelfLight1)
					{
						SelfLight1 = DarkDoomZ_Spotlight(Spawn("DarkDoomZ_Spotlight", Owner.Pos, false));
						SelfLight1.FollowTarget = Owner;
						SelfLight1.Args[DynamicLight.LIGHT_RED] = R;
						SelfLight1.Args[DynamicLight.LIGHT_GREEN] = G;
						SelfLight1.Args[DynamicLight.LIGHT_BLUE] = B;
						SelfLight1.Args[DynamicLight.LIGHT_INTENSITY] = (beamRadius + spillRadius) / 2;
						SelfLight1.SpotInnerAngle = (beamInner + spillInner) / 2;
						SelfLight1.SpotOuterAngle = (beamOuter + spillOuter) / 2;
						SelfLight1.Angle = Owner.Angle;
						SelfLight1.Pitch = Owner.Pitch;
						SelfLight1.spring = spring;
						SelfLight1.damping = damping;
						SelfLight1.inertia = inertia;
						SelfLight1.offsetAngle = offsetAngle;
						SelfLight1.offsetZ = offsetZ;
					}
					break;
				case 1:
					if (!SelfLight1)
					{
						SelfLight1 = DarkDoomZ_Spotlight(Spawn("DarkDoomZ_Spotlight", Owner.Pos, false));
						SelfLight1.FollowTarget = Owner;
						SelfLight1.Args[DynamicLight.LIGHT_RED] = R;
						SelfLight1.Args[DynamicLight.LIGHT_GREEN] = G;
						SelfLight1.Args[DynamicLight.LIGHT_BLUE] = B;
						SelfLight1.Args[DynamicLight.LIGHT_INTENSITY] = beamRadius;
						SelfLight1.SpotInnerAngle = beamInner;
						SelfLight1.SpotOuterAngle = beamOuter;
						SelfLight1.Angle = Owner.Angle;
						SelfLight1.Pitch = Owner.Pitch;
						SelfLight1.spring = spring;
						SelfLight1.damping = damping;
						SelfLight1.inertia = inertia;
						SelfLight1.offsetAngle = offsetAngle;
						SelfLight1.offsetZ = offsetZ;
					}
					if (!SelfLight2)
					{
						SelfLight2 = DarkDoomZ_Spotlight(Spawn("DarkDoomZ_Spotlight", Owner.Pos, false));
						SelfLight2.FollowTarget = Owner;
						SelfLight2.Args[DynamicLight.LIGHT_RED] = int(R * 0.75);
						SelfLight2.Args[DynamicLight.LIGHT_GREEN] = int(G * 0.75);
						SelfLight2.Args[DynamicLight.LIGHT_BLUE] = int(B * 0.75);
						SelfLight2.Args[DynamicLight.LIGHT_INTENSITY] = spillRadius;
						SelfLight2.SpotInnerAngle = spillInner;
						SelfLight2.SpotOuterAngle = spillOuter;
						SelfLight2.Angle = Owner.Angle;
						SelfLight2.Pitch = Owner.Pitch;
						SelfLight2.spring = spring;
						SelfLight2.damping = damping;
						SelfLight2.inertia = inertia;
						SelfLight2.offsetAngle = offsetAngle;
						SelfLight2.offsetZ = offsetZ;
					}
					break;
			}
		}
		else
		{
			if (SelfLight1) { SelfLight1.Destroy(); }
			if (SelfLight2) { SelfLight2.Destroy(); }
		}
		OldQuality = Quality;
		OldType = Type;
		OldMount = Mount;
	}

	States
	{
	Spawn:
		ROCK A -1;
		Stop;
	Use:
		TNT1 A 1 { Invoker.ToggleActive(); }
		Loop;
	}

	virtual void ToggleActive()
	{
		Active = !Active;
		Owner.A_StartSound("DarkDoomZ/Flashlight/Click", CHAN_AUTO, 0, 0.5);
	}
}

class DarkDoomZ_Spotlight : DynamicLight
{
	Actor FollowTarget;
	double vela, velp;
	double spring, damping;
	double offsetAngle, offsetZ;
	Vector3 targetPos;
	int inertia;

	default
	{
		DynamicLight.Type "Point";
		+DYNAMICLIGHT.ATTENUATE;
		+DYNAMICLIGHT.SPOT;
	}

	override void Tick()
	{
		Super.Tick();
		if (FollowTarget && FollowTarget.player)
		{
			if (inertia == 0) inertia = 1;
			targetPos = FollowTarget.Vec3Angle(
				2 + (6 * abs(sin(offsetAngle))),
				FollowTarget.Angle + offsetAngle,
				FollowTarget.player.viewz - FollowTarget.pos.z + offsetZ,
				false);
			vel.x += DampedSpring(Pos.X, targetPos.X, vel.x, 1, 1);
			vel.y += DampedSpring(Pos.Y, targetPos.Y, vel.y, 1, 1);
			vel.z += DampedSpring(Pos.Z, targetPos.Z, vel.z, 1, 1);
			vela += DampedSpring(Angle, FollowTarget.Angle, vela, spring, damping);
			velp += DampedSpring(Pitch, FollowTarget.Pitch, velp, spring, damping);
			SetOrigin(Pos + vel, true);
			A_SetAngle(Angle + (vela / inertia), true);
			A_SetPitch(Pitch + (velp / inertia), true);
		}
	}

	double DampedSpring(double p, double r, double v, double k, double d)
	{
		return -(d * v) - (k * (p - r));
	}
}

class SSSDarkDoomOptionMenu : OptionMenu
{
	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		Super.Init(parent, desc);
		DontDim = true;
		DontBlur = true;
	}
}

// Runs last on map load so Dark Doom sector levels win over enhanced-lighting passes.
class SSSMapLoadHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		SSSLightingHandler lighting = SSSLightingHandler.FindHandler();
		if (lighting && lighting.LightingLoadPending)
		{
			lighting.DeferDarkDoomFinish = true;
			return;
		}

		SSSDarkDoom_Handler ddz = SSSDarkDoom_Handler.FindHandler();
		if (!ddz)
			return;

		ddz.RefreshBaseLightLevelsFromMap();
		ddz.FinishMapLoadLighting();
	}
}
