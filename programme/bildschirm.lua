local monitor = nil

init = function(seite)
    monitor = peripheral.wrap(seite)
    monitor.clear()
    monitor.setCursorPos(1,1)
end

hoehe = function()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    local w, h = monitor.getSize()
    return h
end
breite = function()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    local w, h = monitor.getSize()
    return w
end

leeren = function()
    if monitor == nil then
        print("Monitor ist nicht initialisiert")
        return
    end
    monitor.clear()
end

zeichne = function(x, y, farbe, text)
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

zeichneElement = function(position, farbe, text)
    zeichne(position.x, position.y, farbe, text)
end
