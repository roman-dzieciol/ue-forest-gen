// ============================================================================
//  SwForestGen.uc:
// ============================================================================
//  Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwForestGen extends Actor
    placeable;

#exec Texture Import File=Textures\TForestGen.bmp Mips=Off


enum EAction
{
    AC_Rebuild,
    AC_Randomize,
    AC_Keep,
    AC_Erase
};

enum EMaskMode
{
    MM_Alpha,
    MM_Any
};

enum ETraceResult
{
    TR_Invalid,
    TR_Valid,
    TR_NoActor,
    TR_GridIdx,
    TR_GridFail,
    TR_MaskIdx,
    TR_MaskFail,
    TR_Bounds,
    TR_Parents
};

struct sPlant
{
    var() editconst editconstarray array<Actor>     Actors;     // Actor Instances
    var() editconst byte                            Alpha;      // Mask Value
    var() editconst vector                          Angle;      // Floor Angle
    var() editconst vector                          Location;   // World Location
};

struct sGrid
{
    var transient array<vector>     Locations;
};



// - Cache --------------------------------------------------------------------

var(Debug) int                      PlantCount;         // Current number of plants
var(Debug) float                    PlantCollisionRadius;    // Plant Radius + Spacing
var(Debug) float                    PlantCollisionDiameter;  // CollisionRadius*2
var(Debug) float                    PlantTrunkOffset;        //

var(Debug) float                    MaskToX;            // Multiply by Location.X to get X sector index
var(Debug) float                    MaskToY;            // Multiply by Location.Y to get Y sector index
var(Debug) float                    MaskSizeX;          // UU
var(Debug) float                    MaskSizeY;          // UU
var(Debug) float                    MaskSizeZ;          // UU
var(Debug) int                      MaskTerrX;          // Index, TerrainInfo X offset
var(Debug) int                      MaskTerrY;          // Index, TerrainInfo Y offset
var(Debug) int                      MaskSizeU;          //
var(Debug) int                      MaskSizeV;          //
var(Debug) int                      MaskSizeUV;         //

var(Debug) vector                   TraceTop;           //
var(Debug) vector                   TraceBottom;        //

var(Debug) float                    TerrainLocationX;   //
var(Debug) float                    TerrainLocationY;   //
var(Debug) float                    TerrainLocationZ;   //
var(Debug) float                    TerrainScaleX;      //
var(Debug) float                    TerrainScaleY;      //
var(Debug) float                    TerrainScaleZ;      //
var(Debug) float                    TerrainSizeX;       //
var(Debug) float                    TerrainSizeY;       //
var(Debug) float                    TerrainSizeZ;       //
var(Debug) float                    TerrainSector;      //

var(Debug) float                    GridCell;           // UU
var(Debug) int                      GridCellsX;         //
var(Debug) int                      GridCellsY;         //
var(Debug) int                      GridCellsXY;        //
var(Debug) float                    GridToX;            // Multiply by Location.X to get X sector index
var(Debug) float                    GridToY;            // Multiply by Location.Y to get Y sector index
var(Debug) float                    GridSizeX;          // UU
var(Debug) float                    GridSizeY;          // UU
var(Debug) int                      GridTerrX;          // Index, TerrainInfo X offset
var(Debug) int                      GridTerrY;          // Index, TerrainInfo Y offset


var(Debug) int                  ERR_Invalid;
var(Debug) int                  ERR_Valid;
var(Debug) int                  ERR_NoActor;
var(Debug) int                  ERR_GridIdx;
var(Debug) int                  ERR_GridFail;
var(Debug) int                  ERR_MaskIdx;
var(Debug) int                  ERR_MaskFail;
var(Debug) int                  ERR_Bounds;
var(Debug) int                  ERR_Parents;


// - Internal -----------------------------------------------------------------

var(Debug) string  LogName;

var(Debug) editconst editconstarray array<sPlant>               Plants;
var(Debug) editconst editconstarray array<sGrid>                Grid;
var(Debug) editconst editconstarray array<byte>                 Mask;
var(Debug) editconst editconstarray array<SwForestHint>         Hints;
var(Debug) editconst editconstarray array<SwForestGen>          Parents;
var(Debug) bool bParents;




// - Options ------------------------------------------------------------------

var(Forest) EAction                                 Action;             // What should this generator do
var(Forest) array<string>                           Description;        // Your notes go here

