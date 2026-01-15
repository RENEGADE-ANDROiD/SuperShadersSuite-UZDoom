void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;
	colour -= brightness;
	colour *= contrast;
	colour = pow(colour, vec3(gamma));
	FragColor = vec4(colour, 1.0);
}
