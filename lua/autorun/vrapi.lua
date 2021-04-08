if not vrmod then
    error( "You need vrmod for vrapi to work." )
    
    return
end

vrapi = {}

if CLIENT then
    function vrapi.GetViewSize()
        return vrapi.view_size or 400
    end
    
    function vrapi.SetViewSize( size )
        vrapi.view_size = size
    end
end

--  > We get everything in the folder
local files, folders = file.Find( "vrapi/*", "LUA" )

--  > First, we load our API
-- Putting something in 'vrapi/' will load it during the API load, don't do that except if you know what you're doing 
for k, v in ipairs( files ) do
    if v:StartWith( "cl_" ) then
        AddCSLuaFile( "vrapi/" .. v )

        if CLIENT then
            include( "vrapi/" .. v )
        end

        print( "[VR-API] Loaded client file " .. v )
    elseif v:StartWith( "sv_" ) then
        if SERVER then
            include( "vrapi/" .. v )
        end

        print( "[VR-API] Loaded server file " .. v )
    else
        AddCSLuaFile( "vrapi/" .. v )
        include( "vrapi/" .. v )

        print( "[VR-API] Loaded shared file " .. v )
    end
end

vrapi.modules = {}
--  > Now that the API is loaded, we can load modules
for k, v in ipairs( folders ) do
    if not file.Exists( "vrapi/" .. v .. "/shared.lua", "LUA" ) then
        print( "[VR-API] Skipping module folder " .. v .. ", shared.lua not found." )

        continue
    end

    MODULE = {}
    MODULE.Class = v
    MODULE.Folder = "vrapi/" .. v .. "/"

    AddCSLuaFile( "vrapi/" .. v .. "/shared.lua" )
    include( "vrapi/" .. v .. "/shared.lua" )

    MODULE = MODULE or {} -- If someone try to make the MODULE = nil, then we have an empty module
    MODULE.Class = v -- We assign it again to avoid overwriting
    vrapi.modules[ v ] = MODULE

    print( "[VR-API] Loaded module " .. ( MODULE.Name or "Unknown" ) )
end

MODULE = nil