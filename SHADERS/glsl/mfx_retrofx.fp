/*
   RetroFX downscaling from MariENB
   (C)2012-2021 Marisa Kirisame
*/
void main()
{
	// far more simplified when the actual scale calculations are on the zscript side
	ivec2 ncoord = ivec2((floor(TexCoord*bresl)/bresl)*textureSize(InputTexture,0));
	FragColor = texelFetch(InputTexture,ncoord,0);
}
