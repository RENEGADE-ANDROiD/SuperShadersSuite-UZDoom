/*
   LumaSharpen from MariENB
   (C)2012-2021 Marisa Kirisame
*/
#define luminance(x) dot(x,vec3(0.2126,0.7152,0.0722))

float TextureCrawlEffectKeep(vec2 uv, vec3 rgb, float flatSoften)
{
	if (flatSoften <= 0.001)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = luminance(rgb);
	float midTone = smoothstep(0.10, 0.28, l0) * (1.0 - smoothstep(0.72, 0.92, l0));

	float lXp = luminance(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = luminance(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = luminance(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = luminance(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float microAvg = (lXp + lXm + lYp + lYm) * 0.25;
	float microDev = max(max(abs(lXp - microAvg), abs(lXm - microAvg)),
	                     max(abs(lYp - microAvg), abs(lYm - microAvg)));

	vec2 ms = ts * 4.0;
	float LXp = luminance(texture(InputTexture, uv + vec2( ms.x, 0.0)).rgb);
	float LXm = luminance(texture(InputTexture, uv + vec2(-ms.x, 0.0)).rgb);
	float LYp = luminance(texture(InputTexture, uv + vec2(0.0,  ms.y)).rgb);
	float LYm = luminance(texture(InputTexture, uv + vec2(0.0, -ms.y)).rgb);
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
	float l0 = luminance(rgb);
	float lXp = luminance(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = luminance(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = luminance(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = luminance(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
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
	vec2 bof = (1.0/textureSize(InputTexture,0))*sharpradius;
	vec4 crawling = texture(InputTexture,coord+vec2(0,-1)*bof);
	crawling += texture(InputTexture,coord+vec2(-1,0)*bof);
	crawling += texture(InputTexture,coord+vec2(1,0)*bof);
	crawling += texture(InputTexture,coord+vec2(0,1)*bof);
	crawling *= 0.25;
	vec4 inmyskin = res-crawling;
	float thesewounds = luminance(inmyskin.rgb);
	thesewounds = clamp(thesewounds,-sharpclamp*0.01,sharpclamp*0.01);
	vec4 sharpened = res + thesewounds * sharpblend;
	float keep = TextureCrawlEffectKeep(coord, res.rgb, sss_pp_flat_soften);
	keep *= FloorTextureGuard(coord, res.rgb, sss_pp_flat_soften);
	FragColor = mix(res, sharpened, keep);
}
