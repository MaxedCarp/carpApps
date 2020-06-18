opens = 1
local dbIDV = 0
local carpID, carpID2 = 1, nil
if opens==1 then
dofile("extensions")
carpApps.Login(true)
local x, y = term.getCursorPos()
carpApps.OnlineStatus()
carpApps.Time()
term.setTextColor(colors.white)
write("This computer's ID: "..tostring(os.getComputerID())..".\n")
term.setTextColor(colors.lightGray)
write("Use \"commands\" to see custom commands.\n")
term.setTextColor(colors.white)
local oldFs = {}
for k, v in pairs( fs ) do
    oldFs[k] = v
end
local function normalise(path)
    return path
    :gsub( "//+", "/" ) --# remove multiple slashes
    :gsub( "/%./", "/" ) --# remove /./ (has no effect on path)
    :gsub( "^%./", "" ) --# remove ./ at start (same as above)
    :gsub( "(/?)[^/]+/%.%./", "%1" ) --# remove /X/../
    :gsub( "(/?)[^/]+/%.%.$", "%1" ) --# remove /X/.. at end
    :gsub( "^%.%./", "" ) --# remove ../ at start
    :gsub( "^[^/]+/%.%./", "/" ) --# remove X/.. at start
    :gsub( "^/", "" ):gsub( "/$", "" ) --# remove trailing slashes
end
local oldOpen = fs.open
local blacklist = {
    ["commands"] = true;
    ["startup.lua"] = true;
}
local blacklist2 = {
    ["carpApps"] = true;
    ["carpPowers"] = true;
    ["options"] = true;
}
function fs.open(path, mode, usr)
    if tostring(usr)~="sys" then
        if mode ~= "r" and mode ~= "rb" and blacklist[normalise( path )] then
            if os.getComputerID()~=carpID and os.getComputerID()~=carpID2 then
                return error( "attempt to open read-only file in '" .. mode .. "' mode" )
            else
                return oldOpen( path, mode )
            end
        elseif blacklist2[normalise(path)] and os.getComputerID()~=carpID and os.getComputerID()~=carpID2 then
            error("ACCESS DENIED!")
        else
            return oldOpen( path, mode )
        end
    else
        return oldOpen( path, mode )
    end
end
opens = opens + 1
end
local sh = multishell.launch({shell = shell, multishell = multishell}, "receiver")
multishell.setTitle(sh, "Unread MSG's: 0")
