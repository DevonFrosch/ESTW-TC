local monitor = nil

local function init(seite)
    monitor = peripheral.wrap(seite)
    monitor.clear()
    monitor.setCursorPos(1,1)
end

local function hoehe()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    local w, h = monitor.getSize()
    return h
end
local function breite()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    local w, h = monitor.getSize()
    return w
end

local function leeren()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    monitor.clear()
end

local function zeichne(x, y, farbe, text)
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
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
    monitor.setTextColor(farbe)
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

local function zeichneElement(position, farbe, text, offsetX, offsetY)
    if offsetX == nil then
        offsetX = 0
    end
    if offsetY == nil then
        offsetY = 0
    end
    zeichne(position.x + offsetX, position.y + offsetY, farbe, text)
end

return {
    init = init,
    hoehe = hoehe,
    breite = breite,
    leeren = leeren,
    zeichne = zeichne,
    zeichneElement = zeichneElement,
}
