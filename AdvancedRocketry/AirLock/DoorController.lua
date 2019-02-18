-- Enter the sides that the computer is connected to for each block

-- entity detector side (expects a redstone signal)
local detector = "bottom"
-- Door that connects to space side of airlock (redstone signal will output to this side)
local outerDoor = "left"
-- Door that connects to oxygenated side of airlock (redstone signal will output to this side)
local innerDoor = "back"

-- name of monitor that leads into airlock from space
local outerEntranceMonitorName = "monitor_6"
-- name of monitor that leads into base from airlock
local innerEntranceMonitorName = "monitor_8"
-- name of monitor that leads out to space from airlock
local outerExitMonitorName = "monitor_9"
-- name of monitor that leads into airlock from base
local innerExitMonitorName = "monitor_7"


-- wrap the monitor names for easier use later
local outerEntranceMonitor = peripheral.wrap(outerEntranceMonitorName)
local innerEntranceMonitor = peripheral.wrap(innerEntranceMonitorName)
local outerExitMonitor = peripheral.wrap(outerExitMonitorName)
local innerExitMonitor = peripheral.wrap(innerExitMonitorName)




-- opens the door passed in
function openDoor(doorName)
    redstone.setAnalogOutput(doorName,15)
end

-- closes the door passed in
function closeDoor(doorName)
    redstone.setAnalogOutput(doorName,0)
end

-- returns true if a player is detected in the airlock
function playerDetected()
    ret_val = redstone.getAnalogInput(detector) ~= 0
    return ret_val
end

-- opens doors, needs monitor displays
function ButtonListener()
    switch = {
        [outerEntranceMonitorName] = function ()
            if playerDetected() then
                -- Access Denied
            else
                closeDoor(innerDoor)
                sleep(3)
                openDoor(outerDoor)
                sleep(3)
                closeDoor(outerDoor)
            end
        end;
        [innerEntranceMonitorName] = function ()
            closeDoor(outerDoor)
            sleep(3)
            openDoor(innerDoor)
            sleep(3)
            closeDoor(innerDoor)
        
        end;
        [outerExitMonitorName] = function ()
            closeDoor(innerDoor)
            sleep(3)
            openDoor(outerDoor)
            sleep(3)
            closeDoor(outerDoor)
        
        end;
        [innerExitMonitorName] = function ()
            closeDoor(outerDoor)
            sleep(3)
            openDoor(innerDoor)
            sleep(3)
            closeDoor(innerDoor)
        
        end
    }
    
    do
        _,name,_,_ = os.PullEvent("monitor_touch")
        switch[name]() 
    end
end

ButtonListener()