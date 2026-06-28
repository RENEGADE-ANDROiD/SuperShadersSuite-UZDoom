/*
   BlurSharpShift sharpen from MariENB
   (C)2012-2021 Marisa Kirisame
*/
float TextureCrawlLuma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float TextureCrawlEffectKeep(vec2 uv, vec3 rgb, float flatSoften)
{
	if (flatSoften <= 0.001)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = TextureCrawlLuma(rgb);
	float midTone = smoothstep(0.10, 0.28, l0) * (1.0 - smoothstep(0.72, 0.92, l0));

	float lXp = TextureCrawlLuma(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = TextureCrawlLuma(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float microAvg = (lXp + lXm + lYp + lYm) * 0.25;
	float microDev = max(max(abs(lXp - microAvg), abs(lXm - microAvg)),
	                     max(abs(lYp - microAvg), abs(lYm - microAvg)));

	vec2 ms = ts * 4.0;
	float LXp = TextureCrawlLuma(texture(InputTexture, uv + vec2( ms.x, 0.0)).rgb);
	float LXm = TextureCrawlLuma(texture(InputTexture, uv + vec2(-ms.x, 0.0)).rgb);
	float LYp = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0,  ms.y)).rgb);
	float LYm = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0, -ms.y)).rgb);
	float macroAvg = (LXp + LXm + LYp + LYm) * 0.25;
	float macroEdge = abs(l0 - macroAvg);

	float crawl = clamp((microDev - macroEdge * 0.85) / 0.08, 0.0, 1.0);
	crawl *= midTone;
	float flatMacro = 1.0 - smoothstep(0.015, 0.09, macroEdge);
	float soften = crawl * flatMacro * flatSoften;

	return 1.0 - clamp(soften, 0.0, 0.95);
}

float FloorTextureGuard(vec2 uv, vec3 rgb, float flatSoften)
{
	if (flatSoften <= 0.001)
		return 1.0;

	float floorZone = smoothstep(0.42, 0.82, uv.y);
	if (floorZone < 0.01)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = TextureCrawlLuma(rgb);
	float lXp = TextureCrawlLuma(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = TextureCrawlLuma(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = TextureCrawlLuma(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float microAvg = (lXp + lXm + lYp + lYm) * 0.25;
	float microDev = max(max(abs(lXp - microAvg), abs(lXm - microAvg)),
	                     max(abs(lYp - microAvg), abs(lYm - microAvg)));

	float detail = clamp(microDev / 0.055, 0.0, 1.0);
	float kill = floorZone * detail * flatSoften;
	return 1.0 - clamp(kill, 0.0, 0.97);
}

void main()
{
	vec2 coord = TexCoord;
	vec4 res = texture(InputTexture,coord);
	vec2 ofs[8] = vec2[]
	(
		vec2(1.0,1.0), vec2(-1.0,-1.0),
		vec2(-1.0,1.0), vec2(1.0,-1.0),

		vec2(1.41,1.41), vec2(-1.41,-1.41),
		vec2(-1.41,1.41), vec2(1.41,-1.41)
	);
	vec2 bresl = textureSize(InputTexture,0);
	vec2 bof = (1.0/bresl)*bsssharpradius;
	vec4 tcol = res;
	int i;
	for ( i=0; i<8; i++ ) tcol += texture(InputTexture,coord+ofs[i]*bof);
	tcol /= 9.0;
	vec4 orig = res;
	res = orig*(1.0+dot(orig.rgb-tcol.rgb,vec3(0.333333))*bsssharpamount);
	float rg = clamp(pow(orig.b,3.0),0.0,1.0);
	vec4 sharpened = mix(res, orig, rg);
	float keep = TextureCrawlEffectKeep(coord, orig.rgb, sss_pp_flat_soften);
	keep *= FloorTextureGuard(coord, orig.rgb, sss_pp_flat_soften);
	FragColor = mix(orig, sharpened, keep);
}