var(Forest) EMaskMode                               MaskMode;           // How to interpret the mask data
var(Forest) edfindable SwForestHint                 MaskHints[16];      // See Below
var(Forest) edfindable SwForestGen                  MaskParents[8];     //
var(Forest) edfindable TerrainInfo                  MaskTerrain;        // TerrainInfo Actor to use
var(Forest) Texture                                 MaskTexture;        // Mask Texture
var(Forest) byte                                    MaskThreshold;      // See Below

var(Forest) int                                     PlantLimit;         // Max number of plants
var(Forest) vector                                	PlantOffset3D;    	//
var(Forest) float                                   PlantRadiusMax;     // Biggest radius of plant (ie corona)
var(Forest) float                                   PlantRadiusMin;     // Smallest radius of plant's (ie trunk)
var(Forest) float                                   PlantScaleMax;      // Plant scale
var(Forest) float                                   PlantScaleMin;      //
var(Forest) byte                                    PlantSeedsMax;      // Number of neighbours to plant
var(Forest) byte                                    PlantSeedsMin;      //
var(Forest) float                                   PlantSlopeAdjust;   //
var(Forest) float                                   PlantSpacingMax;    // Extra spacing between plants
var(Forest) float                                   PlantSpacingMin;    //

var(Forest) bool                                    RandRotate;
var(Forest) float                                   RandRotatePMin, RandRotatePMax;
var(Forest) float                                   RandRotateYMin, RandRotateYMax;
var(Forest) float                                   RandRotateRMin, RandRotateRMax;

var(Forest) bool                                    RandScale;
var(Forest) float                                   RandScaleXMin, RandScaleXMax;
var(Forest) float                                   RandScaleYMin, RandScaleYMax;
var(Forest) float                                   RandScaleZMin, RandScaleZMax;

var(Forest) editinline array<SwForestTemplate>      Templates;          // Plant actors templates

//var(Forest) editconst string                      TypeID;


// MaskHints are used to suggest location where plants should
// Other plants will try to grow around this location in circular fashion.
// If StartPoints/s werent specified:
// - First plants will try to grow on every valid pixel of the mask.
// - Pixels with value smaller than MaskThreshold will be invalid for first plants.


// =============================================================================
//  Delegates
// =============================================================================

delegate bool OnError( string S );
delegate array<byte> OnGetLayerData( Texture T );


// =============================================================================
//  Switchboard
// =============================================================================

event Destroyed()
{
    Log("Destroyed",name);
}

function bool Generate()
{
    local bool bResult;

    xLog("- BEGIN ------------------------------------------------------------------");
    xLog( "Action: " $GetEnum(enum'EAction',Action) );

    switch( Action )
    {
        case AC_Rebuild:
            bResult = ActionRebuild();
            break;

        case AC_Randomize:
            bResult = ActionRandomize();
            break;

        case AC_Keep:
            bResult = True;
            break;

        case AC_Erase:
            bResult = ActionErase();
            break;
    }

    // On exit all objects should be gc safe!
    xLog("- END --------------------------------------------------------------------");
    return bResult;
}


function bool ActionRebuild()
{
    // Clean existing data
    Clean();

    // Try to find all errors
    if( NoErrors() )
    {
        // Precache variables
        Initialize();

        // Read layer texture
        Mask = OnGetLayerData( MaskTexture );
        if( Mask.Length == 0 )
            return Critical("Could not read data from texture" @MaskTexture);

        // Generate tree locations
        PlantFirstPlant();

        // Spawn tree meshes
        SpawnPlants();
        
        // Apply randomness
        ActionRandomize();

        // Dump profiling info
        LogDebug();

        // Clean temporary references
        Hints.Length = 0;
    }
}


