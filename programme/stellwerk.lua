function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- load configuration
local debug = false
local configFile = "config.lua"
if not fs.exists(configFile) then
    print("Config not found")
    return
end

os.loadAPI(configFile)
local config = _G[configFile]

local configContents = {
    gleisbildDatei = "string",
    signale = "table",
    fsZiele = "table",
    bahnuebergaenge = "table",
    gleise = "table",
    weichen = "table",
    fahrstrassenteile = "table",
    fahrstrassen = "table",
    bildschirm = "string",
    modem = "string",
    stellwerkName = "string",
}

for name, typ in pairs(configContents) do
    if type(config[name]) ~= typ then
        print("Config: kein "..name)
        return
    end
end

-- load text
if not fs.exists(config.gleisbildDatei) then
    print("Datei " .. config.gleisbildDatei .. " nicht gefunden")
    return
end

-- Status: 0 = Halt, 1 = Fahrt, 2 = Rangierfahrt
local signale = config.signale
local fsZiele = config.fsZiele
local bahnuebergaenge = config.bahnuebergaenge
-- Status: 0 = Frei, 1 = Besetzt
local gleise = config.gleise
local weichen = config.weichen
local fahrstrassenteile = config.fahrstrassenteile
-- Status: 0 = Nichts, 1 = Wird eingestellt, 2 = Festgelegt, 3 = Signalfreigabe, 4 = Wird aufgelöst
local fahrstrassen = config.fahrstrassen

local eingabe = ""
local eingabeModus = ""
local nachricht = ""
local clientIds = {}
local clientNames = {}
local laufendeTimer = {}

local protocolVersion = "STW v1"
local protocol = protocolVersion .. " " .. config.stellwerkName
local serverName = "Server"

local SIGNAL_HALT = "halt"
local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"

local mon = peripheral.wrap(config.bildschirm)
mon.clear()
mon.setCursorPos(1,1)
w, h = mon.getSize()

local fileHandle = fs.open(config.gleisbildDatei, "r")

local gleisbild = {}
for i = 1, h do
    local line = fileHandle.readLine()
    if line == nil then
        break
    end
    gleisbild[i] = line
end

fileHandle.close()

print("Startup, Bildschirm " .. w .. "x" .. h)

-- Kommunikation
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
local function setzteTimer(zeit, callback, ...)
    local id = os.startTimer(zeit)
    laufendeTimer[id] = {
        callback = callback,
        params = arg,
    }
end
local function behandleTimer(id)
    local timerData = laufendeTimer[id]
    if timerData == nil then
        return
    end
    if timerData.callback == nil or timerData.params == nil then
        return
    end
    timerData.callback(unpack(timerData.params))
end

local function init()
    if debug then
        print("Protokoll: "..protocol)
    end
    
    rednet.open(config.modem)
    rednet.host(protocol, serverName)
    
    foundClients = {rednet.lookup(protocol)}
    if type(foundClients) == "table" then
        for i, foundClient in ipairs(foundClients) do
            if debug then
                print("Frage Client "..foundClient)
            end
            rednet.send(foundClient, "HELLO IAM "..serverName, protocol)
        end
    end
end
local function deinit()
    rednet.unhost(protocol, serverName)
    rednet.close(config.modem)
