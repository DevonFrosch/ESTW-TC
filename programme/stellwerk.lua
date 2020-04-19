os.loadAPI("tools")

local debug = false
local kommunikation = tools.loadAPI("kommunikation.lua")
local bildschirm = tools.loadAPI("bildschirm.lua")
local events = tools.loadAPI("events.lua")
local stellwerkDatei = tools.loadAPI("stellwerk.datei.lua")

-- load configuration
local config = tools.loadAPI("config.lua")

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

local protocolVersion = "STW v1"
local protocol = protocolVersion .. " " .. config.stellwerkName
local serverName = "Server"

local SIGNAL_HALT = "halt"
local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"

bildschirm.init(config.bildschirm)
local hoehe = bildschirm.hoehe()

local fileHandle = fs.open(config.gleisbildDatei, "r")

local gleisbild = {}
for i = 1, hoehe do
    local line = fileHandle.readLine()
    if line == nil then
        break
    end
    gleisbild[i] = line
end

fileHandle.close()

print("Startup, Bildschirm " .. bildschirm.breite() .. "x" .. hoehe)

-- Stellbild
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
    
    bildschirm.zeichneElement(signal, farbe, symbol)
end
local function zeichneGleis(gleis, farbe)
    if gleis.status == 1 then
        farbe = colors.red
    end
    
    if gleis.text then
        bildschirm.zeichneElement(gleis, farbe, gleis.text)
    else
        for j, abschnitt in ipairs(gleis.abschnitte) do
            bildschirm.zeichne(abschnitt.x, abschnitt.y, farbe, abschnitt.text)
        end
    end
