local appversion = "v30"
local recversion = "v15"
local temporary = fs.open("rec/settings", "w")
local settingsdef = {}
settingsdef.terminate = false
settingsdef.version = recversion
temporary.write(textutils.serialise(settingsdef))
temporary.close()
local function Connect()
    local modem = false
    local side = {"left", "right", "bottom", "top", "back", "front"}
    local i = 0
    for i=1,6 do
        if peripheral.isPresent(side[i])==true then
            if peripheral.getType(side[i])=="modem" then
                modem = true
                rednet.open(side[i])
            end
        end
    end
    if modem==true then
        term.setTextColor(colors.lime)
        write("Database(s) Status: ONLINE!\n")
    else
        term.setTextColor(colors.red)
        write("Please connect an Ender Modem to use this!\n")
    end
    term.setTextColor(colors.white)
    return modem
end
local function Status()
    local id, msg, protocol = rednet.receive("STATUS")
    rednet.send(id, "ONLINE", "ONLINE")
    write(id.." has checked the online status.\n")
end
local function uRegister()
    local id, msg, protocol = rednet.receive("UREGISTER")
    local file = fs.open("database", "r")
    local tbl = textutils.unserialise(file.readAll())
    local flag = false
    local user = "user"..tostring(id)
    file.close()
    file = fs.open("database", "w")
    tbl[user] = tostring(msg)
    file.write(textutils.serialise(tbl))
    file.close()
    if fs.exists("users/"..user)==false then
        file = fs.open("users/"..user, "w")
        local data = {}
        data["name"] = tostring(msg)
        data["score"] = 0
        file.write(textutils.serialise(data))
        file.close()
    else
        file = fs.open("users/"..user, "r")
        local data = textutils.unserialise(file.readAll())
        data["name"] = tostring(msg)
        file.close()
        file = fs.open("users/"..user, "w")
        file.write(textutils.serialise(data))
        file.close()
    end
    write("Registered: \""..msg.."\".\n")
    file = fs.open("log", "a")
    file.writeLine("Registered: \""..msg.."\".\n")
    file.close()
end
local function rSearch()
    local id, msg, protocol = rednet.receive("RSEARCH")
    local file = fs.open("database", "r")
    local tbl = textutils.unserialise(file.readAll())
    local flag = false
    local udata = ""
    local user = "user"..tostring(msg)
    local k,v = nil, nil
    for k,v in pairs(tbl) do
        if k==user then
            flag = true
            udata = tostring(tbl[user])
        end
    end
    if flag==false then
        udata = tostring(msg)
    end
    rednet.send(id, tostring(udata), "USER")
    file.close()
end
local function uSearch()
    local id, msg, protocol = rednet.receive("USEARCH")
    local file = fs.open("database", "r")
    local tbl = textutils.unserialise(file.readAll())
    local flag = false
    local udata = ""
    local user = "user"..tostring(msg)
    local k,v = nil, nil
    for k,v in pairs(tbl) do
        if k==user then
            flag = true
            udata = tostring(tbl[user])
        end
    end
    if flag==false then
        udata = tostring(msg)
    end
    rednet.send(id, tostring(udata), "USER")
    file.close()
end
local function List()
    local id, msg, protocol = rednet.receive("LIST")
    local files = fs.open("database", "r")
    local datas = files.readAll()
    datas = textutils.unserialise(datas)
    local final = ""
    local keyv,val = nil, nil
    for keyv,val in pairs(datas) do
        final = final.."ID: "
        final = final..string.sub(keyv, 5, string.len(keyv))
        final = final..". Name: "
        final = final..val
        final = final..".\n"
    end
    rednet.send(id, tostring(final), "LISTED")
    write("User list sent to: "..id..".\n")
    files.close()
    files = fs.open("log", "a")
    files.writeLine("User list sent to: "..id..".\n")
    files.close()
