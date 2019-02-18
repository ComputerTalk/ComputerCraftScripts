 
local airlockURL = "https://raw.githubusercontent.com/acidjazz/drmon/master/drmon.lua"

local airlock
local airlockFile

airlock = http.get(airlockURL)
airlockFile = airlock.readAll()


local fout = fs.open("airlock", "w")
fout.write(airlockFile)
fout.close()