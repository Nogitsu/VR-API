--  > Enums
VR_LEFT_HAND = 1
VR_RIGHT_HAND = 2
VR_HMD = 3
VR_PLAYSPACE = 4
VR_LEFT_ARM = 5
VR_RIGHT_ARM = 6

local function get_bone_pos_ang(  bone )
    local ply = LocalPlayer()
    
    local id = ply:LookupBone( bone )
    if not id then return ply:GetPos(), ply:GetAngles() end

    local mat = ply:GetBoneMatrix( id )

    return mat:GetTranslation(), mat:GetAngles()
end

function vrapi.GetPlacementPos( place )
    local ply = LocalPlayer()

    if place == VR_LEFT_HAND then
        return get_bone_pos_ang( "ValveBiped.Bip01_L_Hand" )

    elseif place == VR_RIGHT_HAND then
        return get_bone_pos_ang( "ValveBiped.Bip01_R_Hand" )

    elseif place == VR_HMD then
        return vrmod.GetHMDPos(), EyeAngles()

    elseif place == VR_LEFT_ARM then
        return get_bone_pos_ang( "ValveBiped.Bip01_L_Ulna" )

    elseif place == VR_RIGHT_ARM then
        return get_bone_pos_ang( "ValveBiped.Bip01_R_Ulna" )
    end

    return ply:GetPos(), ply:GetAngles()
end