end
local function carpApps()
    local id, msg, protocol = rednet.receive("carpApps")
    if msg=="install" then
        os.sleep(1.5)
        local file = fs.open("apps/startup", "r")
        local data = file.readAll()
        file.close()
        rednet.send(id, data, "startup")
        os.sleep(1.5)
        file = fs.open("apps/carpApps", "r")
        data = file.readAll()
        file.close()
        rednet.send(id, data, "carpApps")
        os.sleep(1.5)
        file = fs.open("apps/extensions", "r")
        data = file.readAll()
        file.close()
        rednet.send(id, data, "extensions")
        os.sleep(1.5)
        file = fs.open("apps/commands", "r")
        data = file.readAll()
        file.close()
        rednet.send(id, data, "commands")
        os.sleep(1.5)
        file = fs.open("apps/worm", "r")
        data = file.readAll()
        file.close()
        rednet.send(id, data, "worm")
        os.sleep(1.5)
        file = fs.open("apps/receiver", "r")
        data = file.readAll()
        file.close()
        rednet.send(id, data, "receiver")
        id, msg, protocol = rednet.receive("logsdown", 15)
        if msg=="f" then
            os.sleep(1.5)
            file = fs.open("apps/logs.lua", "r")
            data = file.readAll()
            file.close()
            rednet.send(id, data, "logs")
        end
        id, msg, protocol = rednet.receive("optionsdown", 15)
        if msg=="f" then
            os.sleep(1.5)
            file = fs.open("apps/options", "r")
            data = file.readAll()
            file.close()
            data = textutils.unserialise(data)
            data["version"] = appversion
            data = textutils.serialise(data)
            rednet.send(id, data, "options")
            write("Computer ID: "..id.." Just finished installing!\n")
            file = fs.open("log", "a")
            file.writeLine("Computer ID: "..id.." Just finished installing!\n")
            file.close()
        elseif msg=="t" then
            os.sleep(1.5)
            rednet.send(id, appversion, "newver")
            write("Computer ID: "..id.." Just finished updating!\n")
            file = fs.open("log", "a")
            file.writeLine("Computer ID: "..id.." Just finished updating!\n")
            file.close()
            os.sleep(1.5)
        end
    end
end
local function appVersionCheck()
    local id, msg, prot = rednet.receive("vcheck")
    if msg~=appversion then
        os.sleep(1.5)
        rednet.send(id, "outdated", "rvcheck")
    else
        os.sleep(1.5)
        rednet.send(id, "uptodate", "rvcheck")
    end
end
local function recUpdate()
    local id, msg, prot = rednet.receive("recUp")
    os.sleep(1.5)
    local file = fs.open("rec/startup.lua", "r")
    rednet.send(id, file.readAll(), "startup")
    file.close()
    id, msg, prot = rednet.receive("settingc")
    if msg=="t" then
        os.sleep(1.5)
        rednet.send(id, recversion, "newver")
    elseif msg=="f" then
        os.sleep(1.5)
        file = fs.open("rec/settings", "r")
        rednet.send(id, file.readAll(), "settings")
        file.close()
    end
end
local function recVcheck()
    local id, msg, prot = rednet.receive("recCheck")
    if msg~=recVersion then
        os.sleep(1.5)
        rednet.send(id, "outdated", "recvCheck")
    else
        os.sleep(1.5)
        rednet.send(id, "outdated", "recvCheck")
    end
end
local function updateScore()
    local id, msg, prot = rednet.receive("upScore")
    local user = "user"..id
    if fs.exists("users/"..user)==true then
        local file = fs.open("users/"..user, "r")
        local data = textutils.unserialise(file.readAll())
        file.close()
        file = fs.open("users/"..user, "w")
        data["score"] = data["score"] + tonumber(msg)
        file.write(textutils.serialise(data))
        file.close()
    else
        local file = fs.open("users/"..user, "w")
        local data = {}
        data["name"] = tostring(id)
        data["score"] = tonumber(msg)
        file.write(textutils.serialise(data))
        file.close()
    end
end
local function hiscore()
    local id, msg, prot = rednet.receive("hiscore")
    local score = 0
    local tmpscore = score
    local name = ""
    local list = fs.list("users/")
    for _, filen in ipairs(list) do
        local file = fs.open("users/"..filen, "r")
        local data = textutils.unserialise(file.readAll())
        tmpscore = data["score"]
        if score<tmpscore then
            score = tmpscore
            name = data["name"]
        end
    end
    local message = "Name: "..name..". Score: "..score..".\n"
    rednet.send(id, message, "rhiscore")
end
local function pos()
    local id, msg, prot = rednet.receive("location")
    local user = "user"..id
    if msg~=nil then
        if fs.exists("users/"..user)==true then
            local file = fs.open("users/"..user, "r")
            local data = textutils.unserialise(file.readAll())
            data["pos"] = "x"..msg.x.." y"..msg.y.." z"..msg.z
            file.close()
            file = fs.open("users/"..user, "w")
            file.write(textutils.serialise(data))
            file.close()
        else
            local file = fs.open("users/"..user, "w")
            local data = {}
            data["name"] = id
            data["score"] = 0
            data["pos"] = "x"..msg.x.." y"..msg.y.." z"..msg.z
            file.write(textutils.serialise(data))
            file.close()
        end
    end
end
if Connect()==true then
    while true do
        parallel.waitForAny(uRegister, uSearch, rSearch, List, Status, carpApps, appVersionCheck, recVcheck, recUpdate, updateScore, hiscore, pos)
    end
end
