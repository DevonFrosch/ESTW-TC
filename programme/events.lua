local eventData = {}

local function listenForCharPressed()
    local event, character = os.pullEvent("char")
    eventData = {
        event = event,
        char = character
    }
end
local function listenForRednetReceive()
    local id, msg, proto = rednet.receive()
    eventData = {
        id = id,
        msg = msg,
        protocol = proto
    }
end
local function listenForMonitorTouch()
    local event, side, x, y = os.pullEvent("monitor_touch")
    eventData = {
        event = event,
        size = size,
        x = x,
        y = y,
    }
end
local function listenForTimerEvent()
    local event, id = os.pullEvent("timer")
    eventData = {
        event = event,
        id = id,
    }
end
local function listenForRedstoneChange()
    local event = os.pullEvent("redstone")
    eventData = {
        event = event,
    }
end

listen = function(handlers)
    repeat
        local eventNumber = parallel.waitForAny(
            listenForCharPressed,
            listenForRednetReceive,
            listenForMonitorTouch,
            listenForTimerEvent,
            listenForRedstoneChange
        )
        
        if type(handlers.beforeHook) == "function" then
            handlers.beforeHook()
        end
        
        if eventNumber == 1 and type(handlers.onCharEvent) == "function" then
            handlers.onCharEvent(eventData)
        elseif eventNumber == 2 and type(handlers.onRednetReceive) == "function" then
            handlers.onRednetReceive(eventData)
        elseif eventNumber == 3 and type(handlers.onMonitorTouch) == "function" then
            handlers.onMonitorTouch(eventData)
        elseif eventNumber == 4 and type(handlers.onTimerEvent) == "function" then
            handlers.onTimerEvent(eventData)
        elseif eventNumber == 5 and type(handlers.onRedstoneChange) == "function" then
            handlers.onRedstoneChange(eventData)
        end
        
        if type(handlers.afterHook) == "function" then
            handlers.afterHook()
        end
    until eventNumber == 1 and eventData.char == "x"
end