function bool ActionRandomize()
{
    local int           i,j;
    local vector        NewScale3D;
    local rotator       NewRotation;
    local array<Actor>  Actors;

    if( i < Plants.Length ) do
    {
        if( RandScale )
        {
            NewScale3D =  vect(1,0,0)*(RandScaleXMin + (RandScaleXMax - RandScaleXMin) * FRand())
                       +  vect(0,1,0)*(RandScaleYMin + (RandScaleYMax - RandScaleYMin) * FRand())
                       +  vect(0,0,1)*(RandScaleZMin + (RandScaleZMax - RandScaleZMin) * FRand());

            j = 0;
            Actors = Plants[i].Actors;
            if( j < Actors.Length ) do {
                if( Actors[j] != None )
                    Actors[j].SetDrawScale3D( NewScale3D );
            } until( ++j == Actors.Length )
        }
        if( RandRotate )
        {
            NewRotation = rot(1,0,0)*(RandRotatePMin + (RandRotatePMax - RandRotatePMin) * FRand())
                        + rot(0,1,0)*(RandRotateYMin + (RandRotateYMax - RandRotateYMin) * FRand())
                        + rot(0,0,1)*(RandRotateRMin + (RandRotateRMax - RandRotateRMin) * FRand());

            j = 0;
            Actors = Plants[i].Actors;
            if( j < Actors.Length ) do {
                if( Actors[j] != None )
                    Actors[j].SetRotation( NewRotation );
            } until( ++j == Actors.Length )
        }
    } until( ++i == Plants.Length )

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].Randomize(self,i);

    return True;
}


function bool ActionErase()
{
    Clean();
    return True;
}


// =============================================================================
//  Generator
// =============================================================================

function Clean()
{
    local int i,j;
    local array<Actor> Actors;

    xLog( "Clean()" );

    // Destroy plant actors
    if( i < Plants.Length ) do
    {
        j = 0;
        Actors = Plants[i].Actors;
        if( j < Actors.Length ) do
        {
            if( Actors[j] != None )
            {
                Actors[j].Destroy();
                Actors[j] = None;
            }
        } until( ++j == Actors.Length )
    } until( ++i == Plants.Length )

    Plants.Length = 0;
    Grid.Length = 0;
    Mask.Length = 0;
    Hints.Length = 0;
    Parents.Length = 0;

    // Clean Debug
    ERR_Invalid     = 0;
    ERR_Valid       = 0;
    ERR_NoActor     = 0;
    ERR_GridIdx     = 0;
    ERR_GridFail    = 0;
    ERR_MaskIdx     = 0;
    ERR_MaskFail    = 0;
    ERR_Bounds      = 0;
    ERR_Parents     = 0;


    PlantCount              = 0;
    PlantCollisionRadius    = 0;
    PlantCollisionDiameter  = 0;

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].Clean();
}

function CleanRefs()
{
    local int i;

    xLog( "CleanRefs()" );

    Clean();

    for( i=0; i<ArrayCount(MaskHints); ++i )
        MaskHints[i] = None;

    for( i=0; i<ArrayCount(MaskParents); ++i )
        MaskParents[i] = None;

    MaskTerrain = None;
    MaskTexture = None;

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].CleanRefs();
    Templates.Length = 0;
}

function MarkUse()
{
    local int i;
    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].bInUse = True;
}

function bool NoErrors()
{
    local int i;

    xLog( "NoErrors()" );

    if( MaskTerrain == None )                   return Critical("MaskTerrain not set.");
    if( MaskTexture == None )                   return Critical("MaskTexture not set.");
    if( MaskTexture.Format != TEXF_RGBA8 )      return Critical("MaskTexture should be in RGBA8 format.");
//  if( MaskTexture.USize != MaskSizeU )        return Critical("MaskTexture has different U size.");
//  if( MaskTexture.VSize != MaskSizeV )        return Critical("MaskTexture has different V size.");

    if( PlantLimit <= 0 )                       return Critical("PlantLimit <= 0.");
    if( PlantSeedsMin < 0 )                     return Critical("PlantSeedsMin < 0.");
    if( PlantSeedsMax <= 0 )                    return Critical("PlantSeedsMax <= 0.");
    if( PlantRadiusMin < 0 )                    return Critical("PlantRadiusMin < 0.");
    if( PlantRadiusMax <= 0 )                   return Critical("PlantRadiusMax <= 0.");
    if( PlantScaleMin <= 0 )                    return Critical("PlantScaleMin <= 0.");
    if( PlantScaleMax <= 0 )                    return Critical("PlantScaleMax <= 0.");
    if( PlantSpacingMin < 0 )                   return Critical("PlantSpacingMin < 0.");
    if( PlantSpacingMax < 0 )                   return Critical("PlantSpacingMax < 0.");

    if( RandScaleXMin <= 0 )                    return Critical("RandScaleXMin <= 0."); // negative scale?
    if( RandScaleXMax <= 0 )                    return Critical("RandScaleXMax <= 0.");
    if( RandScaleYMin <= 0 )                    return Critical("RandScaleYMin <= 0.");
    if( RandScaleYMax <= 0 )                    return Critical("RandScaleYMax <= 0.");
    if( RandScaleZMin <= 0 )                    return Critical("RandScaleZMin <= 0.");
    if( RandScaleZMax <= 0 )                    return Critical("RandScaleZMax <= 0.");

    if( Templates.Length == 0 )
        return Critical("Templates not set.");

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            if( !Templates[i].NoErrors(self,i) )
                return False;

    return True;
}

