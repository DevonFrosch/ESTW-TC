local local_path = nil
local local_logName = nil
local local_folder = nil
local loglevel = LEVEL_NONE
local maxRotate = 10

LEVEL_NONE = 0
LEVEL_ERROR = 1
LEVEL_WARN = 2
LEVEL_INFO = 3
LEVEL_DEBUG = 4

local levelTransl = {
    [LEVEL_ERROR] = "FEHLER: ",
    [LEVEL_WARN] = "WARNUNG: ",
    [LEVEL_INFO] = "INFO: ",
    [LEVEL_DEBUG] = "DEBUG: ",
}

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

local function getPath(logName, folder, index)
    local pfad = logName
    
    if index ~= nil then
        pfad = pfad .. "." .. index
    end
    
    pfad = pfad .. ".log"
    
    if folder ~= nil then
        pfad = folder .. "/" .. pfad
    end
    return pfad
end

local function rotate(logName, folder, index)
    local pfadAlt = getPath(logName, folder, index)
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
    
    local pfadNeu = rotate(logName, folder, index + 1)
    fs.move(pfadAlt, pfadNeu)
    
    return pfadAlt
end

local function initFile(logName, folder)
    if logName ~= nil then
        local_logName = logName
    end
    if folder ~= nil then
        local_folder = folder
    end
    if local_folder ~= nil and not fs.isDir(local_folder) then
        fs.makeDir(local_folder)
    end
    
    local_path = rotate(local_logName, local_folder)
end

local function writeLog(level, text, objects)
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
    if local_path == nil then
        print("log.lua: Path not set, did you forget start()?")
        return
    end
    
    local timeStamp = "[" .. os.day() .. " " .. os.time() .. "] "
    local translLevel = levelTransl[level] or ""
    local line = timeStamp .. translLevel .. text
    
    if not fs.exists(local_path) 
        -- reinit if file was moved/deleted/etc
        init()
    end
    
    local datei = fs.open(local_path, "a")
    if datei == nil then
        print("log.lua: Cannot open file "..local_path)
        return
    end
    
    datei.writeLine(line)
    
    if objects ~= nil then
        for i, object in ipairs(objects) do
            datei.writeLine(dump(object))
        end
    end
    
    datei.close()
end

start = function(logName, folder, level)
    if folder ~= nil and not fs.isDir(folder) then
        fs.makeDir(folder)
    end
    
    local_path = rotate(logName, folder, nil)
    loglevel = (level or "info")
end

error = function(text, ...)
    writeLog(LEVEL_ERROR, tostring(text), arg)
end
warn = function(text, ...)
    writeLog(LEVEL_WARN, tostring(text), arg)
end
info = function(text, ...)
    writeLog(LEVEL_INFO, tostring(text), arg)
end
debug = function(text, ...)
    writeLog(LEVEL_DEBUG, tostring(text), arg)
end
