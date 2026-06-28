// Screen-space fluid reflection with distortion + ripple (player on fluid flat only).

vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = (c.g < c.b) ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = (c.r < p.x) ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float SkyMask(vec2 uv, vec3 rgb)
{
	float luma = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
	float upper = smoothstep(0.10, 0.50, uv.y);
	float bright = smoothstep(0.18, 0.48, luma);
	float peak = smoothstep(0.45, 0.78, max(max(rgb.r, rgb.g), rgb.b));
	float cloudBody = upper * smoothstep(0.12, 0.38, luma);
	float brightSky = upper * bright * mix(0.7, 1.0, peak);
	return clamp(max(cloudBody, brightSky), 0.0, 1.0);
}

// Depth proxy: lower screen + local contrast (engine depth unavailable to custom PP).
float DepthProxy(vec2 uv, vec3 rgb)
{
	if (sss_depth_proxy <= 0.001)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
	float lXp = dot(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb, vec3(0.2126, 0.7152, 0.0722));
	float lXm = dot(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb, vec3(0.2126, 0.7152, 0.0722));
	float edge = abs(lXp - lXm);
	float lower = 1.0 - smoothstep(0.15, 0.75, uv.y);
	return clamp(lower * (0.35 + edge * 4.0) * sss_depth_proxy, 0.0, 1.0);
}

vec2 Ripple(vec2 uv)
{
	float t = floor(sss_fluidssr_time * 0.25) * 4.0;
	vec2 wave;
	wave.x = sin(uv.x * 24.0 + t * 2.0) * cos(uv.y * 18.0 - t * 1.6);
	wave.y = cos(uv.x * 20.0 - t * 1.4) * sin(uv.y * 22.0 + t * 2.2);
	return wave * sss_fluidssr_ripple * 0.015;
}

void main()
{
	vec4 color = texture(InputTexture, TexCoord);
	if (TexCoord.y > 0.38)
	{
		FragColor = color;
		return;
	}

	if (SkyMask(TexCoord, color.rgb) > 0.18)
	{
		FragColor = color;
		return;
	}

	vec3 hsv = rgb2hsv(color.rgb);
	float fluidMask = smoothstep(0.35, 0.65, hsv.y) * smoothstep(0.12, 0.40, hsv.z) * (1.0 - smoothstep(0.82, 0.98, hsv.z));
	if (fluidMask <= 0.001)
	{
		FragColor = color;
		return;
	}

	vec2 reflBase = vec2(TexCoord.x, 1.0 - TexCoord.y);
	vec2 distort = Ripple(TexCoord) * sss_fluidssr_distortion;
	vec3 reflection = texture(InputTexture, reflBase + distort).rgb;

	// Fresnel-like: stronger reflection toward lower screen (floor region).
	float fresnel = smoothstep(0.35, 0.05, TexCoord.y);
	float edgeFade = 1.0 - abs(TexCoord.y - 0.5) * 2.0;
	float depthW = DepthProxy(TexCoord, color.rgb);
	float blend = sss_fluidssr_strength * fluidMask * edgeFade * edgeFade * mix(0.65, 1.0, fresnel) * depthW;

	FragColor = vec4(mix(color.rgb, reflection, blend), color.a);
}
