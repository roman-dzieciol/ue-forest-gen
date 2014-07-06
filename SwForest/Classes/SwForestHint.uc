// ============================================================================
//  SwForestStart.uc:
// ============================================================================
//  Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwForestHint extends Actor
    placeable;

#exec Texture Import File=Textures\TPlant.bmp Mips=Off

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'SwForest.TPlant'
     DrawScale=5.000000
     CollisionRadius=0.000000
     CollisionHeight=1024.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
