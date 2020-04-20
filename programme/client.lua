os.loadAPI("bin/tools")

local debug = false
local kommunikation = tools.loadAPI("kommunikation.lua", "bin")
local events = tools.loadAPI("events.lua", "bin")

-- load configuration
local config = tools.loadAPI("config.lua")

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
        print("Config fuer "..name.." falsch formatiert")
        return
    end
end

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
                if debug then
                    print("index="..index..",oldBit="..oldBit..",newBit="..newBit)
                end
                if newBit ~= oldBit then
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
        print("onChange: Seite "..side.." nicht verbunden")
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

local serverGefunden = kommunikation.init(protocol, config.modem, tostring(config.role), debug)

if serverGefunden then
    redstoneHasChanged()
end

events.listen({
    onRednetReceive = function(eventData)
        kommunikation.rednetMessageReceivedClient(eventData.id, eventData.msg, onRegister, onChange, debug)
    end,
    onRedstoneChange = function(eventData)
        redstoneHasChanged()
    end,
})

kommunikation.deinit()
