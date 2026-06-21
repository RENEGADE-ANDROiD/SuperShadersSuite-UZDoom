// Digital body-worn camera: rolling shutter, sensor noise, scanlines, banding, vignette.
// Wide-angle barrel/chroma come from the fisheye post shader (enabled alongside this).

float hash21(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 rollingShutterUV(vec2 uv, float skewX, float skewY, float amount)
{
	float scan = uv.y - 0.5;
	uv.x += skewX * scan * amount;
	uv.y += skewY * scan * amount * 0.35;
	uv.x += sin(iTime * 4.2 + uv.y * 18.0) * 0.0012 * amount;
	return uv;
}

vec3 gradeColor(vec3 c, float contrast, float saturation)
{
	c = (c - 0.5) * contrast + 0.5;
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	return mix(vec3(luma), c, saturation);
}

void main()
{
	vec2 uv = TexCoord;
	vec2 res = vec2(textureSize(InputTexture, 0));

	uv = rollingShutterUV(uv, rollSkewX, rollSkewY, rollStrength);

	float motion = abs(rollSkewX) + abs(rollSkewY);
	if (motion > 0.0003)
	{
		vec2 block = floor(uv * res / 8.0) / res * 8.0 + 0.5 / res;
		uv = mix(uv, block, clamp(motion * 180.0, 0.0, 0.35));
	}

	vec3 color = texture(InputTexture, uv).rgb;
	color = gradeColor(color, contrast, saturation);

	// Macroblock grid shimmer under motion.
	vec2 macro = floor(uv * res / 16.0);
	float macroHash = hash21(macro + vec2(iTime * 2.0, 0.0));
	color += (macroHash - 0.5) * noiseStrength * (0.15 + motion * 40.0);

	// Horizontal CMOS scanlines.
	float scan = sin(uv.y * res.y * 3.14159 * 2.0) * 0.5 + 0.5;
	color *= 1.0 - scan * 0.055;

	// Flat sensor noise (always visible at default strength).
	float grain = hash21(uv * res + vec2(iTime * 19.0, iTime * 5.7));
	color += (grain - 0.5) * noiseStrength;

	// Cheap 6-bit sensor banding.
	color = floor(color * 28.0 + grain * 0.5) / 28.0;

	// Edge chromatic smear on the final plate.
	float edge = length(uv - 0.5);
	vec2 ca = (uv - 0.5) * chromaStrength * edge * 2.5;
	color.r = texture(InputTexture, uv + ca).r;
	color.b = texture(InputTexture, uv - ca * 0.85).b;

	// Lens vignette / cheap housing shadow.
	float vig = 1.0 - dot((TexCoord - 0.5) * vec2(1.25, 1.05), (TexCoord - 0.5) * vec2(1.25, 1.05)) * 0.55;
	color *= clamp(vig, 0.55, 1.0);

	FragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
