/*
   "Technicolor" filter from MariENB
   (C)2012-2021 Marisa Kirisame
*/
void main()
{
	vec2 coord = TexCoord;
	vec4 res = texture(InputTexture,coord);
	res.rgb = clamp(res.rgb,0.,1.);
	float red = 1.-(res.r-(res.g+res.b)*.5);
	float green = 1.-(res.g-(res.r+res.b)*.5);
	float blue = 1.-(res.b-(res.r+res.g)*.5);
	vec3 tint = vec3(green*blue,red*blue,red*green)*res.rgb;
	res.rgb = mix(res.rgb,res.rgb+.5*(tint-res.rgb),techblend);
	FragColor = res;
}
