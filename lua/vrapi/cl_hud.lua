hook.Add( "PostPlayerDraw", "VR-API:HUD", function( ply )
    if ply ~= LocalPlayer() or not vrmod.IsPlayerInVR( ply ) then return end

    --  > Left arm
    local la = ply:LookupBone( "ValveBiped.Bip01_L_Ulna" )
    if la then
        local mat = ply:GetBoneMatrix( la )
        local pos, ang = mat:GetTranslation(), mat:GetAngles()
        ang:RotateAroundAxis( ang:Forward(), 90 + 55 )

        cam.Start3D2D( pos + ang:Up() * 3, ang, 0.05 )
            hook.Run( "VR-API:LeftHUD" )
        cam.End3D2D()
        
        hook.Run( "VR-API:DrawLeft", pos, ang )
    end

    --  > Right arm
    local ra = ply:LookupBone( "ValveBiped.Bip01_R_Ulna" )
    if ra then
        local mat = ply:GetBoneMatrix( ra )
        local pos, ang = mat:GetTranslation(), mat:GetAngles()
        ang:RotateAroundAxis( ang:Forward(), 90 - 55 )
        ang:RotateAroundAxis( ang:Up(), 180 )

        cam.Start3D2D( pos + ang:Up() * 3, ang, 0.05 )
            hook.Run( "VR-API:RightHUD" )
        cam.End3D2D()

        hook.Run( "VR-API:DrawRight", pos, ang )
    end

    --  > Head
    local ang = EyeAngles()
    local pos = vrmod.GetHMDPos() + ang:Forward() * 64

    ang:RotateAroundAxis( ang:Right(), -90 )
    ang:RotateAroundAxis( ang:Forward(), 180 )
    ang:RotateAroundAxis( ang:Up(), 90 )

    cam.IgnoreZ( true )
        cam.Start3D2D( pos, ang, 0.15 )
            hook.Run( "VR-API:HUD" )
        cam.End3D2D()
    cam.IgnoreZ( false )
end )