// DarkDoomZ sector darkening + flashlight, integrated with SSS enhanced lighting.
// Based on DarkDoomZ by Sterling "Caligari87" Parker (zlib license).

class SSSDarkDoom_Handler : EventHandler
{
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

		SetReliteFloat("sss_darken", ReliteDarkenWeight[p] / 1000.0);
		SetReliteFloat("sss_brighten", ReliteBrightenWeight[p] / 1000.0);
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
	int BaseAdjustment, FinalAdjustment;
	bool IsSky;

	override void WorldLoaded(WorldEvent e)
	{
		if (!CVar.FindCVar("ddz_lighting").GetBool())
		{
			ThinkerIterator it = ThinkerIterator.Create("Lighting");
			Lighting effect;
			while (effect = Lighting(it.Next())) { effect.Destroy(); }
		}

		BaseLightLevels.Clear();
		for (int i = 0; i < Level.Sectors.Size(); i++)
			BaseLightLevels.Push(Level.Sectors[i].LightLevel);

		ChangeLighting(true);

		if (e.IsReopen)
		{
			let iterator = ThinkerIterator.Create("DarkDoomZ_Spotlight");
			for (Thinker mo; (mo = iterator.Next());)
				mo.Destroy();
		}
	}

	override void PlayerSpawned(PlayerEvent e)
	{
		if (!CVar.FindCVar("sss_darkdoom_flashlight").GetBool())
			return;

		PlayerInfo player = players[e.PlayerNumber];
		let FlashlightClass = (class<Inventory>)(Actor.GetReplacement("DarkDoomZ_Flashlight"));
		player.mo.GiveInventory(FlashlightClass, 1);
	}

	override void UiTick()
	{
		int mode = CVar.FindCVar("ddz_mode").GetInt();
		int preset = CVar.FindCVar("ddz_preset").GetInt();
		int preGain = CVar.FindCVar("ddz_pregain").GetInt();
		int postGain = CVar.FindCVar("ddz_postgain").GetInt();
		double skyMode = CVar.FindCVar("ddz_skymode").GetFloat();
		int fogDensity = CVar.FindCVar("ddz_fog").GetInt();
		int minLight = CVar.FindCVar("ddz_minlight").GetInt();
		bool reliteSync = CVar.FindCVar("sss_darkdoom_relite_sync").GetBool();
		if (OldMode == mode
			&& OldPreset == preset
			&& OldPreGain == preGain
			&& OldPostGain == postGain
			&& OldSkyMode == skyMode
			&& OldFogDensity == fogDensity
			&& OldMinLight == minLight
			&& OldReliteSync == reliteSync)
			return;

		EventHandler.SendNetworkEvent("SSSUpdateDarkDoom");
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "SSSUpdateDarkDoom")
			ChangeLighting(false);
		if (e.Name == "SSSReapplyDarkDoomSectors")
			ApplySectorDarkening();
		if (e.Name == "sss_apply_reflections")
			SSSReflectionHelper.ApplyPlaneReflections();
	}

	void ReadDarkDoomCvars()
	{
		Mode = CVar.FindCVar("ddz_mode").GetInt();
		Preset = CVar.FindCVar("ddz_preset").GetInt();
		PreGain = CVar.FindCVar("ddz_pregain").GetInt();
		PostGain = CVar.FindCVar("ddz_postgain").GetInt();
		SkyMode = CVar.FindCVar("ddz_skymode").GetFloat();
		FogDensity = CVar.FindCVar("ddz_fog").GetInt();
		MinLight = CVar.FindCVar("ddz_minlight").GetInt();
	}

	void ApplySectorDarkening()
	{
		if (BaseLightLevels.Size() != Level.Sectors.Size())
			return;

		ReadDarkDoomCvars();
		BaseAdjustment = 32 * Preset;
		for (int i = 0; i < BaseLightLevels.Size(); i++)
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
	}

	void ChangeLighting(bool forceRelite)
	{
		ReadDarkDoomCvars();
		bool reliteSync = CVar.FindCVar("sss_darkdoom_relite_sync").GetBool();

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
			if (Mode >= 10)
				ApplyReliteClassicMode(Mode);
			else if (Mode == 0 || Preset == 0)
				ApplyRelitePreset(0);
			else
				ApplyRelitePreset(Preset);

			ApplySectorDarkening();
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
			EventHandler.SendNetworkEvent("sss_apply_reflections");
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
		EventHandler.SendNetworkEvent("SSSReapplyDarkDoomSectors");
	}
}
