/*
   LUT color grading from MariENB
   (C)2012-2021 Marisa Kirisame
*/

void main()
{
	vec2 coord = TexCoord;
	vec4 res = texture(InputTexture,coord);
	vec3 lc = clamp(res.rgb,0.,63./64.);
	vec2 lcoord = vec2((lc.r+lutindex)/16.,lc.g/64.)+vec2(1./2048,1./8192.);
	double minb = floor(lc.b*64.)/64.;
	double maxb = ceil(lc.b*64.)/64.;
	double theta = fract(lc.b*64.);
	vec3 luta = textureLod(LUTTexture,lcoord+vec2(0,minb),0.).rgb;
	vec3 lutb = textureLod(LUTTexture,lcoord+vec2(0,maxb),0.).rgb;
	vec3 lutm = mix(luta,lutb,vec3(theta));	// has to be vec3 for whatever reason
	res.rgb = mix(res.rgb,lutm,lutblend);
	FragColor = res;
}