end
local function rednetMessageReceived(id, packet)
    print("Nachricht von "..id..": "..(packet or ""))
    
    local message = ""
    if type(packet) == "table" then
        message = splitString(packet[1])
    elseif type(packet) == "string" then
        message = splitString(packet)
    else
        print("Falscher Typ: packet="..type(packet))
    end
    
    local command = message[1]
    
    -- HELLO IAM <clientname>
    if #message == 3 and command == "HELLO" and message[3] ~= serverName then
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
        
        -- Signale
        for sName, signal in pairs(signale) do
            if signal.hp ~= nil and tostring(signal.hp.pc) == pc and tostring(2 ^ signal.hp.fb) == color and tostring(signal.hp.au) == side then
                if debug then
                    print("Signalstatus "..sName)
                end
                if state == "ON" then
                    signal.status = SIGNAL_HP
                else
                    signal.status = SIGNAL_HALT
                end
            elseif signal.sh ~= nil and tostring(signal.sh.pc) == pc and tostring(2 ^ signal.sh.fb) == color and tostring(signal.sh.au) == side then
                if debug then
                    print("Signalstatus "..sName)
                end
                if state == "ON" then
                    signal.status = SIGNAL_SH
                else
                    signal.status = SIGNAL_HALT
                end
            end
        end
        
        -- Gleise
        for gName, gleis in pairs(gleise) do
            if tostring(gleis.pc) == pc and tostring(gleis.au) == side
                    and tostring(2 ^ gleis.fb) == color then
                if debug then
                    print("Gleisstatus "..gName)
                end
                if state == "ON" then
                    gleis.status = 1
                else
                    gleis.status = 0
                end
            end
        end
        
        -- Fahrstrassen
        for fName, fahrstrasse in pairs(fahrstrassen) do
            if fahrstrasse.melder and tostring(fahrstrasse.melder.pc) == tostring(pc) and tostring(fahrstrasse.melder.au) == side
                    and tostring(2 ^ fahrstrasse.melder.fb) == color then
                if debug then
                    print("Fahrstrassenstatus "..fName.." "..state)
                end
                if state == "ON" then
                    fahrstrasse.status = 3
                else
                    fahrstrasse.status = 0
                end
            end
        end
    end
end
local function sendRestoneMessage(clientNumber, side, colorIndex, bit)
    local index = 2 ^ colorIndex
    clientNumber = tostring(clientNumber)
    if clientIds[clientNumber] == nil then
        print("Kein Client fuer " .. (clientNumber or "nil") .. "verbunden")
        return
    end

    local message = "REDSTONE " .. serverName .. " " .. side
    
    message = message .. " " .. index
    
    if bit then
        message = message .. " ON"
    else
        message = message .. " OFF"
    end
    
    print("SEND "..message)
    rednet.send(clientIds[clientNumber], message, protocol)
end
local function sendRedstoneImpulse(clientNumber, side, colorIndex)
    sendRestoneMessage(clientNumber, side, colorIndex, true)
    local resetRedstone = function(clientNumber, side, colorIndex)
        sendRestoneMessage(clientNumber, side, colorIndex, false)
    end
    setzteTimer(0.2, resetRedstone, clientNumber, side, colorIndex)
end

-- Stellbild
local function zeichne(x, y, farbe, text)
    if x == nil then
        print("zeichne: x ist nil "..text)
        return
    end
    if y == nil then
        print("zeichne: y ist nil")
        return
    end
    if farbe == nil then
        print("zeichne: farbe ist nil")
        return
    end
    if text == nil then
        print("zeichne: text ist nil")
        return
    end
    mon.setTextColor(farbe)
    mon.setCursorPos(x, y)
    mon.write(text)
end
local function zeichneItem(position, farbe, text)
    zeichne(position.x, position.y, farbe, text)
end
local function zeichneSignal(signal, symbolL, symbolR)
    local symbol = symbolL
    if signal.richtung == "r" then
        symbol = symbolR
    end
    
    local farbe = colors.red
    if signal.status == SIGNAL_HP then
        farbe = colors.lime
    elseif signal.status == SIGNAL_SH then
        farbe = colors.yellow
    end
    
    zeichneItem(signal, farbe, symbol)
end
local function zeichneGleis(gleis, farbe)
    if gleis.status == 1 then
        farbe = colors.red
    end
    
    if gleis.text then
        zeichneItem(gleis, farbe, gleis.text)
    else
        for j, abschnitt in ipairs(gleis.abschnitte) do
            zeichne(abschnitt.x, abschnitt.y, farbe, abschnitt.text)
        end
    end
