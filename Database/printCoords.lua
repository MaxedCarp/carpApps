pr = peripheral.find("printer")
local list = fs.list("users/")
pr.newPage()
pr.setPageTitle("coords #"..1)
local counter = 2
local mx, my = pr.getPageSize()
local file = nil
local data = nil
local x = 1
local y = 1
for _, fn in ipairs(list) do
    x, y = pr.getCursorPos()
    if y==(my+1) then
        pr.endPage()
        pr.newPage()
        pr.setPageTitle("coords #"..counter)
        counter = counter + 1
    end
    pr.setColor(colors.blue)
    file = fs.open("users/"..fn, "r")
    data = textutils.unserialise(file.readAll())
    file.close()
    pr.write(data["name"]..": ")
    pr.setColor(colors.green)
    pr.setCursorPos(1, y+1)
    y = y + 1
    pr.write(data["pos"])
    pr.setCursorPos(1, y+1)
    y = y + 1
end
pr.endPage()
term.setTextColor(colors.lime)
write("Printed: "..#list.." Users!\n")
term.setTextColor(colors.white)
