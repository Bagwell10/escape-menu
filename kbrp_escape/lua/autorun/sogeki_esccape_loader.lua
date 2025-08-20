local path = 'sogeki_escape'
include(path..'/config/sh_config.lua')

if SERVER then
    local files = file.Find(path..'/shared/*.lua', 'LUA')
    for _, file in ipairs(files) do
        AddCSLuaFile(path..'/shared/'..file)
        include(path..'/shared/'..file)
        Msg('[Sogeki Escape] : '..file..' Succes \n')
    end

    local files = file.Find(path..'/config/*.lua', 'LUA')
    for _, file in ipairs(files) do
        AddCSLuaFile(path..'/config/'..file)
        include(path..'/config/'..file)
        Msg('[Sogeki Escape] : '..file..' Succes \n')
    end

    local files = file.Find(path..'/client/*.lua', 'LUA')
    for _, file in ipairs(files) do
        AddCSLuaFile(path..'/client/'..file)
        Msg('[Sogeki Escape] : '..file..' Succes \n')
    end

    local files = file.Find(path..'/server/*.lua', 'LUA')
    for _, file in ipairs(files) do
        include(path..'/server/'..file)
        Msg('[Sogeki Escape] : '..file..' Succes \n')
    end
end

if CLIENT then
    local files = file.Find(path..'/shared/*.lua', 'LUA')
    for _, file in ipairs(files) do
        include(path..'/shared/'..file)
    end

    local files = file.Find(path..'/config/*.lua', 'LUA')
    for _, file in ipairs(files) do
        include(path..'/config/'..file)
    end

    local files = file.Find(path..'/client/*.lua', 'LUA')
    for _, file in ipairs(files) do
        include(path..'/client/'..file)
    end
end