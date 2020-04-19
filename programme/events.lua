local eventData = {}

local local_rednetProtocol = nil

local function listenForCharPressed()
    local event, character = os.pullEvent("char")
    eventData = {
        event = event,
        char = character
    }
end
local function listenForRednetReceive()
    while true do
        local id, msg, proto = rednet.receive()
        if local_rednetProtocol == nil or proto == local_rednetProtocol then
            eventData = {
                id = id,
                msg = msg,
                protocol = proto
            }
            return
        end
    end
end
local function listenForMonitorTouch()
    local event, side, x, y = os.pullEvent("monitor_touch")
    eventData = {
        event = event,
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

listen = function(beforeHook, afterHook, onCharEvent, onRednetReceive, onMonitorTouch, onTimerEvent, rednetProtocol)
    local_rednetProtocol = rednetProtocol
    
    repeat
        local eventNumber = parallel.waitForAny(listenForCharPressed, listenForRednetReceive, listenForMonitorTouch, listenForTimerEvent)
        
        if type(beforeHook) == "function" then
            beforeHook()
        end
        
        if eventNumber == 1 and type(onCharEvent) == "function" then
            onCharEvent(eventData)
        elseif eventNumber == 2 and type(onRednetReceive) == "function" then
            onRednetReceive(eventData)
        elseif eventNumber == 3 and type(onMonitorTouch) == "function" then
            onMonitorTouch(eventData)
        elseif eventNumber == 4 and type(onTimerEvent) == "function" then
            onTimerEvent(eventData)
        end
        
        if type(afterHook) == "function" then
            afterHook()
        end
    until eventNumber == 1 and eventData.char == "x"
end