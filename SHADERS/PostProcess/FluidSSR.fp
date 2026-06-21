// Screen-space fluid reflection boost on allowlisted fluid flats only.
// Full effect requires standing on a matching floor sector (see SSSRTLiteHandler).

vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = (c.g < c.b) ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = (c.r < p.x) ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main()
{
	vec4 color = texture(InputTexture, TexCoord);
	vec3 hsv = rgb2hsv(color.rgb);

	float fluidMask = smoothstep(0.35, 0.65, hsv.y) * smoothstep(0.12, 0.40, hsv.z) * (1.0 - smoothstep(0.82, 0.98, hsv.z));
	if (fluidMask <= 0.001)
	{
		FragColor = color;
		return;
	}

	vec2 reflUV = vec2(TexCoord.x, 1.0 - TexCoord.y);
	vec3 reflection = texture(InputTexture, reflUV).rgb;
	float edgeFade = 1.0 - abs(TexCoord.y - 0.5) * 2.0;
	float blend = sss_fluidssr_strength * fluidMask * edgeFade * edgeFade;

	FragColor = vec4(mix(color.rgb, reflection, blend), color.a);
}
