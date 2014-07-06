// ============================================================================
//  SwForestTemplate.uc:
// ============================================================================
//  Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwForestTemplate extends Object
    editinlinenew
    abstract
    hidecategories(Object);


// Internal
var transient bool bInUse;


function Clean();
function CleanRefs();
function Initialize( SwForestGen T, int PlantIndex );
function bool NoErrors( SwForestGen T, int PlantIndex );
function bool SpawnPlants( SwForestGen Gen, int PlantIndex );
function Randomize( SwForestGen Gen, int PlantIndex );
function UpdatePrecacheStaticMeshes( SwForestGen T, int PlantIndex );


final static operator(0) bool swap( out byte    A, out byte     B ){ local byte     t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out int     A, out int      B ){ local int      t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out float   A, out float    B ){ local float    t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out string  A, out string   B ){ local string   t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out vector  A, out vector   B ){ local vector   t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out rotator A, out rotator  B ){ local rotator  t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out name    A, out name     B ){ local name     t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out class   A, out class    B ){ local class    t; t=A; A=B; B=t; return true; }
final static operator(0) bool swap( out object  A, out object   B ){ local object   t; t=A; A=B; B=t; return true; }


// =============================================================================
//  DefaultProperties
// =============================================================================

defaultproperties
{
}
