// Color bleeding post-process (ported from ReLite 0.7.4, Relighting-inspired grade)
vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = (c.g < c.b) ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = (c.r < p.x) ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	vec2 coord = TexCoord;
	vec4 res = texture(InputTexture, coord);
	vec3 c = res.rgb;

	if (sss_bleed_gamma > 0.001)
		c = pow(max(c, vec3(0.0)), vec3(1.0 / sss_bleed_gamma));

	vec3 chsv = rgb2hsv(c);
	if ((c.r > c.g && c.r > c.b) || (c.g > c.r && c.g > c.b))
	{
		chsv.y *= sss_bleed_saturation;
		if (chsv.z < 0.5) chsv.z *= 1.05;
	}
	else if (c.r > 0.2 || c.g > 0.8)
	{
		chsv.y *= sss_bleed_saturation;
		if (chsv.z < 0.5) chsv.z *= 1.025;
	}
	else if (c.b > 0.3)
	{
		chsv.y *= 0.95;
		chsv.z *= 0.95;
	}
	c = hsv2rgb(chsv);

	chsv = rgb2hsv(c);
	if (chsv.z > 0.85)
	{
		vec3 mixCol = c.gbr + c.brg;
		if (sss_bleed_rg > 0.5)
			mixCol = c.ggr + c.rrg;
		float bleedScale = 1.0 - clamp((chsv.z - 0.88) / 0.12, 0.0, 1.0);
		c.rgb += mixCol * mixCol * sss_bleeding * chsv.z * bleedScale;
		res.rgb = c;
	}
	else if (chsv.z < 0.30)
	{
		vec3 mixCol = c.gbr + c.brg;
		if (sss_bleed_rg > 0.5)
			mixCol = c.ggr + c.rrg;
		c.rgb -= mixCol * mixCol * mixCol * sss_bleeding * (1.0 - chsv.z);
		res.rgb = c;
	}

	chsv = rgb2hsv(c);
	if (chsv.z > 0.85)
	{
		float t = clamp((chsv.z - 0.85) / 0.15, 0.0, 1.0);
		chsv.y *= mix(1.06, 0.58, t * t);
		c = hsv2rgb(chsv);
	}
	else if (chsv.z < 0.30)
	{
		chsv.y *= (1.0 - chsv.z);
		c = hsv2rgb(chsv);
	}

	FragColor = vec4(c, res.a);
}
