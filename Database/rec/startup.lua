local oldPullEvent = os.pullEvent
local disks = "shell.allow_disk_startup"
local function time()
    local time = textutils.formatTime(os.time("utc"), true)
    local time2 = ""
    if string.sub(time, 2, 2)==":" then
        time2 = string.sub(time, 2, string.len(time))
        time = tonumber(string.sub(time, 1, 1))+2
        time = tostring(time)..time2
    else
        time2 = string.sub(time, 3, string.len(time))
        time = tonumber(string.sub(time, 1, 2))+2
        if time>=24 then
            time = "0"..time2
        else
            time = tostring(time)..time2
        end
    end
    return "["..time.."] "
end
local function save(file, tab, message)
    local file = fs.open(file, "w")
    if message~=nil then
        table.insert(tab, time()..message)
    end
    file.write(textutils.serialise(tab))
    file.close()
end
local function load(f)
    local file = fs.open(f, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialise(data)
end
if load("settings").terminate==false then
    os.pullEvent = os.pullEventRaw
    settings.set(disks, false)
elseif load("settings").terminate==true then
    os.pullEvent = oldPullEvent
    settings.set(disks, true)
else
    local file = fs.open("settings", "w")
    local data = {}
    data.terminate = false
    file.write(textutils.serialise(data))
end
local function wd()
    local tab = load("logs")
    local len = #tab
    mon = peripheral.wrap("top")
    mon.setTextColor(colors.lime)
    mon.setCursorPos(1, 1)
    x, y = 1, 1
    if len>10 then
        for i=(len-10),len do
            y = y + 1
            mon.write(tab[i])
            mon.setCursorPos(1, y)
        end
    else
        for i=1,len do
            y = y + 1
            mon.write(tab[i])
            mon.setCursorPos(1, y)
        end
    end
    mon.setTextColor(colors.white)
end
local side = {"left", "right", "bottom", "front", "back"}
local count = tonumber(0)
for i=1,5 do
    if peripheral.isPresent(side[i])==true then
        if peripheral.getType(side[i])=="modem" then
            rednet.open(side[i])
            count = tonumber(count + 1)
        end
    end
end
if count==0 then
    write("Please connect a Wireless Modem to use this!\n")
else
    if peripheral.getType("top")~="monitor" then
        term.setTextColor(colors.red)
        write("Please connect a Monitor to the top!")
    else
        monitor = peripheral.wrap("top")
        monitor.clear()
        monitor.setTextScale(0.5)
        wd()
        oldx, oldy = monitor.getCursorPos()
        monitor.setTextColor(colors.white)
        index = "Local ID: "..tostring(os.getComputerID()).."\n"
        monitor.write(tostring(index))
        oldy = oldy + 1
        monitor.setCursorPos(1, oldy + 1)
        oldy = oldy + 1
        monitor.write("Message Reader:")
        monitor.setCursorPos(1, oldy + 1)
        oldy = oldy + 1
    end
    while true do
        local id, msg, protocol = rednet.receive()
        if (protocol=="CARPORDER") and ((tonumber(id)==2) or tonumber(id)==20) then
            if msg=="sendfiles" then
                local data = load("logs")
                rednet.send(id, data, "receivefiles")
            elseif msg=="allowterm" then
                local data = load("settings")
                data.terminate = true
                save("settings", data, nil)
                os.pullEvent = oldPullEvent
                settings.set(disks, true)
            elseif msg=="disallowterm" then
                local data = load("settings")
                data.terminate = false
                save("settings", data, nil)
                os.pullEvent = os.pullEventRaw
                settings.set(disks, false)
            end
        else
            msgs = msg
            monitor.setTextColor(colors.yellow)
            if protocol~=nil then
                if protocol=="BROADCAST" then
                    monitor.setTextColor(colors.red)
                end
                msgs = msg.." (PROTOCOL: \""..protocol.."\")"
            end
            tab = load("logs")
            save("logs", tab, msgs)
            monitor.write(time()..msgs)
        end
        protocol = nil
        msgs = nil
        msg = nil
        monitor.setTextColor(colors.yellow)
        monitor.setCursorPos(1, oldy + 1)
        oldy = oldy + 1
        if oldy==29 then
            monitor.scroll(1)
            oldy=28
            monitor.setCursorPos(1, oldy)
        end
    end
end
