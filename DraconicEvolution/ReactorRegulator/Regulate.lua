local buttons = {}

-- Modify these peripheral names

local inFluxGateName = "flux_gate_0"
local outFluxGateName = "flux_gate_3"
local monitorName = "monitor_5"
local reactorPosition = "back"


-- -- Maximum output flux allowed by the program, 1.2 Mrf/t by default
-- -- The max output can be higher than this, but it is not safe to run at that output

local maxOutputFlux = 1200000
local minShieldPercent = 15
local minFuelPercent = 15
local maxTemperature = 7800

local targetOutput = 0


-- Load the APIs 
os.loadAPI("lib/text")


-- Create peripherals
local mon = periph.wrap(monitorName)
local outFluxGate = periph.wrap(outFluxGateName)
local inFluxGate = periph.wrap(inFluxGateName)
local reactor = peripheral.wrap(reactorPosition)

monX, monY = mon.getSize()
monitor = {}
monitor.mon,monitor.X, monitor.Y = mon, monX, monY


-- Error check peripherals
if monitor == nil then
	error("Monitor not found")
end

if inFluxGate == nil then
	error("Input flux gate not found")
end

if reactor == nil then
	error("Reactor not found")
end

if outFluxGate == nil then
	error("Output flux gate not found")
end



-- status check functions
function cold(info)
    text.clear()
    
end

function charging(info)
    if isCharged(info) then
        return charged
    end
    return charging
end

function charged(info)
    start()
    return online
end

function online(info)
    -- check for instability
    if highTemp(info) or lowShield(info) or highConversionRate(info) then
        -- Emergency Stop
        stop()
        return stopping
    end 
    ----------------------------
    ----------------------------
    -- modify in and out flux --
    ----------------------------
    ----------------------------
    return online
end

function stopping(info)
    -- if it is low fuel, just continue stopping
    if lowFuel(info) or highTemp(info) or lowShield(info) or highConversionRate(info) then
        return stopping
    end
    charge()
    return charging
end



-- action functions
function stop()
    reactor.stopReactor()
end

function charge()
    -- set initial input flux to charge shield
    reactor.chargeReactor()
end

function start()
    reactor.startReactor()
end



-- instability check functions
function lowFuel(info)
    fuelPercent = 100 - math.ceil(info.fuelConversion / info.maxFuelConversion * 100)
    return fuelPercent < minFuelPercent
end

function highTemp(info)
    return info.temperature > maxTemperature
end

function lowShield(info)
    shieldPercent = getShieldPercent(info)
    return shieldPercent < minShieldPercent
end

function highConversionRate(info)
    return false
end

-- helper functions
function isCharged(info)
    shieldPercent = getShieldPercent(info)
    return shieldPercent >= 50
end

function getShieldPercent(info)
    return math.ceil(ri.fieldStrength / ri.maxFieldStrength * 100)
end

function increaseTargetOutput(amount)
    if targetOutput + amount <= maxOutputFlux then
        targetOutput = targetOutput + amount
    end
end

function decreaseTargetOutput(amount)
    if targetOutput - amount > 0 then
        targetOutput = targetOutput - amount    
    end
end

function updateFluxInput(info)
--  inFluxGate.setSignalLowFlow( )
    fluxval = info.fieldDrainRate / (1 - (targetStrength/100) )
    inFluxGate.setSignalLowFlow(fluxval)
end


buttons.stop = {label="Stop",action=stop,params={},textColor=colors.red,bgColor=colors.gray}
buttons.start = {label="Start",action=start,params={},textColor=colors.green,bgColor=colors.gray}

buttons.increase1000 = {label=">",action=increaseTargetOutput,params={1000},textColor=colors.white,bgColor=colors.gray}
buttons.increase10000 = {label=">>",action=increaseTargetOutput,params={10000},textColor=colors.white,bgColor=colors.gray}
buttons.increase100000 = {label=">>>",action=increaseTargetOutput,params={100000},textColor=colors.white,bgColor=colors.gray}

buttons.decrease1000 = {label="<",action=decreaseTargetOutput,params={1000},textColor=colors.white,bgColor=colors.gray}
buttons.decrease10000 = {label="<<",action=decreaseTargetOutput,params={10000},textColor=colors.white,bgColor=colors.gray}
buttons.decrease100000 = {label="<<<",action=decreaseTargetOutput,params={100000},textColor=colors.white,bgColor=colors.gray}

buttons.NA = {label=nil,action=nil,params=nil,textColor=nil,bgColor=nil}

ButtonMap={}
for i=1,29 do
    for j=1,19 do
        ButtonMap[i],[j] = buttons.NA 
    end
end 



-- GUI
function displayStats(info)
    text.clear()
end 



-- Control Functions
function ReactorController()
    local info
    func = cold
    while true do
        info = reactor.getReactorInfo()
        displayStats(info)
        func = func(info)
        sleep(0.05)
    end 
end 

function ButtonListener()
    while true do
        event, side, xPos, yPos = os.pullEvent("monitor_touch")
        
        button = ButtonMap[i][j]
        if button.action != nil and button.params != nil then
            button.action(unpack(button.params))
        end
    end
end

parallel.waitforany(ReactorController,ButtonListener)