function Initialize()
{
    local int i;

    xLog( "Initialize()" );

    // Swap variables where neccessary
    if( PlantSeedsMin > PlantSeedsMax )         PlantSeedsMin swap PlantSeedsMax;
    if( PlantRadiusMin > PlantRadiusMax )       PlantRadiusMin swap PlantRadiusMax;
    if( PlantScaleMin > PlantScaleMax )         PlantScaleMin swap PlantScaleMax;
    if( PlantSpacingMin > PlantSpacingMax )     PlantSpacingMin swap PlantSpacingMax;

    if( RandRotatePMin > RandRotatePMax )       RandRotatePMin swap RandRotatePMax;
    if( RandRotateYMin > RandRotateYMax )       RandRotateYMin swap RandRotateYMax;
    if( RandRotateRMin > RandRotateRMax )       RandRotateRMin swap RandRotateRMax;

    if( RandScaleXMin > RandScaleXMax )         RandScaleXMin swap RandScaleXMax;
    if( RandScaleYMin > RandScaleYMax )         RandScaleYMin swap RandScaleYMax;
    if( RandScaleZMin > RandScaleZMax )         RandScaleZMin swap RandScaleZMax;

    for( i=0; i<ArrayCount(MaskHints); ++i )
    {
        if( MaskHints[i] == None
        ||  MaskHints[i].bDeleteMe
        ||  MaskHints[i].bPendingDelete )
            MaskHints[i] = None;
        else
            Hints[Hints.Length] = MaskHints[i];
    }

    for( i=0; i<ArrayCount(MaskParents); ++i )
    {
        if( MaskParents[i] == None
        ||  MaskParents[i].bDeleteMe
        ||  MaskParents[i].bPendingDelete
        || !MaskParents[i].IsA('SwForestGen') )
            MaskParents[i] = None;
        else
            Parents[Parents.Length] = MaskParents[i];
    }

    bParents = Parents.Length > 0;

    // Terrain
    TerrainLocationX    = MaskTerrain.Location.X;
    TerrainLocationY    = MaskTerrain.Location.Y;
    TerrainLocationZ    = MaskTerrain.Location.Z;
    TerrainScaleX       = MaskTerrain.TerrainScale.X;
    TerrainScaleY       = MaskTerrain.TerrainScale.Y;
    TerrainScaleZ       = MaskTerrain.TerrainScale.Z;
    TerrainSizeX        = TerrainScaleX * MaskTexture.USize;
    TerrainSizeY        = TerrainScaleY * MaskTexture.VSize;
    TerrainSizeZ        = TerrainScaleZ * MaskTexture.USize;
    TerrainSector       = MaskTerrain.TerrainSectorSize;

    // Texture Mask
    MaskSizeU           = MaskTexture.USize;                                //
    MaskSizeV           = MaskTexture.VSize;                                //
    MaskSizeUV          = MaskSizeU * MaskSizeV;                            //
    MaskToX             = 1 / (TerrainScaleX);                              // Multiply by Location.X to get X sector index
    MaskToY             = 1 / (TerrainScaleY);                              // Multiply by Location.Y to get Y sector index
    MaskSizeX           = TerrainScaleX * MaskSizeU * 0.5;                  // UU
    MaskSizeY           = TerrainScaleY * MaskSizeV * 0.5;                  // UU
    MaskSizeZ           = TerrainScaleZ * MaskSizeU * 0.5;                  // UU
    MaskTerrX           = MaskToX * (MaskSizeX - TerrainLocationX);         // Array Index, TerrainInfo X offset
    MaskTerrY           = MaskToY * (MaskSizeY - TerrainLocationY);         // Array Index, TerrainInfo Y offset

    // Collision Grid
    PlantCollisionRadius     = PlantRadiusMax + PlantSpacingMin-1;                  //
    PlantCollisionDiameter   = PlantCollisionRadius*2;                                //
    GridCell            = PlantCollisionRadius*2;                                // UU
    GridCellsX          = (TerrainScaleX * MaskSizeU) /  GridCell;          //
    GridCellsY          = (TerrainScaleY * MaskSizeV) /  GridCell;          //
    GridCellsXY         = GridCellsX * GridCellsY;                          //
    GridToX             = 1 / (GridCell);                                   // Multiply by Location.X to get X sector index
    GridToY             = 1 / (GridCell);                                   // Multiply by Location.Y to get Y sector index
    GridSizeX           = GridCell * GridCellsX * 0.5;                      // UU
    GridSizeY           = GridCell * GridCellsY * 0.5;                      // UU
    GridTerrX           = GridToX * (GridSizeX - TerrainLocationX);         // Array Index, TerrainInfo X offset
    GridTerrY           = GridToY * (GridSizeY - TerrainLocationY);         // Array Index, TerrainInfo Y offset

    //Mask.Insert(0,MaskSizeUV);
    Grid.Insert(0,GridCellsXY);

    TraceTop.Z          = TerrainLocationZ + MaskSizeZ;
    TraceBottom.Z       = TerrainLocationZ - MaskSizeZ;

    PlantTrunkOffset = PlantRadiusMin * PlantSlopeAdjust;

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].Initialize(self,i);
}

