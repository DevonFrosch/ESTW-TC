function loadAPI(filename, folder)
    local fileExists = function(path)
        local f = io.open(path, "r")
        if f == nil then
            return false
        end
        f.close(f)
        return true
    end
    
    if filename:sub(-4) == ".lua" then
        filename = filename:sub(1,-5)
    end
    if folder == nil then
        folder = ""
    elseif folder:sub(-1) ~= "/" then
        folder = folder .. "/"
    end
    
    if os.loadAPI ~= nil then
        -- ComputerCraft
        local path = folder..filename..".lua"
        if fileExists(folder.."cc/"..filename..".lua") then
            path = folder.."cc/"..filename..".lua"
        end
        local file, err = loadfile(path)
        if file == nil then
            print("Failed loading api "..folder..filename.."!")
            return nil
        end
        return file()
    else
        -- OpenComputers
        local path = folder..filename
        if fileExists(folder.."oc/"..filename..".lua") then
            path = folder.."oc/"..filename
        end
        local result = require(path)
        if result == nil then
            print("Failed loading api "..folder..filename.."!")
            return nil
        end
        return result
    end
end

local tools = loadAPI("tools", "bin")
local log = loadAPI("log", "bin")
log.start("client", "log", log.LEVEL_DEBUG)

local kommunikation = loadAPI("kommunikation", "bin")
local events = loadAPI("events", "bin")

-- load configuration
local config = loadAPI("config")

-- test config
local configTests = {
    modem = type(config.modem) == "string",
    stellwerkName = type(config.stellwerkName) == "string",
    role = type(config.role) == "string",
    sides = type(config.sides) == "table",
    ["sides.left"]   = config.sides and (config.sides.left   == nil or config.sides.left   == true),
    ["sides.right"]  = config.sides and (config.sides.right  == nil or config.sides.right  == true),
    ["sides.top"]    = config.sides and (config.sides.top    == nil or config.sides.top    == true),
    ["sides.bottom"] = config.sides and (config.sides.bottom == nil or config.sides.bottom == true),
    ["sides.front"]  = config.sides and (config.sides.front  == nil or config.sides.front  == true),
    ["sides.back"]   = config.sides and (config.sides.back   == nil or config.sides.back   == true),
}

for name, test in pairs(configTests) do
    if not test then
        log.error("Config fuer "..name.." falsch formatiert")
        return
    end
end

log.info("Starte client, Rolle "..config.role)

local redstoneStates = {}

redstoneHasChanged = function()
    for side, use in pairs(config.sides) do
        local newState = redstone.getBundledInput(side)
        local oldState = (redstoneStates[side] or 0)
        
        if newState ~= oldState then
            for i = 0, 15 do
                local index = (2 ^ i)
                local oldBit = bit.band(index, oldState)
                local newBit = bit.band(index, newState)
                if newBit ~= oldBit then
                    log.debug("Redstone geaendert: ", {side = side, index = index, newBit = newBit})
                    kommunikation.sendRedstoneChangeClient(side, index, newBit)
                end
            end
            redstoneStates[side] = newState
        end
    end
end

function onRegister()
    redstoneStates = {}
    redstoneHasChanged()
end

function onChange(side, color, state)
    if not config.sides[side] then
        log.warn("onChange: Seite "..side.." nicht verbunden")
        return
    end
    if state == "ON" then
        local newColors = colors.combine(redstone.getBundledOutput(side), color)
        redstone.setBundledOutput(side, newColors)
    else
        local newColors = colors.subtract(redstone.getBundledOutput(side), color)
        redstone.setBundledOutput(side, newColors)
    end
end

local protocol = "ESTW " .. config.stellwerkName

local serverGefunden = kommunikation.init(protocol, config.modem, tostring(config.role), log)

if serverGefunden then
    redstoneHasChanged()
end

events.listen({
    onRednetReceive = function(eventData)
        kommunikation.rednetMessageReceivedClient(eventData.id, eventData.msg, onRegister, onChange, log)
    end,
    onRedstoneChange = function(eventData)
        redstoneHasChanged()
    end,
    onCharEvent = function(eventData)
        if eventData.char == "i" then
            log.info("Status:")
            log.info("  Role: "..config.role)
            log.info("  Server: "..kommunikation.getServerId())
            log.info("  RedstoneState: "..(#redstoneStates).." Einträge", redstoneStates)
            log.info("----")
        end
    end,
    onTimerEvent = function(eventData)
        kommunikation.behandleTimer(eventData.id)
    end,
})

kommunikation.deinit()