end
local function zeichneFSTeile(fs, farbe)
    if fs.status and fs.status > 0 then
        for i, item in ipairs(fs.fsTeile) do
            local fsTeil
            if fahrstrassenteile[item] then
                fsTeil = fahrstrassenteile[item]
                zeichneItem(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/1"] then
                fsTeil = fahrstrassenteile[item.."/1"]
                zeichneItem(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/2"] then
                fsTeil = fahrstrassenteile[item.."/2"]
                zeichneItem(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/3"] then
                fsTeil = fahrstrassenteile[item.."/3"]
                zeichneItem(fsTeil, farbe, fsTeil.text)
            end
        end
    end
end
local function zeichneBahnuebergang(name, bue)
    local farbe = colors.yellow
    if bue.status == 1 then
        farbe = colors.lime
    end
    
    zeichne(bue.x, bue.y, farbe, name)
    for i = 1, bue.hoehe do
        zeichne(bue.x, bue.y + i, farbe, "| |")
    end
end

local function neuzeichnen()
    -- Hintergrundbild
    mon.clear()
    w, h = mon.getSize()
    
    for i, item in pairs(gleisbild) do
        if type(item) == "string" then
            zeichne(1, i, colors.white, item)
        else
            local offset = 1
            for j, teil in ipairs(item) do
                zeichne(offset, i, colors.white, teil)
                offset = offset + string.len(teil)
            end
        end
    end
    
    -- zeichen Fahrstrassenteile
    if debug then
        for i, fsTeil in pairs(fahrstrassenteile) do
            zeichneItem(fsTeil, colors.orange, fsTeil.text)
        end
    end
    
    -- zeichne Signale
    for i, signal in pairs(signale) do
        if signal.hp ~= nil or signal.stelle_hp ~= nil then
            zeichneSignal(signal, "<|", "|>")
        else
            zeichneSignal(signal, "<", ">")
        end
    end
    
    -- zeichne Gleise
    for i, gleis in pairs(gleise) do
        zeichneGleis(gleis, colors.yellow)
    end
    
    -- zeichne Fahrstrassen
    for i, fs in pairs(fahrstrassen) do
        local fsFarbe = colors.lime
        if fs.rangieren then
            fsFarbe = colors.blue
        end
        zeichneFSTeile(fs, fsFarbe)
    end
    
    -- zeichne Bahnuebergaenge
    for name, bue in pairs(bahnuebergaenge) do
        zeichneBahnuebergang(name, bue)
    end
    
    -- Textzeilen
    zeichne(1, h-3, colors.white, "LOE    AUFL   HALT")
    
    zeichne(1, h-2, colors.white, "EIN:")
    if eingabe then
        zeichne(6, h-2, colors.white, eingabeModus.." "..eingabe)
    end
    
    zeichne(1, h-1, colors.white, "VQ:")
    if nachricht then
        zeichne(6, h-1, colors.white, nachricht)
    end
end

-- Callback
local function stelleWeiche(name, abzweigend, keineNachricht)
    local rueckmeldung = ""
    local weiche = weichen[name]
    if weiche == nil then
        rueckmeldung = "stelleWeiche: Weiche "..name.." nicht projektiert"
    else
        sendRestoneMessage(weiche.pc, weiche.au, weiche.fb, abzweigend)
        
        local lage = "gerade"
        if abzweigend then
            lage = "abzweigend"
        end
        rueckmeldung = "Weiche " .. name .. " umgestellt auf " .. lage
    end
    
    if keineNachricht then
        print(rueckmeldung)
    else
        nachricht = rueckmeldung
    end
end
local function aktiviereSignalbild(signal, signalbild, aktiv)
    local cnf = signal["stelle_"..signalbild]
    if cnf ~= nil then
        sendRestoneMessage(cnf.pc, cnf.au, cnf.fb, aktiv)
    end
end
local function stelleSignal(name, signalbild, keineNachricht)
    local rueckmeldung = ""
    local signal = signale[name]
    if signal == nil then
        rueckmeldung = "Signal "..name.." nicht projektiert"
    end
    
    if signal[signalbild] ~= nil then
        sendRedstoneImpulse(signal[signalbild].pc, signal[signalbild].au, signal[signalbild].fb)
    elseif signalbild == SIGNAL_HALT then
        aktiviereSignalbild(signal, SIGNAL_HP, false)
        aktiviereSignalbild(signal, SIGNAL_SH, false)
        aktiviereSignalbild(signal, SIGNAL_ERS, false)
        signale[name].status = signalbild
    else
        signale[name].status = signalbild
        aktiviereSignalbild(signal, signalbild, true)
    end
    
    rueckmeldung = "Signal " .. name .. " auf " .. signalbild .. " gestellt"
    
    if keineNachricht then
        print(rueckmeldung)
    else
        nachricht = rueckmeldung
    end
end

local function kollidierendeFahrstrasse(fs)
    for i, fsTeil in ipairs(fs.fsTeile) do
        print(i.." fsTeil "..fsTeil)
        for fName, andereFs in pairs(fahrstrassen) do
            if andereFs.status ~= nil and andereFs.status > 0 then
                for j, anderesFsTeil in ipairs(andereFs.fsTeile) do
                    print("Vergleiche "..fsTeil.." mit "..anderesFsTeil)
                    if fsTeil == anderesFsTeil then
                        return fName
                    end
                end
            end
        end
    end
    return nil
end
local function stelleFS(name, keineNachricht)
    local rueckmeldung = ""
    local fs = fahrstrassen[name]
    if fs == nil then
        rueckmeldung = "Fahrstrasse "..name.." nicht projektiert"
    elseif fs.steller ~= nil then
        sendRedstoneImpulse(fs.steller.pc, fs.steller.au, fs.steller.fb)
        rueckmeldung = "Fahrstrasse " .. name .. " eingestellt"
    elseif fs.signale ~= nil then
        -- Kollisionserkennung
        local kollision = kollidierendeFahrstrasse(fs)
        if kollision ~= nil then
            nachricht = "FS " .. name .. " nicht einstellbar: Kollidiert mit " .. kollision
            return
        end
        
        fahrstrassen[name].status = 1
        
        if fs.weichen ~= nil then
            for i, weiche in pairs(fs.weichen) do
                stelleWeiche(weiche, true)
            end
        end
        
        fahrstrassen[name].status = 2
        
        -- Gleisbelegung prüfen
        
        fahrstrassen[name].status = 3
        
        for signal, signalbild in pairs(fs.signale) do
            print("stelleSignal "..signal.." "..signalbild)
            stelleSignal(signal, signalbild, false)
        end
        
        rueckmeldung = "Fahrstrasse " .. name .. " eingestellt"
    else
        nachricht = "Fahrstrasse " .. name .. " nicht richtig projektiert (keine Aktion)"
    end
    
    if keineNachricht then
        print(rueckmeldung)
    else
        nachricht = rueckmeldung
    end
end
local function loeseFSauf(name, keineNachricht)
    local rueckmeldung = ""
    local fs = fahrstrassen[name]
    if fs == nil then
        rueckmeldung = "Fahrstrasse "..name.." nicht projektiert"
    elseif fs.aufloeser ~= nil then
        sendRedstoneImpulse(fs.aufloeser.pc, fs.aufloeser.au, fs.aufloeser.fb)
        rueckmeldung = "Fahrstrasse " .. name .. " aufgeloest"
    elseif fs.signale ~= nil then
        for signal, signalbild in pairs(fs.signale) do
            stelleSignal(signal, SIGNAL_HALT, true)
        end
        
        fahrstrassen[name].status = 4
        if fs.weichen ~= nil then
            for i, weiche in pairs(fs.weichen) do
                stelleWeiche(weiche, false)
            end
        end
        fahrstrassen[name].status = 0
    else
        nachricht = "Fahrstrasse " .. name .. " nicht richtig projektiert (keine Aktion)"
    end
    
    if keineNachricht then
        print(rueckmeldung)
    else
        nachricht = rueckmeldung
    end
end

local function puefeElement(x, y, eName, element, groesse)
    if (x >= element.x and x <= element.x + groesse) and y == element.y then
        if eingabe == "" then
            if eingabeModus == "HALT" then
                stelleSignal(eName, SIGNAL_HALT, true)
            else
                eingabe = eName
                return true
            end
        else
            local fsName
            if fahrstrassen[eingabe .. "." .. eName] then
                fsName = eingabe .. "." .. eName
                if eingabeModus == "" then
                    stelleFS(fsName)
                elseif eingabeModus == "AUFL" then
                    loeseFSauf(fsName)
                end
            elseif fahrstrassen[eingabe .. "-" .. eName] then
                fsName = eingabe .. "-" .. eName
                if eingabeModus == "" then
                    stelleFS(fsName)
                elseif eingabeModus == "AUFL" then
                    loeseFSauf(fsName)
                end
            else
                nachricht = "Keine Fahrstrasse von " .. eingabe .. " nach " .. eName .. " gefunden"
            end
        end
        eingabe = ""
        eingabeModus = ""
        return true
    end
    return false
end

local function behandleKlick(x, y)
    nachricht = ""
    if debug then
        print("Klick auf "..x.." "..y)
    end
    
    for name, signal in pairs(signale) do
        if puefeElement(x, y, name, signal, 1) then
            break
        end
    end
    for name, ziel in pairs(fsZiele) do
        if puefeElement(x, y, name, ziel, ziel.laenge) then
            break
        end
    end
    for name, fsTeil in pairs(fahrstrassenteile) do
        local x1 = fsTeil.x
        local x2 = x1 + string.len(fsTeil.text)
        if x >= x1 and x < x2 and y == fsTeil.y then
            eingabe = eingabe .. " " .. name
            break
        end
    end
    
    -- Loeschen
    if (x >= 0 and x <= 3) and y == (h-3) then
        eingabe = ""
        nachricht = ""
        eingabeModus = ""
    end
    
    -- Aktionen
    if (x >= 8 and x <= 11) and y == (h-3) then
        eingabeModus = "AUFL"
    end
    if (x >= 15 and x <= 18) and y == (h-3) then
        if eingabe ~= "" then
            stelleSignal(eingabe, SIGNAL_HALT, true)
            eingabe = ""
            eingabeModus = ""
        else
            eingabeModus = "HALT"
        end
    end
    
    if debug then
        print("EIN: " .. eingabe)
        print("VQ: " .. nachricht)
    end
end

init()

local eventData = {}
local function charPressed()
    local event, character = os.pullEvent("char")
    eventData = {
        event = event,
        char = character
    }
end
local function rednetReceive()
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
local function monitorTouch()
    local event, side, x, y = os.pullEvent("monitor_touch")
    eventData = {
        event = event,
        x = x,
        y = y,
    }
end
local function timerEvent()
    local event, id = os.pullEvent("timer")
    eventData = {
        event = event,
        id = id,
    }
end

repeat
    neuzeichnen()
    
    local eventNumber = parallel.waitForAny(charPressed, rednetReceive, monitorTouch, timerEvent)
    
    if eventNumber == 2 then
        rednetMessageReceived(eventData.id, eventData.msg)
    elseif eventNumber == 3 then
        behandleKlick(eventData.x, eventData.y)
    elseif eventNumber == 4 then
        behandleTimer(eventData.id)
    end
until eventNumber == 1 and eventData.char == "x"

deinit()
