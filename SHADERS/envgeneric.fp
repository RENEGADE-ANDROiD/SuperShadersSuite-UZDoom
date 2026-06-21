// Generic environment shine: no per-texture envmask patterns.
// Works with replacement texture packs that keep standard Doom flat/wall names.

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

Material ProcessMaterial()
{
    vec2 texCoord = vTexCoord.st;
    mat3 tbn = GetTBN();

    vec4 base = getTexel(texCoord);
    vec3 normal = normalize(vWorldNormal.xyz);
    vec3 viewDir = normalize(uCameraPos.xyz - pixelpos.xyz);
    float ndv = max(dot(normal, viewDir), 0.001);

    float gloss = max(uSpecularMaterial.x, 1.0);
    float level = uSpecularMaterial.y;
    float fresnel = pow(1.0 - ndv, clamp(2.0 + gloss * 0.3, 2.0, 7.0));
    float reflectMix = level * mix(0.22, 0.95, fresnel);

    vec2 envUV = normalize(transpose(tbn) * (uCameraPos.xyz - pixelpos.xyz)).xy;
    vec4 envSample = texture(displacement, envUV);

    Material material;
    material.Base = base + envSample * reflectMix;
    material.Normal = normal;

#if defined(SPECULAR)
    material.Specular = vec3(reflectMix * 0.45);
    material.Glossiness = gloss;
    material.SpecularLevel = level;
#endif
#if defined(BRIGHTMAP)
    material.Bright = texture(brighttexture, texCoord);
#endif

    return material;
}
