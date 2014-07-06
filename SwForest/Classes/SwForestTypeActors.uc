// ============================================================================
//  SwForestTemplate.uc:
// ============================================================================
//  Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwForestTypeActors extends SwForestTemplate
    editinlinenew
    hidecategories(Object);



enum EnSurfaceTypes // !! - must mirror with Texture.uc in order for BSP geom surface's to match
{
    EST_Default,
    EST_Rock,
    EST_Dirt,
    EST_Metal,
    EST_Wood,
    EST_Plant,
    EST_Flesh,
    EST_Ice,
    EST_Snow,
    EST_Water,
    EST_Glass,
    EST_Custom00,
    EST_Custom01,
    EST_Custom02,
    EST_Custom03,
    EST_Custom04,
    EST_Custom05,
    EST_Custom06,
    EST_Custom07,
    EST_Custom08,
    EST_Custom09,
    EST_Custom10,
    EST_Custom11,
    EST_Custom12,
    EST_Custom13,
    EST_Custom14,
    EST_Custom15,
    EST_Custom16,
    EST_Custom17,
    EST_Custom18,
    EST_Custom19,
    EST_Custom20,
    EST_Custom21,
    EST_Custom22,
    EST_Custom23,
    EST_Custom24,
    EST_Custom25,
    EST_Custom26,
    EST_Custom27,
    EST_Custom28,
    EST_Custom29,
    EST_Custom30,
    EST_Custom31,
} ;


enum EnDrawType
{
    DT_StaticMesh,
    DT_Mesh,
    DT_Sprite,
    DT_RopeSprite,
    DT_VerticalSprite,
    DT_SpriteAnimOnce
};

enum EnRenderStyle
{
    STY_None,
    STY_Normal,
    STY_Masked,
    STY_Translucent,
    STY_Modulated,
    STY_Alpha,
    STY_Additive,
    STY_Subtractive,
    STY_Particle,
    STY_AlphaZ,
} ;

enum EnUV2Mode
{
    UVM_MacroTexture,
    UVM_LightMap,
    UVM_Skin,
};

//enum EOffsetSpace
//{
//  OS_World,
//  OS_Local
//};


// Display.
var(Visual)    EnDrawType      DrawType;           // Drawing effect.
var(Visual)    EnRenderStyle   Style;              // Style for rendering sprites, meshes.

var(Visual)    StaticMesh      StaticMesh;         // StaticMesh if DrawType=DT_StaticMesh
var(Visual)    Mesh            Mesh;               // Mesh if DrawType=DT_Mesh.
var(Visual)    Material        Texture;            // Sprite texture.if DrawType=DT_Sprite

var(Visual)    bool            bAcceptsProjectors; // Projectors can project onto this actor
var(Visual)    bool            bDisableSorting;    // Manual override for translucent material sorting.
var(Visual)    bool            bDeferRendering;    // defer rendering if DrawType is DT_Particle or Style is STY_Additive
var(Visual)    bool            bAlwaysFaceCamera;  // actor will be rendered always facing the camera like a sprite

var(Visual)    float           CullDistance;       // 0 == no distance cull, < 0 only drawn at distance > 0 cull at distance
var(Visual)    float           LODBias;            //
var(Visual)    float           DrawScale;          // Scaling factor, 1.0=normal size.
var(Visual)    vector          DrawScale3D;        // Scaling vector, (1.0,1.0,1.0)=normal size.
var(Visual)    vector          PrePivot;           // Offset from box center for drawing.
var(Visual)    array<Material> Skins;              // Multiple skin support - not replicated.

var(Visual)    Material        UV2Texture;         //
var(Visual)    EnUV2Mode       UV2Mode;            //



// Lighting.
var(Lights)   bool            bUseDynamicLights;      //
var(Lights)   bool            bLightingVisibility;    // Calculate lighting visibility for this actor with line checks.
var(Lights)   bool            bDramaticLighting;      //
var(Lights)   bool            bUnlit;                 // Lights don't affect actor.
var(Lights)   bool            bShadowCast;            // Casts static shadows.
var(Lights)   bool            bStaticLighting;        // Uses raytraced lighting.
var(Lights)   bool            bUseLightingFromBase;   // Use Unlit/AmbientGlow from Base

var(Lights)   byte            AmbientGlow;            // Ambient brightness, or 255=pulsing.
var(Lights)   byte            MaxLights;              // Limit to hardware lights active on this primitive.
var(Lights)   float           ScaleGlow;              //


// Advanced.
var(Misc)   bool            bStatic;                // Does not move or change over time.
var(Misc)   bool            bUseStaticMeshActor;    // Use StaticMeshActor instead of Actor
var(Misc)   bool            bHidden;                // Is hidden during gameplay.
var(Misc)   bool            bHighDetail;            // Only show up in high or super high detail mode.
var(Misc)   bool            bSuperHighDetail;       // Only show up in super high detail mode.
var(Misc)   EnSurfaceTypes  SurfaceType;            //
var(Misc)   class<Actor>    Override;               // Ignore all those settings and use specified class instead
var(Misc)   vector          Offset3D;               //
//var(Misc) EOffsetSpace    OffsetSpace;            //


