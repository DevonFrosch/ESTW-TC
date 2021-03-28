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

-- Hilfsfunktionen
local function dump(o)
    if type(o) ~= 'table' then
        return tostring(o)
    end
    
    local s = '{'
    for k,v in pairs(o) do
        if type(k) ~= 'number' then
            k = '"'..k..'"'
        end
        s = s .. '['..k..']=' .. dump(v) .. ','
    end
    -- letztes Komma entfernen
    if s:len() >= 1 then
        s = s:sub(0, s:len() - 1)
    end
    return s .. '}'
end
local function splitString(inputstr)
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
local function setzteTimer(zeit, callback, ...)
    log.debug("setzteTimer("..zeit..")")
    local id = os.startTimer(zeit)
    laufendeTimer[id] = {
        callback = callback,
        params = arg,
    }
end
local function behandleTimer(id)
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
local function send(id, message)
    log.debug("SENDTO "..id..": "..(message or "nil"))
    rednet.send(id, message, local_protocol)
end
local function sendHello(id)
    local seed = math.random(0, 100)
    send(id, "HELLO IAM " .. (local_role or SERVER) .. " " .. seed)
    return seed
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
local function rednetMessageReceivedServer(id, packet, onchange)
    local message = getMessage(packet, id)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM <clientName>
    if #message >= 3 and command == "HELLO" and message[3] ~= ownName then
        clientIds[message[3]] = id
        clientNames[id] = message[3]
        log.info("Neuer Client: id="..id..", name="..message[3]..", seed="..(message[4] or "none"))
    end
    
    -- REDSTONE <side> <color> <ON|OFF>
    if #message >= 5 and command == "REDSTONE" then
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
local function sendRestoneMessageServer(clientName, side, colorIndex, bit)
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
    
    send(clientIds[clientName], message)
end
local function sendRedstoneImpulseServer(clientName, side, colorIndex)
    sendRestoneMessageServer(clientName, side, colorIndex, true)
    local resetRedstone = function(clientName, side, colorIndex)
        sendRestoneMessageServer(clientName, side, colorIndex, false)
    end
    setzteTimer(0.2, resetRedstone, clientName, side, colorIndex)
end

-- Client-Funktionen
local function sendRedstoneChangeClient(side, index, bit)
    local message = "REDSTONE " .. local_role .. " " .. side
    
    message = message .. " " .. index
    
    if bit > 0 then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    if serverId ~= nil then
        send(serverId, message)
    end
end
local function rednetMessageReceivedClient(id, packet, onRegister, onChange)
    local message = getMessage(packet, id)
    
    if message == nil then
        return false
    end
    
    local command = message[1]
    
    -- HELLO IAM Server
    if #message >= 3 and command == "HELLO" and message[3] == SERVER then
        serverId = id
        local seed = sendHello(serverId)
        log.info("Neuer Server: id="..serverId..", seed="..(message[4] or "none")..", antwortSeed="..seed)
        onRegister()
    end
    
    -- REDSTONE <side> <ON|OFF>
    if #message >= 5 and command == "REDSTONE" then
        local side, color, state = message[3], tonumber(message[4]), message[5]
        onChange(side, color, state)
    end
end
local function findeServer(versuche)
    serverId = rednet.lookup(local_protocol, SERVER)
    if serverId then
        local seed = sendHello(serverId)
        log.info("Server gefunden id=" .. serverId .. ", seed=" .. seed)
        return true
    else
        log.warn("Kein Server gefunden, Client "..local_role)
        if versuche > 0 then
            setzteTimer(2, findeServer, versuche - 1)
        end
        return false
    end
end

local function init(protocol, modem, role, logger)
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
                local seed = sendHello(foundClient)
                log.debug("Frage Client "..foundClient..", seed="..seed)
            end
        else
            log.debug("Keine Clients gefunden")
        end
    else
        ownName = "Client "..role
        log.debug("Registriere "..ownName.." auf "..local_protocol)
        ---rednet.host(local_protocol, ownName)

        return findeServer(2)
    end
end
local function deinit()
    if ownName == ownName then
        rednet.unhost(local_protocol, ownName)
    end
    rednet.close(local_modem)
end

local function getProtocol()
    return local_protocol
end
local function getServerId()
    return serverId
end


return {
    rednetMessageReceivedServer = rednetMessageReceivedServer,
    sendRestoneMessageServer = sendRestoneMessageServer,
    sendRedstoneImpulseServer = sendRedstoneImpulseServer,
    
    sendRedstoneChangeClient = sendRedstoneChangeClient,
    rednetMessageReceivedClient = rednetMessageReceivedClient,
    
    init = init,
    deinit = deinit,
    
    getProtocol = getProtocol,
    getServerId = getServerId,
}