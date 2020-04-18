-- load configuration
local debug = false
local configFile = "config"
if not fs.exists(configFile) then
    print("Config not found")
    return
end

os.loadAPI(configFile)

-- test config
local configTests = {
    modem = type(config.modem) == "string",
    name = type(config.name) == "string",
    role = type(config.role) == "string",
    sides = type(config.sides) == "table",
    ["sides.left"]   = config.sides and (config.sides.left   == nil or config.sides.left   == true),
    ["sides.right"]  = config.sides and (config.sides.right  == nil or config.sides.right  == true),
    ["sides.top"]    = config.sides and (config.sides.top    == nil or config.sides.top    == true),
    ["sides.bottom"] = config.sides and (config.sides.bottom == nil or config.sides.bottom == true),
    ["sides.front"]  = config.sides and (config.sides.front  == nil or config.sides.front  == true),
    ["sides.back"]   = config.sides and (config.sides.back   == nil or config.sides.back   == true),
}

for name, test in pairs(configTests) do
    if not test then
        print("Config fuer "..name.." falsch formatiert")
        return
    end
end
if debug then
    print("Config ok")
end

local serverId = nil
local redstoneStates = {}

local protocolVersion = "STW v1"
local protocol = protocolVersion .. " " .. config.name
local serverName = "Server"
local clientName = "Client"..tostring(config.role)
local redstoneHasChanged = function() print("stub") end -- defined below

function splitString(inputstr)
    local tbl = {}
    local i = 1
    local matches = string.gmatch(inputstr, "([^ ]+)")
    for part in matches do
        tbl[i] = part
        i = i + 1
    end
    return tbl
end

local function init()
    rednet.open(config.modem)
    if debug then
        print("Registriere "..clientName.." auf "..protocol)
    end
    rednet.host(protocol, clientName)

    serverId = rednet.lookup(protocol, serverName)
    if serverId then
        print("Server: " .. serverId..", Client "..config.role)
        rednet.send(serverId, "HELLO IAM " .. config.role, protocol)
    else
        print("Kein Server gefunden, Client "..config.role)
    end
end
local function deinit()
    rednet.unhost(protocol, clientName)
    rednet.close(config.modem)
end

local function rednetMessageReceived(id, packet)
    print("Nachricht von "..id..":")
    print(packet)
    
    local message = ""
    if type(packet) == "table" then
        message = splitString(packet[1])
    elseif type(packet) == "string" then
        message = splitString(packet)
    else
        print("Falscher Typ: packet="..type(packet))
    end
    
    local command = message[1]
    
    -- HELLO IAM Server
    if #message == 3 and command == "HELLO" and message[3] == serverName then
        serverId = id
        print("Neuer Server: id="..serverId)
        local msg = "HELLO IAM " .. config.role
        if debug then
            print("SEND "..msg)
        end
        rednet.send(serverId, msg, protocol)
        -- reset send redstone states
        redstoneStates = {}
        redstoneHasChanged()
    end
    
    -- REDSTONE <side> <ON|OFF>
    if #message == 5 and command == "REDSTONE" then
        local side, color, state = message[3], tonumber(message[4]), message[5]
        if not config.sides[side] then
            print("Seite "..side.." nicht verbunden")
            return
        end
        if state == "ON" then
            local newColors = colors.combine(redstone.getBundledOutput(side), color)
            redstone.setBundledOutput(side, newColors)
        else
            local newColors = colors.subtract(redstone.getBundledOutput(side), color)
            redstone.setBundledOutput(side, newColors)
        end
    end
end
local function sendRedstoneChange(side, index, bit)
    local message = "REDSTONE " .. config.role .. " " .. side
    
    message = message .. " " .. index
    
    if bit > 0 then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    if serverId ~= nil then
        print("SEND "..message)
        rednet.send(serverId, message, protocol)
    end
end
function redstoneHasChanged()
    if debug then
        print("redstoneHasChanged")
    end
    for side, use in pairs(config.sides) do
        local newState = redstone.getBundledInput(side)
        local oldState = (redstoneStates[side] or 0)
        
        if newState ~= oldState then
            for i = 0, 15 do
                local index = (2 ^ i)
                local oldBit = bit.band(index, oldState)
                local newBit = bit.band(index, newState)
                if debug then
                    print("index="..index..",oldBit="..oldBit..",newBit="..newBit)
                end
                if newBit ~= oldBit then
                    sendRedstoneChange(side, index, newBit)
                end
            end
            redstoneStates[side] = newState
        end
    end
end

init()
redstoneHasChanged()

local eventData = {}
local function waitForCharPressed()
    local event, character = os.pullEvent("char")
    eventData = {
        event = event,
        char = character,
    }
end
local function waitForRednetReceive()
    while true do
        local id, msg, proto = rednet.receive()
        if proto == protocol then
            eventData = {
                id = id,
                msg = msg,
                protocol = protocol
            }
            return
        end
    end
end
local function waitForRedstoneChanged()
    local event = os.pullEvent("redstone")
    eventData = {
        event = event,
    }
end

repeat
    local eventNumber = parallel.waitForAny(waitForCharPressed, waitForRednetReceive, waitForRedstoneChanged)
    
    if eventNumber == 2 then
        rednetMessageReceived(eventData.id, eventData.msg)
    elseif eventNumber == 3 then
        redstoneHasChanged()
    end
until eventNumber == 1 and eventData.char == "x"

rednet.close(config.modem)
