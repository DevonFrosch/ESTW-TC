local configFile = "config"

-- load configuration
if not fs.exists(configFile) then
    print("Config not found")
    return
end

os.loadAPI(configFile)

if type(config.textFile) ~= "string" then
    print("Config: no textFile")
    return
end
if type(config.monitorSide) ~= "string" then
    print("Config: no monitorSide")
    return
end

-- load text
if not fs.exists(config.textFile) then
    print("Datei "..config.textFile.." nicht gefunden")
    return
end

local mon = peripheral.wrap(config.monitorSide)
mon.clear()
mon.setCursorPos(1,1)
w, h = mon.getSize()

if type(config.textColor) == "number" and config.textColor >= 0 and config.textColor < 16 then
    mon.setTextColor(config.textColor)
end
if type(config.backgroundColor) == "number" and config.backgroundColor >= 0 and config.backgroundColor < 65536 then
    mon.setBackgroundColor(config.backgroundColor)
end
if type(config.scale) == "number" and config.scale >= 0 and config.scale < 16 then
    mon.setTextScale(config.scale)
end

print("Startup, Bildschirm " .. w .. "x" .. h)

local function paintText(x, y, text)
    mon.setCursorPos(x, y)
    mon.write(text)
end

-- background
local emptyLine = ""
for j = 1, w do
    emptyLine = emptyLine .. " "
end

for i = 1, h do
    paintText(1, i, emptyLine)
end

local fileHandle = fs.open(config.textFile, "r")

for i = 1, h do
    local line = fileHandle.readLine()
    if line == nil then
        break
    end
    if #line > w then
        print("Zeile "..i.." zu lang")
    else
        paintText(1, i, line)
    end
end

fileHandle.close()
