local airlockURL = "https://raw.githubusercontent.com/ComputerTalk/ComputerCraftScripts/master/AdvancedRocketry/AirLock/DoorController.lua"

local airlock
local airlockFile

airlock = http.get(airlockURL)
airlockFile = airlock.readAll()


local fout = fs.open("airlock", "w")
fout.write(airlockFile)
fout.close()

