
// Start of #include "/lib/CalculateTBN.vsh"

// Prerequisites:
// 
// attribute vec4 at_tangent;
// 
// #include "/lib/VertexDisplacements.vsh"    // Excluding gbuffers_hand.vsh


void CalculateTBN(in vec3 position, out mat3 tbnMatrix, out vec3 normal) {
	vec3 tangent  = normalize(                  at_tangent.xyz );
	vec3 binormal = normalize(-cross(gl_Normal, at_tangent.xyz));
	
	#if (defined RECALCULATE_DISPLACED_NORMALS) && (!defined hand_vsh)
	tangent  += CalculateVertexDisplacements(position +  tangent) * 0.3;
	binormal += CalculateVertexDisplacements(position + binormal) * 0.3;
	#endif
	
	tangent  = normalize(gl_NormalMatrix * tangent);
	binormal = normalize(gl_NormalMatrix * binormal);
	
	normal = cross(-tangent, binormal);
	
	tbnMatrix = mat3(
	tangent.x, binormal.x, normal.x,
	tangent.y, binormal.y, normal.y,
	tangent.z, binormal.z, normal.z);
}


// End of #include "/lib/CalculateTBN.vsh"