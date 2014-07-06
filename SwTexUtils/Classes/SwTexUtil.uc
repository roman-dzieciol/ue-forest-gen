// ============================================================================
//	SwTexUtil.uc:
// ============================================================================
//	Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwTexUtil extends Object
	native;
	
// ACHTUNG! FUCKUP!!
// In 3369+ USwTexUtil needs special padding variable:
// class UObject* Unknown;

var native Texture 		TexRef;
var native array<byte> 	TexData;
var native byte 		TexChannel;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native final static function bool ReadChannel();

defaultproperties
{
}