function bool PlantFirstPlant()
{
    local int i;
    local sPlant Plant;
    local vector TracePoint;

    xLog( "PlantFirstPlant()" );

    // Try to plant on hint actors
    if( i < Hints.Length ) do
    {
        if( Hints[i] != None )
        {
            TracePoint = Hints[i].Location * vect(1,1,0);
            if( TracePlant( TracePoint, Plant ) == TR_Valid )
            {
                Plants[ Plants.Length ] = Plant;
                if( ++PlantCount >= PlantLimit )            break;
                if( !PlantOtherPlants(Plants.Length-1) )    break;
            }
        }
    } until( ++i == Hints.Length )

    // Try to plant on every mask pixel
    if( PlantCount == 0 )
    {
        i = 0;
        if( i < Mask.Length ) do
        {
            if( Mask[i] >= MaskThreshold )
            {
                TracePoint.X = TerrainLocationX + (i % MaskSizeU)*TerrainScaleX - MaskSizeX;
                TracePoint.Y = TerrainLocationY + (i / MaskSizeV)*TerrainScaleY - MaskSizeY;
                if( TracePlant( TracePoint, Plant ) == TR_Valid )
                {
                    Plants[Plants.Length] = Plant;
                    if( ++PlantCount >= PlantLimit )            break;
                    if( !PlantOtherPlants(Plants.Length-1) )    break;
                }
            }
        } until( ++i == Mask.Length )
    }

    if( PlantCount >= PlantLimit )
    {
        xLog( "PlantLimit =" @ PlantLimit @ "reached in" @ name $ "." );
        return False;
    }
    else
    {
        return True;
    }
}


final function bool PlantOtherPlants( int i )
{
    local int           j, Num;
    local float         Dist;
    local rotator       Dir;
    local sPlant        Plant;
    local vector        TracePoint;

    if( i < Plants.Length ) do
    {
        Dir.Yaw = 65536*FRand() - 65536*FRand() ;
        Num     = PlantSeedsMin + (PlantSeedsMax - PlantSeedsMin) * FRand();

        j = 0;
        if( j < Num ) do
        {
            Dir.Yaw    += (65535 / Num);
            Dist        = PlantRadiusMax + (PlantSpacingMin + (PlantSpacingMax - PlantSpacingMin) * FRand());
            TracePoint  = Plants[i].Location + vector(Dir)*Dist;

            if( TracePlant( TracePoint, Plant ) == TR_Valid )
            {
                Plants[Plants.Length] = Plant;
                if( ++PlantCount >= PlantLimit )
                    return False;
            }
        } until( ++j == Num )
    } until( ++i == Plants.Length )

    return True;
}

