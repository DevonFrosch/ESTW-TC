local dateiname = "fahrstrassen.tmp"

local leseFahrstrassen = function()
    if not fs.exists(dateiname) then
        return {}
    end
    local datei = fs.open(dateiname, "r")
    local fsArray = {}
    
    repeat
        local line = datei.readLine()
        if line ~= nil then
            table.insert(fsArray, line)
        end
    until line == nil
    
    datei.close()
    return fsArray
end

local findeFahrstrasse = function(name)
    if not fs.exists(dateiname) then
        return {}
    end
    local datei = fs.open(dateiname, "r")
    
    repeat
        local line = datei.readLine()
        if line == name then
            datei.close()
            return true
        end
    until line == nil
    
    datei.close()
    return false
end

local speichereFahrstrasse = function(name)
    if findeFahrstrasse(name) then
        return
    end

    local datei = fs.open(dateiname, "a")
    datei.writeLine(name)
    datei.close()
end

local loescheFahrstrasse = function(name)
    local fahrstrassen = leseFahrstrassen()
    local datei = fs.open(dateiname, "w")
    for i, fahrstrasse in ipairs(fahrstrassen) do
        if fahrstrasse ~= name then
            datei.writeLine(fahrstrasse)
        end
    end
    datei.close()
end

local leereDatei = function()
    local datei = fs.open(dateiname, "w")
    datei.write("")
    datei.close()
end

return {
    leseFahrstrassen = leseFahrstrassen,
    findeFahrstrasse = findeFahrstrasse,
    speichereFahrstrasse = speichereFahrstrasse,
    loescheFahrstrasse = loescheFahrstrasse,
    leereDatei = leereDatei,
}