// Collision flags.
var(Colliding)  bool            bCollideActors;             // Collides with other actors.
var(Colliding)  bool            bCollideWorld;              // Collides with the world.
var(Colliding)  bool            bBlockActors;               // Blocks other nonplayer actors.
var(Colliding)  bool            bProjTarget;                // Projectiles should potentially target this actor.
var(Colliding)  bool            bBlockZeroExtentTraces;     // block zero extent actors/traces
var(Colliding)  bool            bBlockNonZeroExtentTraces;  // block non-zero extent actors/traces
var(Colliding)  bool            bBlockKarma;                // Block actors being simulated with Karma.
var(Colliding)  bool            bBlocksTeleport;            //
var(Colliding)  bool            bWorldGeometry;             // Collision and Physics treats this actor as world geometry
var(Colliding)  bool            bIgnoreEncroachers;         // Ignore collisions between movers and this actor
var(Colliding)  bool            bIgnoreVehicles;            // Ignore collisions between vehicles and this actor (only relevant if bIgnoreEncroachers is false)
var(Colliding)  bool            bPathColliding;             // this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var(Colliding)  bool            bUseCollisionStaticMesh;    //
var(Colliding)  bool            bExactProjectileCollision;  // nonzero extent projectiles should shrink to zero when hitting this actor, requires bStaticMeshActor=True


// Editor.
var(UnrealEd)     bool            bHiddenEd;          // Is hidden during editing.
var(UnrealEd)     bool            bHiddenEdGroup;     // Is hidden by the group brower.
var(UnrealEd)     bool            bEdShouldSnap;      // Snap to grid in editor.
var(UnrealEd)     bool            bObsolete;          // actor is obsolete, warn level designers to remove it
var(UnrealEd)     bool            bLockLocation;      // Prevent the actor from being moved in the editor.
var(UnrealEd)     string          GroupFormat;        //


// Internal
var array<Actor.EDrawType> DrawTypeConv;




function Clean()
{
}

function CleanRefs()
{
    StaticMesh = None;
    Mesh = None;
    Texture = None;
    Skins.Length = 0;
    UV2Texture = None;
    Override = None;
}

function Initialize( SwForestGen T, int PlantIndex )
{
}

function bool NoErrors( SwForestGen T, int PlantIndex )
{
    Switch( DrawType )
    {
        case DT_Mesh:
            if( Mesh == None )
                return T.Critical("Templates[" $PlantIndex$ "].DrawType==DT_Mesh but no Mesh.");

        case DT_StaticMesh:
            if( StaticMesh == None )
                return T.Critical("Templates[" $PlantIndex$ "].DrawType==DT_StaticMesh but no StaticMesh.");

        default:
            break;
    }

    return True;
}

