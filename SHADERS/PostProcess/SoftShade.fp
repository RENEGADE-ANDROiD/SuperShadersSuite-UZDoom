#define d(x) x / 64.0
const float dither8[64] = float[] (
	d( 0.0),d(48.0),d(12.0),d(60.0),d( 3.0),d(51.0),d(15.0),d(63.0),
	d(32.0),d(16.0),d(44.0),d(28.0),d(35.0),d(19.0),d(47.0),d(31.0),
	d( 8.0),d(56.0),d( 4.0),d(52.0),d(11.0),d(59.0),d( 7.0),d(55.0),
	d(40.0),d(24.0),d(36.0),d(20.0),d(43.0),d(27.0),d(39.0),d(23.0),
	d( 2.0),d(50.0),d(14.0),d(62.0),d( 1.0),d(49.0),d(13.0),d(61.0),
	d(34.0),d(18.0),d(46.0),d(30.0),d(33.0),d(17.0),d(45.0),d(29.0),
	d(10.0),d(58.0),d( 6.0),d(54.0),d( 9.0),d(57.0),d( 5.0),d(53.0),
	d(42.0),d(26.0),d(38.0),d(22.0),d(41.0),d(25.0),d(37.0),d(21.0)
);
#undef d

float indexValue()
{
    int x = int(mod(gl_FragCoord.x, 8.0));
    int y = int(mod(gl_FragCoord.y, 8.0));
    return dither8[(x + y * 8)];
}

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
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0-K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

ivec2 getLUTCoordForRGB(vec3 fragcol)
{
    int b = int(clamp(fragcol.b * 63.0, 0.0, 63.0));
    ivec2 bluecoord = ivec2(b % 8, b / 8) * 64;
    ivec2 rgcoord = ivec2(
        int(clamp(fragcol.r * 63.0, 0.0, 63.0)),
        int(clamp(fragcol.g * 63.0, 0.0, 63.0)));

	return bluecoord + rgcoord;
}

void main()
{
	float paldither = paldither * resscalefac;

    // InputTexture is screen texture
    vec2 coord = TexCoord;
    vec4 fragcol = texture(InputTexture, coord);

	vec3 hsv = rgb2hsv(fragcol.rgb);
	hsv.y = clamp(hsv.y, 0.0, 1.0);
	hsv.z = max(hsv.z, 0.0);
	fragcol.rgb = hsv2rgb(hsv);

	if (fragcol.r <= 0.0) fragcol.r -= paldither;
	if (fragcol.g <= 0.0) fragcol.g -= paldither;
	if (fragcol.b <= 0.0) fragcol.b -= paldither;
	if (fragcol.r >= 1.0) fragcol.r += paldither;
	if (fragcol.g >= 1.0) fragcol.g += paldither;
	if (fragcol.b >= 1.0) fragcol.b += paldither;

	fragcol.rgb += paldither * indexValue() - 0.5 * paldither;
	fragcol = texelFetch(TexLUT8, getLUTCoordForRGB(fragcol.rgb), 0);

	FragColor = fragcol;
}
