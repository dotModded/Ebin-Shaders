vec3 WaterFog(vec3 color, vec3 viewSpacePosition0, vec3 viewSpacePosition1) {
	viewSpacePosition1 *= 1 - isEyeInWater;
	
	float waterDepth = distance(viewSpacePosition1, viewSpacePosition0); // Depth of the water volume
	
	float fogAccum = exp(-waterDepth * 0.1); // Beer's Law
	
	vec3 waterDepthColors = vec3(0.015, 0.04, 0.098) * sunlightColor * mix(0.2, 1.0, eyeBrightnessSmooth.g / 240.0);
	
	color *= pow(vec3(0.1, 0.5, 0.8), vec3(waterDepth) * 0.8);
	color  = mix(waterDepthColors, color, clamp01(fogAccum));
	
	return color;
}