final function ETraceResult TracePlant( vector TracePoint, out sPlant Plant )
{
    local byte MCache;
    local int i,e,MX,MY,MIdx,GX,GY,GIdx;
    local bool TActor;
    local vector THitLocation, THitNormal;
    local array<vector> GCache;

    if( Abs(TracePoint.X-TerrainLocationX) > TerrainSizeX * 0.5
    ||  Abs(TracePoint.Y-TerrainLocationY) > TerrainSizeY * 0.5 )
    {
        ++ERR_Bounds;
        return TR_Bounds;
    }

    //Spawn(class'SwForestDummy',,,TracePoint);

    // Grid Test --------------------------------------------------------------

    //GX = TracePoint.X - TerrainLocationX - MaskTerr;
    //GY = TracePoint.Y - TerrainLocationY;

    GX = GridTerrX + (TracePoint.X * GridToX);
    GY = GridTerrY + (TracePoint.Y * GridToY);
    GIdx = GX + GY*GridCellsX;

    if( GIdx < 0 || GIdx >= Grid.Length )
    {
        ERR_GridIdx++;
        return TR_GridIdx;
    }

    GCache = Grid[GIdx].Locations;
    if( i < GCache.Length ) do {
        if( VSize( (TracePoint - GCache[i]) * vect(1,1,0) ) < PlantCollisionRadius )
        {
            ERR_GridFail++;
            return TR_GridFail;
        }
    } until( ++i == GCache.Length )

    // Extras Test ------------------------------------------------------------

    if( bParents ) do
    {
        if( Parents[e].IsSpotOccupied( TracePoint, Parents[e].PlantRadiusMin + PlantRadiusMax ) )
        {
            ERR_Parents++;
            return TR_Parents;
        }
    } until( ++e == Parents.Length )


    // Mask Test --------------------------------------------------------------
    MX = MaskTerrX + (TracePoint.X * MaskToX);
    MY = MaskTerrY + (TracePoint.Y * MaskToY);
    MIdx = MX + MY*MaskSizeU;

    if( MIdx < 0 || MIdx >= MaskSizeUV )
    {
        ERR_MaskIdx++;
        return TR_MaskIdx;
    }

    MCache = Mask[MIdx];
    switch( MaskMode )
    {
        case MM_Alpha:
            if( MCache <= 255*FRand() )
            {
                ERR_MaskFail++;
                return TR_MaskFail;
            }
        break;

        case MM_Any:
            if( MCache == 0 )
            {
                ERR_MaskFail++;
                return TR_MaskFail;
            }
        break;
    }


    // Trace ground level -----------------------------------------------------
    TracePoint.Z    = 0;
    //TActor          = Trace(THitLocation, THitNormal, TEnd, TStart );
    TActor          = !MaskTerrain.TraceThisActor(THitLocation, THitNormal, TracePoint + TraceBottom, TracePoint + TraceTop );

    if( TActor /*!= None*/ )
    {
        //if( TerrainInfo(TActor) != None || LevelInfo(TActor) != None )
        //{
            // Add to Grid ----------------------------------------------------
            GIdx = (GX  ) + (GY  )*GridCellsX;  Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;

            GIdx = (GX-1) + (GY-1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX+1) + (GY-1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX  ) + (GY-1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX-1) + (GY+1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX+1) + (GY+1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX  ) + (GY+1)*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX+1) + (GY  )*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;
            GIdx = (GX-1) + (GY  )*GridCellsX;  if( GIdx>=0 && GIdx<GridCellsXY ) Grid[GIdx].Locations[Grid[GIdx].Locations.Length] = THitLocation;

            Plant.Alpha     = MCache;
            Plant.Angle     = THitNormal;
            Plant.Location  = THitLocation;

            ERR_Valid++;
            return TR_Valid;
        //}
    }
    else
    {
        //Spawn(class'SwForestDummy',,,TracePoint);
        ERR_NoActor++;
        return TR_NoActor;
    }

    ERR_Invalid++;
    return TR_Invalid;
}


