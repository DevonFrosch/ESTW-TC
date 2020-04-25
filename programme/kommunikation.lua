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
local log = {
    error = function() end,
    warn = function() end,
    info = function() end,
    debug = function() end,
}

if not tools then
    os.loadAPI("bin/tools")
end

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

local function getMessage(packet, id)
    log.debug("Nachricht id="..id.." packet="..tools.dump(packet))
    
    local message = ""
    if type(packet) == "table" then
        message = splitString(packet[1])
    elseif type(packet) == "string" then
        message = splitString(packet)
    else
        log.warn("Falscher Typ für Paket: id="..id..", packet="..type(packet))
        return nil
    end
    
    if message == nil then
        return nil
    end
    
    return message
end

-- Server-Funktionen
rednetMessageReceivedServer = function(id, packet, onchange)
    local message = getMessage(packet, id)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM <clientName>
    if #message == 3 and command == "HELLO" and message[3] ~= ownName then
        clientIds[message[3]] = id
        clientNames[id] = message[3]
        log.info("Neuer Client: id="..id..", name="..message[3])
    end
    
    -- REDSTONE <side> <color> <ON|OFF>
    if #message == 5 and command == "REDSTONE" then
        local side, color, state = message[3], message[4], message[5]
        
        if tonumber(message[4]) == nil then
            log.error("Farbe ist keine Zahl: "..(message[4] or "nil"))
            return false
        end
        local colorIndex = math.log(color) / math.log(2)
        local pc = clientNames[id]
        if pc == nil then
            log.warn("PC nicht registriert: id="..id)
            return false
        end
        pc = tostring(pc)
        
        onchange(pc, side, colorIndex, state)
    end
    
    return true
end
sendRestoneMessageServer = function(clientName, side, colorIndex, bit)
    local index = 2 ^ colorIndex
    clientName = tostring(clientName)
    if clientIds[clientName] == nil then
        log.warn("sendRestoneMessageServer: Kein Client fuer " .. (clientName or "nil") .. " verbunden", clientIds)
        return
    end

    local message = "REDSTONE " .. ownName .. " " .. side
    
    message = message .. " " .. index
    
    if bit then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    log.debug("SENDTO "..clientName..": "..message)
    rednet.send(clientIds[clientName], message, local_protocol)
end
sendRedstoneImpulseServer = function(clientName, side, colorIndex)
    sendRestoneMessageServer(clientName, side, colorIndex, true)
    local resetRedstone = function(clientName, side, colorIndex)
        sendRestoneMessageServer(clientName, side, colorIndex, false)
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
        log.debug("SEND: "..message)
        rednet.send(serverId, message, local_protocol)
    end
end
rednetMessageReceivedClient = function(id, packet, onRegister, onChange)
    local message = getMessage(packet, id)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM Server
    if #message == 3 and command == "HELLO" and message[3] == SERVER then
        serverId = id
        log.info("Neuer Server: id="..serverId)
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

init = function(protocol, modem, role, logger)
    log = logger
    
    local_protocol = protocol .. " v" .. version
    local_modem = modem
    local_role = role
    
    log.debug("Verbinde: local_protocol="..local_protocol)
    
    rednet.open(local_modem)
    
    if role == nil then
        ownName = SERVER
        log.debug("Registriere "..ownName.." auf "..local_protocol)
        rednet.host(local_protocol, ownName)
        
        foundClients = {rednet.lookup(local_protocol)}
        if type(foundClients) == "table" then
            for i, foundClient in ipairs(foundClients) do
                log.debug("Frage Client "..foundClient)
                rednet.send(foundClient, "HELLO IAM "..ownName, local_protocol)
            end
        else
            log.debug("Keine Clients gefunden")
        end
    else
        ownName = "Client "..role
        log.debug("Registriere "..ownName.." auf "..local_protocol)
        rednet.host(local_protocol, ownName)

        serverId = rednet.lookup(local_protocol, SERVER)
        if serverId then
            log.info("Server gefunden id=" .. serverId)
            rednet.send(serverId, "HELLO IAM " .. role, local_protocol)
        else
            log.warn("Kein Server gefunden, Client "..role)
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
getServerId = function()
    return serverId
end