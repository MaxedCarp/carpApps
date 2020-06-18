rednet.open("left")
--sleep(5)
--rednet.send(219, "inactive", "pet")
oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw
local isActive = false
local mx = -5208
local my = 67
local mz = -11973
local mid = vector.new(mx, my, mz)
local currentPos = vector.new(gps.locate(1, false))
local xp = currentPos.x
local zp = currentPos.z
-- Location Check Functions
local function CheckPos()
    currentPos = vector.new(gps.locate(1, false))
    xp = currentPos.x
    zp = currentPos.z
end
local function Quadrant()
    CheckPos()
    if xp>mx and zp>mz then
        return 1 -- South-East
    elseif xp<mx and zp>mz then
        return 2 -- South-West
    elseif xp<mx and zp<mz then
        return 3 -- North-West
    elseif xp>mx and zp<mz then
        return 4 -- North-East
    elseif xp==mx and zp==mz then
        return 5 -- MID
    elseif xp==mx and zp>mz then
        return 6 -- Positive Z
    elseif xp==mx and zp<mz then
        return 7 -- Negative Z
    elseif xp>mx and zp==mz then
        return 8 -- Positive X
    elseif xp<mx and zp==mz then
        return 9 -- Negative X
    end
    return 999
end
local function CalcBlocks()
    CheckPos()
    local blocks = math.abs(mid - currentPos)
    return blocks
end
-- Border Related Functions
local function DPZBorder()
    return math.abs(zp - (-11934))
end
local function DNZBorder()
    return math.abs(zp - (-12010))
end
local function DPXBorder()
    return math.abs(xp - (-5169))
end
local function DNXBorder()
    return math.abs(xp - (-5247))
end
local function ClosestBorder()
    CheckPos()
    local min = DPZBorder()
    local borderName = "+Z"
    if min > DNZBorder() then
        min = DNZBorder()
        borderName = "-Z"
    end
    if min > DPXBorder() then
        min = DPXBorder()
        borderName = "+X"
    end
    if min > DNXBorder() then
        min = DNXBorder()
        borderName = "-X"
    end
    return borderName, min
end
-- Return Path Functions
local function ReturnPathX()
    CheckPos()
    while xp~=mx do
        if Quadrant()==1 then
            while turtle.getDirection()~="west" do
                turtle.turnLeft()
            end
        elseif Quadrant()==2 then
            while turtle.getDirection()~="east" do
                turtle.turnRight()
            end
        elseif Quadrant()==3 then
            while turtle.getDirection()~="east" do
                turtle.turnLeft()
            end
        elseif Quadrant()==4 then
            while turtle.getDirection()~="west" do
                turtle.turnRight()
            end
        end
        if Quadrant()==1 or Quadrant()==3 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnRight()
                end
                turtle.forward()
                turtle.turnLeft()
            end
        elseif Quadrant()==2 or Quadrant()==4 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnLeft()
                end
                turtle.forward()
                turtle.turnRight()
            end
        end
        turtle.forward()
        CheckPos()
    end
end
local function ReturnPathZ()
    CheckPos()
    while zp~=mz do
        if Quadrant()==1 then
            while turtle.getDirection()~="north" do
                turtle.turnLeft()
            end
        elseif Quadrant()==2 then
            while turtle.getDirection()~="north" do
                turtle.turnRight()
            end
        elseif Quadrant()==3 then
            while turtle.getDirection()~="south" do
                turtle.turnLeft()
            end
        elseif Quadrant()==4 then
            while turtle.getDirection()~="south" do
                turtle.turnRight()
            end
        end
        if Quadrant()==1 or Quadrant()==3 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnLeft()
                end
                turtle.forward()
                turtle.turnRight()
            end
        elseif Quadrant()==2 or Quadrant()==4 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnRight()
                end
                turtle.forward()
                turtle.turnLeft()
            end
        end
        turtle.forward()
        CheckPos()
    end
end
local function FinishX()
    CheckPos()
    while xp~=mx do
        if Quadrant()==8 then
            while turtle.getDirection()~="west" do
                turtle.turnRight()
            end
        elseif Quadrant()==9 then
            while turtle.getDirection()~="east" do
                turtle.turnLeft()
            end
        end
        if Quadrant()==1 or Quadrant()==3 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnRight()
                end
                turtle.forward()
                turtle.turnLeft()
            end
        elseif Quadrant()==2 or Quadrant()==4 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnLeft()
                end
                turtle.forward()
                turtle.turnRight()
            end
        end
        turtle.forward()
        CheckPos()
    end
end
local function FinishZ()
    CheckPos()
    while zp~=mz do
        if Quadrant()==6 then
            while turtle.getDirection()~="north" do
                turtle.turnLeft()
            end
        elseif Quadrant()==7 then
            while turtle.getDirection()~="south" do
                turtle.turnLeft()
            end
        end
        if Quadrant()==1 or Quadrant()==3 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnLeft()
                end
                turtle.forward()
                turtle.turnRight()
            end
        elseif Quadrant()==2 or Quadrant()==4 then
            if turtle.inspect()~=false then
                while turtle.inspect()~=false do
                    turtle.turnRight()
                end
                turtle.forward()
                turtle.turnLeft()
            end
        end
        turtle.forward()
        CheckPos()
    end
end
-- Choice Functions
local function UseBestPath()
    CheckPos()
    if math.abs(math.abs(xp) - math.abs(mx)) > math.abs(math.abs(zp) - math.abs(mz)) then
        ReturnPathZ()
        CheckPos()
        FinishX()
    else
        ReturnPathX()
        CheckPos()
        FinishZ()
    end
end
-- Movement Functions
local function Return()
    os.pullEventRaw("terminate")
    isActive = false
    print("Returning!\n")
    UseBestPath()
    print("Done!\n")
    os.pullEvent = oldPull
end
local function Move()
    if isActive then
    
    end
end
-- Control Functions
local function Activate()
    while true do
        local id, msg, prot = rednet.receive("petctrl")
        if id == 219 then
            if prot == "petctrl" then
                if msg == "petactivate" then
                    isActive = true
                    os.pullEvent = os.pullEventRaw
                end
            end
        end
    end
end
local function Deactivate()
    while true do
        local id, msg, prot = rednet.receive("petctrl")
        if id == 219 then
            if msg == "petdeactivate" then
                isActive = false
                Return()
            end
        end
    end
end
-- Startup
print(Quadrant())
parallel.waitForAll(Return)
