vec3 UserDeformation(vec3 position) {
	position.xy = rotate(position.xy, position.z * 0.04);
	
	return position;
}

vec3 Globe(vec3 position, cfloat radius) {
	position.y -= length2(position.xz) / radius;
	
	return position;
}

vec3 Acid(vec3 position) {
	position.xy = rotate(position.xy, sin(length2(position.xz) * 0.00005) * 0.8);
	
	return position;
}

vec3 TerrainDeformation(vec3 position) {
	
#ifdef DEFORM
	
	#if DEFORMATION == 1
		
		position = Globe(position, 500.0);
		
	#elif DEFORMATION == 2
		
		position = Acid(position);
		
	#else
		
		position = UserDeformation(position);
		
	#endif
	
#endif
	
	return position;
}
