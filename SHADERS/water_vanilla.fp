// Universal fluid flat material — animated ripples + env shine, no envmask required.

mat3 GetTBN()
{
	vec3 n = normalize(vWorldNormal.xyz);
	vec3 p = pixelpos.xyz;
	vec2 uv = vTexCoord.st;

	vec3 dp1 = dFdx(p);
	vec3 dp2 = dFdy(p);
	vec2 duv1 = dFdx(uv);
	vec2 duv2 = dFdy(uv);

	vec3 dp2perp = cross(n, dp2);
	vec3 dp1perp = cross(dp1, n);
	vec3 t = dp2perp * duv1.x + dp1perp * duv2.x;
	vec3 b = dp2perp * duv1.y + dp1perp * duv2.y;

	float invmax = inversesqrt(max(dot(t, t), dot(b, b)));
	return mat3(t * invmax, b * invmax, n);
}

vec2 RippleOffset(vec2 uv)
{
	float t = timer * 0.04;
	vec2 wave;
	wave.x = sin(uv.x * 18.0 + t * 2.1) * cos(uv.y * 14.0 - t * 1.7);
	wave.y = cos(uv.x * 16.0 - t * 1.5) * sin(uv.y * 20.0 + t * 2.3);
	return wave * 0.012;
}

Material ProcessMaterial()
{
	vec2 texCoord = vTexCoord.st + RippleOffset(vTexCoord.st);
	mat3 tbn = GetTBN();

	vec4 base = getTexel(texCoord);
	vec3 normal = normalize(vWorldNormal.xyz);
	vec3 viewDir = normalize(uCameraPos.xyz - pixelpos.xyz);
	float ndv = max(dot(normal, viewDir), 0.001);

	float gloss = max(uSpecularMaterial.x, 1.0);
	float level = uSpecularMaterial.y;
	float fresnel = pow(1.0 - ndv, clamp(2.5 + gloss * 0.35, 2.5, 8.0));
	float reflectMix = level * mix(0.35, 1.0, fresnel);

	vec2 envUV = normalize(transpose(tbn) * (uCameraPos.xyz - pixelpos.xyz)).xy;
	vec2 envSampleUV = envUV + RippleOffset(envUV) * 2.5;
	vec4 envSample = texture(displacement, envSampleUV);

	Material material;
	material.Base = base + envSample * reflectMix;
	material.Normal = normal;

#if defined(SPECULAR)
	material.Specular = vec3(reflectMix * 0.55);
	material.Glossiness = gloss;
	material.SpecularLevel = level;
#endif
#if defined(BRIGHTMAP)
	material.Bright = texture(brighttexture, texCoord);
#endif

	return material;
}
