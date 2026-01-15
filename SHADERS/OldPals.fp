vec3 Tonemap(vec3 color)
{
	ivec3 c = ivec3(clamp(color, vec3(0.0), vec3(1.0)) * 255.0 + 0.5);
	int index = (c.r * 256 + c.g) * 256 + c.b;
	
	int tx = index % 4096;
	int ty = int(index * 0.000244140625);
	
	return vec3(texelFetch(OldPalLut, ivec2(tx, ty), 0).rgb);
}

void main()
{
	vec3 base = texture(InputTexture, TexCoord).rgb;
	//base = pow(base, vec3(invYbias));
	
	vec3 blend = Tonemap(base);
	vec3 colour = base * invamount + (blend * amount);
	//colour = pow(colour, vec3(Ybias));
	
	FragColor = vec4(colour, 1.0);
}