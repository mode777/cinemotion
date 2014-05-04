local system = {}

local layer     = require(ENGINE_PATH.."/layer")
local thread    = require(ENGINE_PATH.."/thread")
local event     = require(ENGINE_PATH.."/event")
local config    = require(ENGINE_PATH.."/config")
local tween     = require(ENGINE_PATH.."/tween")
local geometry  = require(ENGINE_PATH.."/geometry")
local sprite    = require(ENGINE_PATH.."/sprite")
local scene     = require(ENGINE_PATH.."/scene")
local asset     = require(ENGINE_PATH.."/asset")

local oldprint = print
local printstack = {}

function print(...)
    if config.console then
        local args = {...}
        local strg = tostring(args[1])
        table.remove(args, 1)
        local cntr = 1
        for i,v in pairs(args) do
            while i > cntr+1 do
                strg = strg .. ", nil"
                cntr = cntr+1
            end
            strg = strg .. ", " .. tostring(v)
            cntr = cntr+1
        end
        if #printstack > 20 then table.remove(printstack,1) end
        table.insert( printstack, strg )
    end
    oldprint(...)
end

local startScene

function system.reset()
    layer.clearAll()
    thread.clearAll()
    thread.new(function()while true do event.update() thread.yield() end end):run()
end

function system.runScene(file)
    local myScene = scene.new(file)
    myScene:run()
    return myScene
end

function system.setStartScene(name)
    startScene = name
end

local eventQueue = {}

local function load()
    system.reset()
    print(startScene)
    system.runScene(startScene)
end

local function draw()
    --love.graphics.scale(0.75,0.75)
    layer.draw()
    --love.graphics.scale(1,1)
    if config.debug.frames then love.graphics.print(love.timer.getFPS(),10,10) end
    if config.debug.console then
        love.graphics.setColor(255,255,255,128)
        for i, v in ipairs(printstack) do
            love.graphics.print(v, 10, 12 + (12*i))
        end
        love.graphics.setColor(255,255,255,255)
    end
end

local function update(dt)
    tween.update(dt)
    geometry.update()
    thread.update()
    --engine.event.update()
    eventQueue = {}
end

local function keypressed(key, u)
    --if key == "t" then print("Active threads:", engine.thread.active()) end
    if key == "f5" then system.reset() end
    --if key == "l" then print("Current layers:", engine.layer.amount()) end
    if key == "b" then
        if sprite.getShowBounds() then
            sprite.showBounds(false)
        else
            sprite.showBounds(true)
        end
    end
    if key == "a" then
        local assets = asset.getAssets()
        print("List of loaded assets:")
        for name in pairs(assets) do print(name) end
    end
    if key == "f4" and love.keyboard.isDown("lalt") then love.event.quit() end
    eventQueue["keypressed"] = {key,u}
end

local function keyreleased(key,u)
    eventQueue["keyreleased"] = {key,u}
end

local function textinput(t)
    eventQueue["textinput"] = {t}
end

local function mousepressed(x,y,button)
    eventQueue["mousepressed"] = {x,y,button}
end

local function mousereleased(x,y,button)
    eventQueue["mousereleased"] = {x,y,button}
end

local function gamepadaxis(joystick, axis, value)
    eventQueue["gamepadaxis"] = {joystick, axis, value}
end

local function gamepadpressed(joystick, button)
    eventQueue["gamepadpressed"] = {joystick, button}
end

local function gamepadreleased(joystick, button)
    eventQueue["gamepadreleased"] = {joystick, button}
end

local function joystickpressed(joystick, button)
    eventQueue["joystickpressed"] = {joystick, button}
end

local function joystickreleased(joystick, button)
    eventQueue["joystickreleased"] = {joystick, button}
end

local function joystickhat( joystick, hat, direction )
    eventQueue["joystickhat"] = {joystick, hat, direction}
end

local axisbuffer = {}
for _,joystick in ipairs(love.joystick.getJoysticks()) do
    axisbuffer[joystick] = {}
end

local function joystickaxis ( joystick, axis, value )
    eventQueue["joystickaxis"] = { joystick,axis,value }
    if value == 0 then
        if axisbuffer[joystick][axis] then
            axisbuffer[joystick][axis] = nil
            eventQueue["joystickaxisreleased"] = { joystick,axis,value }
        end
    elseif axisbuffer[joystick][axis] then
        return
    else
        eventQueue["joystickaxispressed"] = { joystick,axis,value }
        axisbuffer[joystick][axis] = true
    end
end

function system.registerCallbacks()
    love.load = load
    love.draw = draw
    love.update = update
    love.keypressed = keypressed
    love.keyreleased = keyreleased
    love.textinput = textinput
    love.mousepressed = mousepressed
    love.mousereleased = mousereleased
    love.gamepadaxis = gamepadaxis
    love.gamepadpressed = gamepadpressed
    love.gamepadreleased = gamepadreleased
    love.joystickpressed = joystickpressed
    love.joystickreleased = joystickreleased
    love.joystickhat = joystickhat
    love.joystickaxis = joystickaxis
end

function system.getLoveEvent(Name)
    if eventQueue[Name] then
        return unpack(eventQueue[Name])
    end
end

return system