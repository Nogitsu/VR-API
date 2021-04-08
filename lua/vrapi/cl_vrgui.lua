function vrapi.ClearPanels()
    if vrapi._panels then
        for k, v in ipairs( vrapi._panels ) do
            v.panel:Remove()
        end
    end

    vrapi._panels = {}
end
vrapi.ClearPanels()

vrapi._panels = {}

local PANEL = FindMetaTable( "Panel" )
function PANEL:MakeVR( settings )
    self:SetPos( 0, 0 )
    self:SetPaintedManually( true )

    if not self.vrapi_id then
        self.vrapi_id = #vrapi._panels + 1
    end

    vrapi._panels[ self.vrapi_id ] = {
        panel = self,
        settings = settings or {}
    }

    self.OnRemove = function( _self )
        table.remove( vrapi._panels, _self.vrapi_id )
    end
end

hook.Add( "PostPlayerDraw", "VR-API:Draw", function( ply )
    if ply ~= LocalPlayer() or not vrmod.IsPlayerInVR( ply ) then return end

    for k, v in ipairs( vrapi._panels ) do
        if not IsValid( v.panel ) then continue end
        local panel = v.panel
        local settings = v.settings

        --  > Attaching
        local pos, ang = vrapi.GetPlacementPos( settings.attachment )

        --  > Setting up positions
        settings.scale = settings.scale or 1
        settings.pos = settings.pos or Vector()
        settings.ang = settings.ang or Angle()

        pos, ang = LocalToWorld( settings.pos, settings.ang, pos, ang )

        if settings.show_root then
            render.DrawWireframeSphere( pos, 0.1, 10, 10, color_white )
            render.DrawLine( pos, EyePos(), color_white )
        end

        --  > Calculating the offsets
        local offset = Vector()

        if settings.xAlign == TEXT_ALIGN_CENTER then
            offset.x = - panel:GetWide() * settings.scale / 2
        elseif settings.xAlign == TEXT_ALIGN_RIGHT then
            offset.x = - panel:GetWide() * settings.scale
        end

        if settings.yAlign == TEXT_ALIGN_CENTER then
            offset.y = panel:GetTall() * settings.scale / 2
        elseif settings.yAlign == TEXT_ALIGN_BOTTOM then
            offset.y = panel:GetTall() * settings.scale
        end

        pos, ang = LocalToWorld( offset, Angle(), pos, ang )

        --  > Implementing the cursor and the click
        local l_dist, r_dist = 0, 0
        local l_cursor, r_cursor = Vector(), Vector()

        local rf = ply:LookupBone( "ValveBiped.Bip01_R_Finger12" )
        if rf then
            local mat = ply:GetBoneMatrix( rf )
            local finger_pos, finger_ang = mat:GetTranslation(), mat:GetAngles()
            finger_pos = finger_pos + finger_ang:Forward()

            r_cursor = WorldToLocal( finger_pos, Angle(), pos, ang ) / settings.scale
            r_cursor.y = -r_cursor.y

            r_dist = ang:Up():Dot( pos - finger_pos )
        end

        local lf = ply:LookupBone( "ValveBiped.Bip01_L_Finger12" )
        if lf then
            local mat = ply:GetBoneMatrix( lf )
            local finger_pos, finger_ang = mat:GetTranslation(), mat:GetAngles()
            finger_pos = finger_pos + finger_ang:Forward()

            l_cursor = WorldToLocal( finger_pos, Angle(), pos, ang ) / settings.scale
            l_cursor.y = -l_cursor.y

            l_dist = ang:Up():Dot( pos - finger_pos )
        end

        if ( r_dist > -0.3 and r_dist < 0.3 ) then
            local in_x = r_cursor.x > 0 and r_cursor.x < panel:GetWide()
            local in_y = r_cursor.y > 0 and r_cursor.y < panel:GetTall()

            if in_x and in_y then
                panel:MakePopup()

                if v.pressed and r_dist > 0 then
                    local x, y = input.GetCursorPos()
                    gui.InternalCursorMoved( x - r_cursor.x, y - r_cursor.y )
                end
                input.SetCursorPos( r_cursor.x, r_cursor.y )

                if not v.pressed and r_dist > 0 then
                    v.pressed = true
                    gui.InternalMousePressed( MOUSE_LEFT )
                elseif v.pressed and r_dist < 0 then
                    v.pressed = false
                    gui.InternalMouseReleased( MOUSE_LEFT )
                end
            end
        elseif ( l_dist > -0.2 and l_dist < 0.2 ) then
            local in_x = l_cursor.x > 0 and l_cursor.x < panel:GetWide()
            local in_y = l_cursor.y > 0 and l_cursor.y < panel:GetTall()

            if in_x and in_y then
                panel:MakePopup()

                input.SetCursorPos( l_cursor.x, l_cursor.y )

                if l_dist > -0.1 then
                    gui.InternalMousePressed( MOUSE_LEFT )
                else
                    gui.InternalMouseReleased( MOUSE_LEFT )
                end
            end
        end

        --  > Drawing
        cam.IgnoreZ( settings.ignore_z )
            cam.Start3D2D( pos, ang, settings.scale )
                panel:PaintManual()
            cam.End3D2D()
        cam.IgnoreZ( false )
    end
end )