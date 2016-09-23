struct Mask {
	float materialIDs;
	float matIDs;
	
	vec4 bits;
	
	float grass;
	float leaves;
	float water;
	float hand;
	
	float metallic;
	float transparent;
};

float EncodeMaterialIDs(float materialIDs, vec4 bits) {
	materialIDs += dot(vec4(greaterThan(bits, vec4(0.5))), vec4(128.0, 64.0, 32.0, 16.0));
	
	materialIDs += 0.1;
	materialIDs /= 255.0;
	
	return materialIDs;
}

void DecodeMaterialIDs(inout float matID, out vec4 bits) {
	matID *= 255.0;
	
	bits = mod(vec4(matID), vec4(256.0, 128.0, 64.0, 32.0));
	
	bits = vec4(greaterThanEqual(bits, vec4(128.0, 64.0, 32.0, 16.0)));
	
	matID -= dot(bits, vec4(128.0, 64.0, 32.0, 16.0));
}

float GetMaterialMask(float mask, float materialID) {
	return float(abs(materialID - mask) < 0.5);
}

Mask CalculateMasks(float materialIDs) {
	Mask mask;
	
	mask.materialIDs = materialIDs;
	mask.matIDs      = materialIDs;
	
	DecodeMaterialIDs(mask.matIDs, mask.bits);
	
	mask.grass  = GetMaterialMask(2, mask.matIDs);
	mask.leaves = GetMaterialMask(3, mask.matIDs);
	mask.hand   = GetMaterialMask(5, mask.matIDs);
	
	mask.metallic    = mask.bits.x;
	mask.transparent = mask.bits.y;
	mask.water       = mask.bits.z;
	
	return mask;
}