end
local function zeichneFSTeile(fahrstr, farbe)
    if fahrstr.status and fahrstr.status > 0 then
        for i, item in ipairs(fahrstr.fsTeile) do
            local fsTeil
            if fahrstrassenteile[item] then
                fsTeil = fahrstrassenteile[item]
                bildschirm.zeichneElement(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/1"] then
                fsTeil = fahrstrassenteile[item.."/1"]
                bildschirm.zeichneElement(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/2"] then
                fsTeil = fahrstrassenteile[item.."/2"]
                bildschirm.zeichneElement(fsTeil, farbe, fsTeil.text)
            end
            if fahrstrassenteile[item.."/3"] then
                fsTeil = fahrstrassenteile[item.."/3"]
                bildschirm.zeichneElement(fsTeil, farbe, fsTeil.text)
            end
        end
    end
end
local function zeichneBahnuebergang(name, bue)
    local farbe = colors.yellow
    if bue.status == 1 then
        farbe = colors.lime
    end
    
    bildschirm.zeichne(bue.x, bue.y, farbe, name)
    for i = 1, bue.hoehe do
        bildschirm.zeichne(bue.x, bue.y + i, farbe, "| |")
    end
end

local function neuzeichnen()
    -- Hintergrundbild
    bildschirm.leeren()
    local hoehe = bildschirm.hoehe()
    
    for i, item in pairs(gleisbild) do
        if type(item) == "string" then
            bildschirm.zeichne(1, i, colors.white, item)
        else
            local offset = 1
            for j, teil in ipairs(item) do
                bildschirm.zeichne(offset, i, colors.white, teil)
                offset = offset + string.len(teil)
            end
        end
    end
    
    -- zeichen Fahrstrassenteile
    if debug then
        for i, fsTeil in pairs(fahrstrassenteile) do
            bildschirm.zeichneElement(fsTeil, colors.orange, fsTeil.text)
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
    for i, fahrstr in pairs(fahrstrassen) do
        local fsFarbe = colors.lime
        if fahrstr.rangieren then
            fsFarbe = colors.blue
        end
        zeichneFSTeile(fahrstr, fsFarbe)
    end
    
    -- zeichne Bahnuebergaenge
    for name, bue in pairs(bahnuebergaenge) do
        zeichneBahnuebergang(name, bue)
    end
    
    -- Textzeilen
    bildschirm.zeichne(1, hoehe-3, colors.white, "LOE    AUFL   HALT")
    
    bildschirm.zeichne(1, hoehe-2, colors.white, "EIN:")
    if eingabe then
        bildschirm.zeichne(6, hoehe-2, colors.white, eingabeModus.." "..eingabe)
    end
    
    bildschirm.zeichne(1, hoehe-1, colors.white, "VQ:")
    if nachricht then
        bildschirm.zeichne(6, hoehe-1, colors.white, nachricht)
    end
end

-- Callback
local function fehler(text)
    nachricht = text
    print(text)
end
local function erfolg(mitNachricht, text)
    if mitNachricht then
        nachricht = text
    end
    if debug then
        print(text)
    end
end

local function stelleWeiche(name, abzweigend, mitNachricht)
    local weiche = weichen[name]
    if weiche == nil then
        return fehler("stelleWeiche: Weiche "..name.." nicht projektiert")
    end
    
    kommunikation.sendRestoneMessage(weiche.pc, weiche.au, weiche.fb, abzweigend, debug)
    
    local lage = "gerade"
    if abzweigend then
        lage = "abzweigend"
    end
    
    erfolg(mitNachricht, "Weiche " .. name .. " umgestellt auf " .. lage)
end
local function aktiviereSignalbild(signal, signalbild, aktiv)
    local cnf = signal["stelle_"..signalbild]
    if cnf ~= nil then
        kommunikation.sendRestoneMessage(cnf.pc, cnf.au, cnf.fb, aktiv, debug)
    end
end
local function stelleSignal(name, signalbild, mitNachricht)
    local signal = signale[name]
    if signal == nil then
        return fehler("Signal "..name.." nicht projektiert")
    end
    
    kommunikation.sendRedstoneImpulse("signale", "top", 1, debug)
    
    if signal[signalbild] ~= nil then
        kommunikation.sendRedstoneImpulse(signal[signalbild].pc, signal[signalbild].au, signal[signalbild].fb, debug)
    elseif signalbild == SIGNAL_HALT then
        aktiviereSignalbild(signal, SIGNAL_HP, false)
        aktiviereSignalbild(signal, SIGNAL_SH, false)
        aktiviereSignalbild(signal, SIGNAL_ERS, false)
        signale[name].status = signalbild
    else
        signale[name].status = signalbild
        aktiviereSignalbild(signal, signalbild, true)
    end
    
    erfolg(mitNachricht, "Signal " .. name .. " auf " .. signalbild .. " gestellt")
end

local function kollidierendeFahrstrasse(fahrstr)
    for i, fsTeil in ipairs(fahrstr.fsTeile) do
        for fName, andereFs in pairs(fahrstrassen) do
            if andereFs.status ~= nil and andereFs.status > 0 then
                for j, anderesFsTeil in ipairs(andereFs.fsTeile) do
                    if fsTeil == anderesFsTeil then
                        return fName
                    end
                end
            end
        end
    end
    return nil
end
local function stelleFahrstrasse(name, mitNachricht, istReset)
    local rueckmeldung = ""
    local fahrstr = fahrstrassen[name]
    if fahrstr == nil then
        return fehler("Fahrstrasse "..name.." nicht projektiert")
    end
    
    if fahrstr.steller ~= nil then
        kommunikation.sendRedstoneImpulse(fahrstr.steller.pc, fahrstr.steller.au, fahrstr.steller.fb, debug)
    elseif fahrstr.signale ~= nil then
        -- Kollisionserkennung
        local kollision = kollidierendeFahrstrasse(fahrstr)
        if kollision ~= nil then
            return fehler("FS " .. name .. " nicht einstellbar: Kollidiert mit " .. kollision)
        end
        
        fahrstrassen[name].status = 1
        
        if fahrstr.weichen ~= nil then
            for i, weiche in pairs(fahrstr.weichen) do
                stelleWeiche(weiche, true)
            end
        end
        
        fahrstrassen[name].status = 2
        
        -- Gleisbelegung prüfen
        
        if not istReset then
            stellwerkDatei.speichereFahrstrasse(name)
        end
        
        fahrstrassen[name].status = 3
        
        for signal, signalbild in pairs(fahrstr.signale) do
            stelleSignal(signal, signalbild)
        end
        
    else
        return fehler("Fahrstrasse " .. name .. " nicht richtig projektiert (keine Aktion)")
    end
    
    erfolg(mitNachricht, "Fahrstrasse " .. name .. " eingestellt")
end
local function loeseFSauf(name, mitNachricht)
    local rueckmeldung = ""
    local fahrstr = fahrstrassen[name]
    if fahrstr == nil then
        return fehler("Fahrstrasse "..name.." nicht projektiert")
    end
    
    if fahrstr.aufloeser ~= nil then
        kommunikation.sendRedstoneImpulse(fahrstr.aufloeser.pc, fahrstr.aufloeser.au, fahrstr.aufloeser.fb, debug)
    elseif fahrstr.signale ~= nil then
        for signal, signalbild in pairs(fahrstr.signale) do
            stelleSignal(signal, SIGNAL_HALT)
        end
        
        fahrstrassen[name].status = 4
        
        stellwerkDatei.loescheFahrstrasse(name)
        
        if fahrstr.weichen ~= nil then
            for i, weiche in pairs(fahrstr.weichen) do
                stelleWeiche(weiche, false)
            end
        end
        
        fahrstrassen[name].status = 0
    else
       return fehler("Fahrstrasse " .. name .. " nicht richtig projektiert (keine Aktion)")
    end
    
    erfolg(mitNachricht, "Fahrstrasse " .. name .. " aufgeloest")
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
                    stelleFahrstrasse(fsName, true)
                elseif eingabeModus == "AUFL" then
                    loeseFSauf(fsName, true)
                end
            elseif fahrstrassen[eingabe .. "-" .. eName] then
                fsName = eingabe .. "-" .. eName
                if eingabeModus == "" then
                    stelleFahrstrasse(fsName, true)
                elseif eingabeModus == "AUFL" then
                    loeseFSauf(fsName, true)
                end
            else
                fehler("Keine Fahrstrasse von " .. eingabe .. " nach " .. eName .. " gefunden")
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
    
    local hoehe = bildschirm.hoehe()
    
    -- Loeschen
    if (x >= 0 and x <= 3) and y == (hoehe-3) then
        eingabe = ""
        nachricht = ""
        eingabeModus = ""
    end
    
    -- Aktionen
    if (x >= 8 and x <= 11) and y == (hoehe-3) then
        eingabeModus = "AUFL"
    end
    if (x >= 15 and x <= 18) and y == (hoehe-3) then
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

-- setzt alle Ausgänge zurück
local function reset()
    for name, signal in pairs(signale) do
        stelleSignal(name, SIGNAL_HALT)
    end
    
    for name, weiche in pairs(weichen) do
        stelleWeiche(name, false)
    end
    
    local fahrstrassen = stellwerkDatei.leseFahrstrassen()
    for i, fahrstrasse in ipairs(fahrstrassen) do
        stelleFahrstrasse(fahrstrasse, false, true)
    end
end

kommunikation.init(protocol, config.modem, serverName)

-- Kommunikation
local function onRedstoneChange(pc, side, color, state)
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

neuzeichnen()

kommunikation.setzteTimer(1, reset)

events.listen(
    nil,
    function()
        neuzeichnen()
    end,
    nil,
    function(eventData)
        kommunikation.rednetMessageReceived(eventData.id, eventData.msg, onRedstoneChange, debug)
    end,
    function(eventData)
        behandleKlick(eventData.x, eventData.y)
    end,
    function(eventData)
        kommunikation.behandleTimer(eventData.id)
    end
)

kommunikation.deinit()
