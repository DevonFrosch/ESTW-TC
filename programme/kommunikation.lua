local local_protocol = nil
local local_serverName = nil
local local_modem = nil

local laufendeTimer = {}
local clientIds = {}
local clientNames = {}

splitString = function(inputstr)
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
        return
    end
    if timerData.callback == nil or timerData.params == nil then
        return
    end
    timerData.callback(unpack(timerData.params))
end

rednetMessageReceived = function(id, packet, onchange, debug)
    if debug then
        print("Nachricht von "..id..": "..(packet or ""))
    end
    
    local message = ""
    if type(packet) == "table" then
        message = splitString(packet[1])
    elseif type(packet) == "string" then
        message = splitString(packet)
    else
        print("Falscher Typ: packet="..type(packet))
    end
    
    local command = message[1]
    
    -- HELLO IAM <clientName>
    if #message == 3 and command == "HELLO" and message[3] ~= local_serverName then
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
            return
        end
        pc = tostring(pc)
        
        onchange(pc, side, color, state)
    end
end
sendRestoneMessage = function(clientName, side, colorIndex, bit, debug)
    local index = 2 ^ colorIndex
    clientName = tostring(clientName)
    if clientIds[clientName] == nil then
        print("Kein Client fuer " .. (clientName or "nil") .. " verbunden")
        return
    end

    local message = "REDSTONE " .. local_serverName .. " " .. side
    
    message = message .. " " .. index
    
    if bit then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    if debug then
        print("SEND "..message)
    end
    rednet.send(clientIds[clientName], message, local_protocol)
end
sendRedstoneImpulse = function(clientName, side, colorIndex, debug)
    sendRestoneMessage(clientName, side, colorIndex, true, debug)
    local resetRedstone = function(clientName, side, colorIndex)
        sendRestoneMessage(clientName, side, colorIndex, false, debug)
    end
    setzteTimer(0.2, resetRedstone, clientName, side, colorIndex)
end


init = function(protocol, modem, serverName)
    if debug then
        print("Protokoll: "..protocol)
    end
    
    local_protocol = protocol
    local_serverName = serverName
    local_modem = modem
    
    rednet.open(local_modem)
    rednet.host(local_protocol, local_serverName)
    
    foundClients = {rednet.lookup(local_protocol)}
    if type(foundClients) == "table" then
        for i, foundClient in ipairs(foundClients) do
            if debug then
                print("Frage Client "..foundClient)
            end
            rednet.send(foundClient, "HELLO IAM "..local_serverName, local_protocol)
        end
    end
end
deinit = function()
    rednet.unhost(local_protocol, local_serverName)
    rednet.close(local_modem)
end