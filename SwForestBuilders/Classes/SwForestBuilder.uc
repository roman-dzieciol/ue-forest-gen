// ============================================================================
//  SwForestBuilder.uc:
// ============================================================================
//  Copyright 2003-2006 Roman Switch` Dzieciol. All Rights Reserved.
// ============================================================================
class SwForestBuilder extends BrushBuilder;

var class<SwTexUtil> TexUtil;


function bool Build()
{
    local int i;
    local SwForestGen G;
    local SwForestTemplate T;
    local array<SwForestTemplate> Templates;

    foreach AllObjects(class'SwForestTemplate',T)
    {
        Templates[Templates.Length] = T;
        T.bInUse = False;
    }

    foreach AllObjects(class'SwForestGen', G)
    {
        if( !G.bDeleteMe && !G.bPendingDelete )
        {
            G.MarkUse();
            if( G.bSelected )
                Process(G);
        }
        else
        {
            G.CleanRefs();
        }
    }

    for( i=0; i<Templates.Length; ++i )
    {
        if(!Templates[i].bInUse )
            Templates[i].CleanRefs();
    }

    return False;
}

function bool Process( SwForestGen G )
{
    G.OnError           = IError;
    G.OnGetLayerData    = IGetLayerData;

    G.Generate();

    G.OnGetLayerData    = None;
    G.OnError           = None;

    return True;
}

final function bool IError( string S )
{
    BadParameters(S);
    Log(S);
    return False;
}

final function array<byte> IGetLayerData( Texture T )
{
    Log("IGetLayerData()",name);

    TexUtil.default.TexChannel = 3;
    TexUtil.default.TexRef = T;
    if( !TexUtil.static.ReadChannel() )
        TexUtil.default.TexData.Length = 0;
    return TexUtil.default.TexData;
}

defaultproperties
{
     TexUtil=Class'SwTexUtils.SwTexUtil'
     BitmapFilename="SwForestBuilder"
     ToolTip="Forest Builder"
}
