local input = {}
local mapping = {}
local system = require(ENGINE_PATH.."/system")


function input.getCurrentInput()
    if system.getLoveEvent("joystickpressed") then
        local joystick, button = system.getLoveEvent("joystickpressed")
        return "joystick", joystick:getID(), "button", button
    end
    if system.getLoveEvent("joystickhat") then
        local joystick, hat, dir = system.getLoveEvent("joystickhat")
        if dir ~= "c" then return "joystick", joystick:getID(), "hat", hat, dir end
    end
    if system.getLoveEvent("joystickaxispressed") then
        local joystick, axis, value = system.getLoveEvent("joystickaxis")
        if axis ~= 0 then return "joystick", joystick:getID(), "axis", axis, value>0 and "+" or "-" end
    end
    if system.getLoveEvent("keypressed") then
        return "keyboard", system.getLoveEvent("keypressed")
    end
    if system.getLoveEvent("mousepressed") then
        local _, _, button = system.getLoveEvent("mousepressed")
        return "mouse", button
    end
end

function input.isDown(Type,...)
    local data = {...}
    if Type == "keyboard" then
        local key = data[1]
        return love.keyboard.isDown(key)
elseif Type == "mouse" then
        local but = data[1]
        return love.mouse.isDown(but)
elseif Type == "joystick" then
        local joysticks = love.joystick.getJoysticks( )
        local joyID, type = data[1], data[2]
        if type == "button" then
            local button = data[3]
            if joysticks[joyID] then return joysticks[joyID]:isDown(button-1) end
        elseif type == "hat" then
            local hatID, dir = data[3], data[4]
            if joysticks[joyID] then return joysticks[joyID]:getHat(hatID) == dir end
        elseif type == "axis" then
            local axisID, dir = data[3], data[4]
            if joysticks[joyID] then
                if not dir then
                    return joysticks[joyID]:getAxis(axisID) ~= 0
                else
                    if dir == "+" then return joysticks[joyID]:getAxis(axisID) > 0
                    elseif dir == "-" then return joysticks[joyID]:getAxis(axisID) < 0
                    end
                end
            end
        end
    end
end

function input.getValue(Type,...)
    local data = {...}
    if Type == "keyboard" then
        local key = data[1]
        return love.keyboard.isDown(key) and 1 or 0
    elseif Type == "mouse" then
        local but = data[1]
        return love.mouse.isDown(but) and 1 or 0
    elseif Type == "joystick" then
        local joysticks = love.joystick.getJoysticks( )
        local joyID, type = data[1], data[2]
        if type == "button" then
            local button = data[3]
            if joysticks[joyID] then return joysticks[joyID]:isDown(button-1) and 1 or 0 end
        elseif type == "hat" then
            local hatID, dir = data[3], data[4]
            if joysticks[joyID] then
                return joysticks[joyID]:getHat(hatID) == dir and 1 or 0
            end
        elseif type == "axis" then
            local axisID, dir = data[3], data[4]
            if joysticks[joyID] then
                if dir == "+" then return joysticks[joyID]:getAxis(axisID) > 0 and joysticks[joyID]:getAxis(axisID) or 0
                elseif dir == "-" then return joysticks[joyID]:getAxis(axisID) < 0 and -joysticks[joyID]:getAxis(axisID) or 0
                end
            end
        end
    end
    return 0
end

function input.isPressed(Type,...)
    local data = {...}
    if Type == "keyboard" then
        local key = data[1]
        local ckey = system.getLoveEvent("keypressed")
        return key == ckey
    elseif Type == "mouse" then
        local but = data[1]
        local _,_,cbut = system.getLoveEvent("mousepressed")
        return but == cbut
    elseif Type == "joystick" then
        local joysticks = love.joystick.getJoysticks( )
        local joyID, type = data[1], data[2]
        if type == "button" then
            local button = data[3]
            local cjoy, cbut = system.getLoveEvent("joystickpressed")
            if joysticks[joyID] then
                return joysticks[joyID] == cjoy and button == cbut
            end
        elseif type == "hat" then
            local hatID, dir = data[3], data[4]
            local cjoy, chat, cdir = system.getLoveEvent("joystickhat")
            if joysticks[joyID] then return joysticks[joyID] == cjoy and hatID == chat and cdir == dir end
        elseif type == "axis" then
            local axisID, dir = data[3], data[4]
            local cjoy, caxis, cval = system.getLoveEvent("joystickaxispressed")
            if joysticks[joyID] then
                if dir == "+" then return joysticks[joyID] == cjoy and caxis == axisID and cval > 0
            elseif dir == "-" then return joysticks[joyID] == cjoy and caxis == axisID and cval < 0
            end
            end
        end
    end
end


function input.isReleased(Type,...)
    local data = {...}
    if Type == "keyboard" then
        local key = data[1]
        local ckey = system.getLoveEvent("keyreleased")
        return key == ckey
    elseif Type == "mouse" then
        local but = data[1]
        local _,_,cbut = system.getLoveEvent("mousereleased")
        return but == cbut
    elseif Type == "joystick" then
        local joysticks = love.joystick.getJoysticks( )
        local joyID, type = data[1], data[2]
        if type == "button" then
            local button = data[3]
            local cjoy, cbut = system.getLoveEvent("joystickreleased")
            if joysticks[joyID] then
                return joysticks[joyID] == cjoy and button == cbut
            end
        elseif type == "hat" then
            --todo: implement hat release
        elseif type == "axis" then
            local axisID, dir = data[3], data[4]
            local cjoy, caxis, cval = system.getLoveEvent("joystickaxisreleased")
            if joysticks[joyID] then
                if dir == "+" then return joysticks[joyID] == cjoy and caxis == axisID
                elseif dir == "-" then return joysticks[joyID] == cjoy and caxis == axisID
                end
            end
        end
    end
end

function input.getVirtualInput(Name)
    return input.newVirtualInput(Name)
end

function input.setMappingTable(t)
    mapping = t
end

function input.getMappingTable()
    return mapping
end

function input.newVirtualInput(Name)
    local i = {}
    function i:map(...)
        table.insert(mapping[Name],{...})
        return #mapping[Name]
    end
    function i:clearMapping(id)
        if not id then
            mapping[Name] = {}
        else
            table.remove(mapping[Name],id)
        end
    end
    function i:isDown()
        for i=1, #mapping[Name] do
            if input.isDown(unpack(mapping[Name][i])) then return true end
        end
    end
    function i:getValue()
        local returnValue
        for i=1, #mapping[Name] do
           returnValue = input.getValue(unpack(mapping[Name][i])) ~= 0 and input.getValue(unpack(mapping[Name][i])) or returnValue
        end
        return returnValue and returnValue or 0
    end
    function i:isPressed()
        for i=1, #mapping[Name] do
            if input.isPressed(unpack(mapping[Name][i])) then return true end
        end
    end
    function i:isReleased()
        for i=1, #mapping[Name] do
            if input.isReleased(unpack(mapping[Name][i])) then return true end
        end
    end
    if not mapping[Name] then mapping[Name] = {} end
    return i
end

return input