final function bool IsSpotOccupied( vector TracePoint, float Radius )
{
    local int i,GX,GY,GIdx;
    local array<vector> GCache;

    // Check terrain boundaries
    if( Abs(TracePoint.X-TerrainLocationX) > TerrainSizeX * 0.5
    ||  Abs(TracePoint.Y-TerrainLocationY) > TerrainSizeY * 0.5 )
    {
        return False;
    }

    // Check collision grid boundaries
    GX = GridTerrX + (TracePoint.X * GridToX);
    GY = GridTerrY + (TracePoint.Y * GridToY);
    GIdx = GX + GY*GridCellsX;
    if( GIdx < 0 || GIdx >= Grid.Length )
    {
        return False;
    }

    // Check distance to other Plants
    GCache = Grid[GIdx].Locations;
    if( i < GCache.Length ) do {
        if( VSize( (TracePoint - GCache[i]) * vect(1,1,0) ) < Radius )
            return True;
    } until( ++i == GCache.Length )

    return False;
}

function bool SpawnPlants()
{
    local int i;

    xLog( "SpawnPlants()" );

    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            if( !Templates[i].SpawnPlants(self,i) )
                return False;

    return True;
}

function UpdatePrecacheStaticMeshes()
{
    local int i;
    for( i=0; i<Templates.Length; ++i )
        if( Templates[i] != None )
            Templates[i].UpdatePrecacheStaticMeshes(self,i);
}

function bool Critical( string S )
{
    S = "Error in " $Name $":" $Chr(13) $S;
    Clean();
    return OnError(S);
}


// =============================================================================
//  Debug
// =============================================================================

//final function string MakeTypeID( optional int Num  )
//{
//    local string S;
//    local int i;
//
//    do{ S $= Chr(int(32+(126-32)*FRand()));
//    } until( ++i == 32 )
//
//    S $= "_"$Num;
//
//    i = 0;
//    if( Generators.Length > i ) do {
//        if( Generators[i].TypeID == S )
//            return MakeTypeID( Index, Num+RandRange(1,100) );
//    } until( ++i == Generators.Length )
//
//    i = 0;
//    if( GenData.Length > i ) do {
//        if( GenData[i].TypeID == S )
//            return MakeTypeID( Index, Num+RandRange(1,100) );
//    } until( ++i == GenData.Length )
//
//    return S;
//}

function LogDebug()
{
    local FileLog DebugLog;
    local String S;

    xLog( "LogDebug()" );

    DebugLog = Spawn(class'FileLog');
    if( DebugLog != None )  {   DebugLog.OpenLog(LogName);    }
    else                    {   Log("Could not create DebugLog " $LogName$ ".log",name);  return; }

    DebugLog.Logf("");

    S = string(name) $ Chr(9)
    $   "EIN=" $ ERR_Invalid    $ Chr(9)
    $   "EVA=" $ ERR_Valid      $ Chr(9)
    $   "ENA=" $ ERR_NoActor    $ Chr(9)
    $   "EGI=" $ ERR_GridIdx    $ Chr(9)
    $   "EGF=" $ ERR_GridFail   $ Chr(9)
    $   "EMI=" $ ERR_MaskIdx    $ Chr(9)
    $   "EMF=" $ ERR_MaskFail   $ Chr(9)
    $   "EBO=" $ ERR_Bounds     $ Chr(9)
    $   "EPA=" $ ERR_Parents    $ Chr(9)
    $   "GRI=" $ Grid.Length    $ Chr(9)
    $   "MSI=" $ Mask.Length    $ Chr(9);

    DebugLog.Logf(S);

    DebugLog.CloseLog();
    DebugLog.Destroy();
    DebugLog = None;
}

final function xLog(coerce string S)
{
    Log(S,Name);
}


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
     LogName="SwForestGen"
     Description(0)="NA"
     MaskThreshold=1
     PlantLimit=1000
     PlantRadiusMax=512.000000
     PlantRadiusMin=64.000000
     PlantScaleMax=1.000000
     PlantScaleMin=0.400000
     PlantSeedsMax=33
     PlantSeedsMin=11
     PlantSlopeAdjust=3.000000
     PlantSpacingMax=768.000000
     PlantSpacingMin=512.000000
     RandRotate=True
     RandRotatePMax=768.000000
     RandRotateYMax=65535.000000
     RandScale=True
     RandScaleXMin=0.800000
     RandScaleXMax=1.200000
     RandScaleYMin=0.800000
     RandScaleYMax=1.300000
     RandScaleZMin=0.800000
     RandScaleZMax=1.300000
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'SwForest.TForestGen'
     DrawScale=10.000000
     CollisionRadius=0.000000
     CollisionHeight=1024.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
