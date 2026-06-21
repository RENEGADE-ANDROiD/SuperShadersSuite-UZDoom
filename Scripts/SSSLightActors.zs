class sss_lightanchor : Actor
{
	Default
	{
		+NOINTERACTION
		+NOTONAUTOMAP
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
	}
}

class sss_proplight : sss_lightanchor
{
	void ConfigurePoint(int lightLevel, Color col, double strength)
	{
		double scale = clamp(lightLevel / 255.0, 0.15, 1.0) * strength;
		A_AttachLight("sss_prop",
			DynamicLight.PointLight,
			col,
			0,
			int(48.0 * scale + 24.0),
			DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_DONTLIGHTACTORS);
	}

	void ConfigureSpot(int lightLevel, Color col, double strength)
	{
		double scale = clamp(lightLevel / 255.0, 0.15, 1.0) * strength;
		A_AttachLight("sss_prop",
			DynamicLight.PointLight,
			col,
			0,
			int(56.0 * scale + 28.0),
			DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_SPOT | DYNAMICLIGHT.LF_DONTLIGHTACTORS,
			spoti: 12.0 * scale + 8.0,
			spoto: 72.0 * scale + 32.0,
			spotp: 72.0);
	}

	void ConfigureDoor(int brightLight, double openness, double strength, double yaw, double pitch)
	{
		double scale = clamp(brightLight / 255.0, 0.15, 1.0) * clamp(openness, 0.0, 1.0) * strength;
		if (scale < 0.04)
			return;

		angle = yaw;
		A_AttachLight("sss_door",
			DynamicLight.PointLight,
			Color(255, 236, 204),
			0,
			int(36.0 * scale + 18.0),
			DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_SPOT | DYNAMICLIGHT.LF_DONTLIGHTACTORS,
			spoti: 8.0 * scale + 5.0,
			spoto: 56.0 * scale + 22.0,
			spotp: pitch);
	}
}

class sss_wallshadow : Actor
{
	int lifespan;
	Default
	{
		RenderStyle "Stencil";
		StencilColor "Black";
		+WALLSPRITE
		+NOINTERACTION
		+NOTONAUTOMAP
		+NOBLOCKMAP
		+DONTSPLASH
	}
	States
	{
	Spawn:
		SSSH A -1;
		Stop;
	}
	override void Tick()
	{
		Super.Tick();
		if (lifespan > 0 && --lifespan <= 0)
			Destroy();
	}
}