function bool SpawnPlants( SwForestGen Gen, int PlantIndex )
{
    local class<Actor> PlantClass;
    local Actor     Plant;
    local int       i;
    local float     NewScale, Angle;
    local string    GroupName, AssetName;
    local vector    Offset;

    if( Override != None )
    {
        PlantClass = Override;
        for(i=0; i<Gen.Plants.Length; i++)
        {

            Plant = Gen.Spawn( PlantClass,,,Gen.Plants[i].Location + Offset );
            Gen.Plants[i].Actors[Gen.Plants[i].Actors.Length] = Plant;
        }
    }
    else
    {
        if( bStatic )
        {
            if( bUseStaticMeshActor )   PlantClass = class'SwForestActorStaticSM';
            else                        PlantClass = class'SwForestActorStatic';
        }
        else
        {
            if( bUseStaticMeshActor )   PlantClass = class'SwForestActorSM';
            else                        PlantClass = class'SwForestActor';
        }

        if( DrawType == DT_StaticMesh ) AssetName = string(StaticMesh.Name);
        else if( DrawType == DT_Mesh )  AssetName = string(Mesh.Name);
        else if( Texture != None )      AssetName = string(Texture.Name);
        else                            AssetName = "None";

        GroupName = GroupFormat;
        GroupName = Repl( GroupName, "%g", Gen.Name, True );
        GroupName = Repl( GroupName, "%i", PlantIndex, True );
        GroupName = Repl( GroupName, "%a", AssetName, True );


        for(i=0; i<Gen.Plants.Length; i++)
        {

            Offset = Offset3D + Gen.PlantOffset3D;
            if( Gen.PlantTrunkOffset != 0 )
            {
                Angle = acos(Gen.Plants[i].Angle dot vect(0,0,1));
                Offset += FMin( Gen.PlantTrunkOffset, tan(Angle) * Gen.PlantRadiusMin ) * vect(0,0,-1);
            }

            Plant = Gen.Spawn( PlantClass,,,Gen.Plants[i].Location + Offset );
            NewScale = (Gen.PlantScaleMin + (Gen.PlantScaleMax - Gen.PlantScaleMin) * (Gen.Plants[i].Alpha / float(255)));

            // Display.
            Plant.SetDrawType( DrawTypeConv[DrawType] );
            Plant.SetStaticMesh(StaticMesh);
            Plant.LinkMesh(Mesh);
            Plant.Style                 = ERenderStyle(Style);
            Plant.Texture               = Texture;

            Plant.bAcceptsProjectors    = bAcceptsProjectors;
            Plant.bDisableSorting       = bDisableSorting;
            Plant.bDeferRendering       = bDeferRendering;
            Plant.bAlwaysFaceCamera     = bAlwaysFaceCamera;

            Plant.CullDistance          = CullDistance;
            Plant.LODBias               = LODBias;

            if( DrawScale3D != default.DrawScale3D )
                Plant.SetDrawScale3D(DrawScale3D*NewScale);
            else
                Plant.SetDrawScale(DrawScale*NewScale);

            Plant.PrePivot              = PrePivot;
            Plant.Skins                 = Skins;

            Plant.UV2Texture            = UV2Texture;
            Plant.UV2Mode               = EUV2Mode(UV2Mode);


            // Lighting.
            Plant.bUseDynamicLights     = bUseDynamicLights;
            Plant.bLightingVisibility   = bLightingVisibility;
            Plant.bDramaticLighting     = bDramaticLighting;
            Plant.bUnlit                = bUnlit;
            Plant.bShadowCast           = bShadowCast;
            Plant.bStaticLighting       = bStaticLighting;
            Plant.bUseLightingFromBase  = bUseLightingFromBase;

            Plant.AmbientGlow           = AmbientGlow;
            Plant.MaxLights             = MaxLights;
            Plant.ScaleGlow             = ScaleGlow;


            // Advanced.
            Plant.bHidden               = bHidden;
            Plant.bHighDetail           = bHighDetail;
            Plant.bSuperHighDetail      = bSuperHighDetail;
            Plant.SurfaceType           = ESurfaceTypes(SurfaceType);


            // Collision.
            Plant.SetCollision(bCollideActors,bBlockActors);
            Plant.KSetBlockKarma(bBlockKarma);
            Plant.bCollideWorld                 = bCollideWorld;
            Plant.bProjTarget                   = bProjTarget;
            Plant.bBlockZeroExtentTraces        = bBlockZeroExtentTraces;
            Plant.bBlockNonZeroExtentTraces     = bBlockNonZeroExtentTraces;
            Plant.bBlocksTeleport               = bBlocksTeleport;
            Plant.bWorldGeometry                = bWorldGeometry;
            Plant.bIgnoreEncroachers            = bIgnoreEncroachers;
            Plant.bIgnoreVehicles               = bIgnoreVehicles;
            Plant.bPathColliding                = bPathColliding;
            Plant.bUseCollisionStaticMesh       = bUseCollisionStaticMesh;

            if( bUseStaticMeshActor )
                StaticMeshActor(Plant).bExactProjectileCollision     = bExactProjectileCollision;


            // Editor.
            Plant.bHiddenEd             = bHiddenEdGroup;
            Plant.bHiddenEdGroup        = bHiddenEdGroup;
            Plant.bEdShouldSnap         = bEdShouldSnap;
            Plant.bObsolete             = bObsolete;
            Plant.bLockLocation         = bLockLocation;
            Plant.SetPropertyText( "Group", GroupName );

            Gen.Plants[i].Actors[Gen.Plants[i].Actors.Length] = Plant;
        }

    }

    return true;
}

defaultproperties
{
     Style=STY_Normal
     StaticMesh=StaticMesh'Editor.TexPropSphere'
     Texture=Texture'Engine.DefaultTexture'
     bDeferRendering=True
     LODBias=1.000000
     DrawScale=1.000000
     DrawScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     bShadowCast=True
     bStaticLighting=True
     MaxLights=4
     ScaleGlow=1.000000
     bStatic=True
     bUseStaticMeshActor=True
     SurfaceType=EST_Plant
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     bBlockKarma=True
     bBlocksTeleport=True
     bWorldGeometry=True
     bIgnoreEncroachers=True
     bPathColliding=True
     bUseCollisionStaticMesh=True
     bExactProjectileCollision=True
     bEdShouldSnap=True
     bLockLocation=True
     GroupFormat="%g_%a_%i"
     DrawTypeConv(0)=DT_StaticMesh
     DrawTypeConv(1)=DT_Mesh
     DrawTypeConv(2)=DT_Sprite
     DrawTypeConv(3)=DT_RopeSprite
     DrawTypeConv(4)=DT_VerticalSprite
     DrawTypeConv(5)=DT_SpriteAnimOnce
}
