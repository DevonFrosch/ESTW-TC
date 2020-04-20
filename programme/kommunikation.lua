local local_protocol = nil
local local_modem = nil
local local_role = nil
local ownName = nil

local SERVER = "Server"

local laufendeTimer = {}
local clientIds = {}
local clientNames = {}

local serverId = nil

local version = 2

-- Hilfsfunktionen
splitString = function(inputstr)
    if inputstr == nil then
        return nil
    end
    local tbl = {}
    local i = 1
    local matches = inputstr:gmatch("([^ ]+)")
    for part in matches do
        tbl[i] = part
        i = i + 1
    end
    return tbl
end
setzteTimer = function(zeit, callback, ...)
    local id = os.startTimer(zeit)
    laufendeTimer[id] = {
        callback = callback,
        params = arg,
    }
end
behandleTimer = function(id)
    local timerData = laufendeTimer[id]
    if timerData == nil then
        return false
    end
    if timerData.callback == nil or timerData.params == nil then
        return false
    end
    timerData.callback(unpack(timerData.params))
    return true
end

local function getMessage(packet, id, debug)
    if debug then
        print("Nachricht id="..id.." packet="..tools.dump(packet))
    end
    
    local message = ""
    if type(packet) == "table" then
        message = splitString(packet[1])
    elseif type(packet) == "string" then
        message = splitString(packet)
    else
        print("Falscher Typ: id="..id..", packet="..type(packet))
        return nil
    end
    
    if message == nil then
        return nil
    end
    
    return message
end

-- Server-Funktionen
rednetMessageReceivedServer = function(id, packet, onchange, debug)
    local message = getMessage(packet, id, debug)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM <clientName>
    if #message == 3 and command == "HELLO" and message[3] ~= ownName then
        clientIds[message[3]] = id
        clientNames[id] = message[3]
        if debug then
            print("Neuer Client: id="..id..", name="..message[3])
        end
    end
    
    -- REDSTONE <side> <color> <ON|OFF>
    if #message == 5 and command == "REDSTONE" then
        local side, color, state = message[3], message[4], message[5]
        
        local pc = clientNames[id]
        if pc == nil then
            print("PC nicht registriert: id="..id)
            return false
        end
        pc = tostring(pc)
        
        onchange(pc, side, color, state)
    end
    
    return true
end
sendRestoneMessageServer = function(clientName, side, colorIndex, bit, debug)
    local index = 2 ^ colorIndex
    clientName = tostring(clientName)
    if clientIds[clientName] == nil then
        print("sendRestoneMessageServer: Kein Client fuer " .. (clientName or "nil") .. " verbunden")
        return
    end

    local message = "REDSTONE " .. ownName .. " " .. side
    
    message = message .. " " .. index
    
    if bit then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    if debug then
        print("SENDTO "..clientName..": "..message)
    end
    rednet.send(clientIds[clientName], message, local_protocol)
end
sendRedstoneImpulseServer = function(clientName, side, colorIndex, debug)
    sendRestoneMessage(clientName, side, colorIndex, true, debug)
    local resetRedstone = function(clientName, side, colorIndex)
        sendRestoneMessage(clientName, side, colorIndex, false, debug)
    end
    setzteTimer(0.2, resetRedstone, clientName, side, colorIndex)
end

-- Client-Funktionen
sendRedstoneChangeClient = function(side, index, bit)
    local message = "REDSTONE " .. local_role .. " " .. side
    
    message = message .. " " .. index
    
    if bit > 0 then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    if serverId ~= nil then
        if debug then
            print("SEND: "..message)
        end
        rednet.send(serverId, message, local_protocol)
    end
end
rednetMessageReceivedClient = function(id, packet, onRegister, onChange, debug)
    local message = getMessage(packet, id, debug)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM Server
    if #message == 3 and command == "HELLO" and message[3] == SERVER then
        serverId = id
        print("Neuer Server: id="..serverId)
        local msg = "HELLO IAM " .. local_role
        rednet.send(serverId, msg, local_protocol)
        onRegister()
    end
    
    -- REDSTONE <side> <ON|OFF>
    if #message == 5 and command == "REDSTONE" then
        local side, color, state = message[3], tonumber(message[4]), message[5]
        onChange(side, color, state)
    end
end

init = function(protocol, modem, role, debug)
    local_protocol = protocol .. " v" .. version
    local_modem = modem
    local_role = role
    
    if debug then
        print("Verbinde: local_protocol="..local_protocol)
    end
    
    rednet.open(local_modem)
    
    if role == nil then
        ownName = SERVER
        rednet.host(local_protocol, ownName)
        
        foundClients = {rednet.lookup(local_protocol)}
        if type(foundClients) == "table" then
            for i, foundClient in ipairs(foundClients) do
                if debug then
                    print("Frage Client "..foundClient)
                end
                rednet.send(foundClient, "HELLO IAM "..ownName, local_protocol)
            end
        end
    else
        ownName = "Client "..role
        if debug then
            print("Registriere "..ownName.." auf "..local_protocol)
        end
        rednet.host(local_protocol, ownName)

        serverId = rednet.lookup(local_protocol, SERVER)
        if serverId then
            print("Server gefunden id=" .. serverId)
            rednet.send(serverId, "HELLO IAM " .. role, local_protocol)
        else
            print("Kein Server gefunden, Client "..role)
            return false
        end
    end
    return true
end
deinit = function()
    rednet.unhost(local_protocol, ownName)
    rednet.close(local_modem)
end

getProtocol = function()
    return local_protocol
end
