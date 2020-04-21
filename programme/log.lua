local path = nil
local loglevel = LEVEL_NONE
local maxRotate = 10

LEVEL_NONE = 0
LEVEL_ERROR = 1
LEVEL_WARN = 2
LEVEL_INFO = 3
LEVEL_DEBUG = 4

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

local function getPfad(logName, ordner, index)
    local pfad = logName
    
    if index ~= nil then
        pfad = pfad .. "." .. index
    end
    
    pfad = pfad .. ".log"
    
    if ordner ~= nil then
        pfad = ordner .. "/" .. pfad
    end
    return pfad
end
local function rotate(logName, ordner, index)
    local pfadAlt = getPfad(logName, ordner, index)
    if not fs.exists(pfadAlt) then
        return pfadAlt
    end
    if index == nil then
        index = 0
    end
    if index >= maxRotate - 1 then
        fs.delete(pfadAlt)
        return pfadAlt
    end
    
    local pfadNeu = rotate(logName, ordner, index + 1)
    fs.move(pfadAlt, pfadNeu)
    
    return pfadAlt
end
local function schreibe(level, text, objects)
    if loglevel < level then
        return
    end
    if level <= LEVEL_INFO then
        local printText = text
        printText = printText:gsub("ä", "ae")
        printText = printText:gsub("ö", "oe")
        printText = printText:gsub("ü", "ue")
        printText = printText:gsub("Ä", "Ae")
        printText = printText:gsub("Ö", "Oe")
        printText = printText:gsub("Ü", "Ue")
        printText = printText:gsub("ß", "ss")
        print(printText)
    end
    if path == nil then
        return
    end
    
    local timeStamp = "[" .. os.day() .. " " .. os.time() .. "] "
    local levelTransl = {
        [LEVEL_ERROR] = "FEHLER: ",
        [LEVEL_WARN] = "WARNUNG: ",
        [LEVEL_INFO] = "INFO: ",
        [LEVEL_DEBUG] = "DEBUG: ",
    }
    
    local datei = fs.open(path, "a")
    datei.writeLine(timeStamp .. (levelTransl[level] or "") .. text)
    
    if objects ~= nil then
        for i, object in ipairs(objects) do
            datei.writeLine(dump(object))
        end
    end
    
    datei.close()
end

start = function(logName, ordner, level)
    if ordner ~= nil and not fs.isDir(ordner) then
        fs.makeDir(ordner)
    end
    
    path = rotate(logName, ordner, nil)
    loglevel = (level or "info")
end

error = function(text, ...)
    schreibe(LEVEL_ERROR, tostring(text), arg)
end
warn = function(text, ...)
    schreibe(LEVEL_WARN, tostring(text), arg)
end
info = function(text, ...)
    schreibe(LEVEL_INFO, tostring(text), arg)
end
debug = function(text, ...)
    schreibe(LEVEL_DEBUG, tostring(text), arg)
end
