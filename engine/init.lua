ENGINE_PATH = ENGINE_PATH or "engine"

local engine = {}

engine.showConsole = false
engine.showFrames = false

local oldprint = print
local printstack = {}
local eventQueue = {}

function print(...)
    if engine.showConsole then
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

engine.thread = require(ENGINE_PATH.."/thread")
engine.serialize = require(ENGINE_PATH.."/serialize")
engine.layer = require(ENGINE_PATH.."/layer")
engine.sourceImage = require(ENGINE_PATH.."/sourceImage")
engine.sourceTileset = require(ENGINE_PATH.."/sourceTileset")
engine.sourceSpritesheet = require(ENGINE_PATH.."/sourceSpritesheet")
engine.sourcePolyline = require(ENGINE_PATH.."/sourcePolyline")
engine.sourceFont = require(ENGINE_PATH.."/sourceFont")
engine.sourceRectangle = require(ENGINE_PATH.."/sourceRectangle")
engine.sourceCircle = require(ENGINE_PATH.."/sourceCircle")
engine.spriteSheet = require(ENGINE_PATH.."/spriteSheet")
engine.animationSheet = require(ENGINE_PATH.."/animationSheet")
engine.grid = require(ENGINE_PATH.."/grid")
engine.asset = require(ENGINE_PATH.."/asset")
engine.camera = require(ENGINE_PATH.."/camera")
engine.sprite = require(ENGINE_PATH.."/sprite")
engine.geometry = require(ENGINE_PATH.."/geometry")
engine.group = require(ENGINE_PATH.."/group")
engine.menu = require(ENGINE_PATH.."/menu")
engine.textinput = require(ENGINE_PATH.."/textinput")
engine.scene = require(ENGINE_PATH.."/scene")
engine.event = require(ENGINE_PATH.."/event")
engine.tween = require(ENGINE_PATH.."/tween")
engine.data = require(ENGINE_PATH.."/data")

local mouseover = {}
setmetatable(mouseover, {__mode = "k"})

function engine.reset()
    engine.layer.clearAll()
    engine.thread.clearAll()
    local scene = engine.scene.new(engine.config.startScene)
    scene:run()
end

local function load()
    local cfg = {
		startScene = "resample.sce",
		--startScene = "newMenu.sce",
		--startScene = "examples/spotlight/spotlight.sce",
		debug = {console=true, lines=false, frames=true },
		fullscreen = false,
		--resolution = {x=1280,y=720}
		resolution = {x=800,y=600}
    }
    --engine.serialize.save(cfg,"engine.cfg")
    if love.keyboard.isDown("f8") then
        engine.config = cfg
    else
        engine.config = cfg--engine.serialize.load("engine.cfg")
    end
    engine.config.resolution = engine.config.resolution or {x=640,y=480}
    love.window.setMode(engine.config.resolution.x,engine.config.resolution.y, {fullscreen = engine.config.fullscreen, vsync=false, resizable=true})
    engine.showConsole = engine.config.debug.console
    engine.sprite.showBounds(engine.config.debug.lines)
    engine.reset()
    local eventThread = engine.thread.new(function() while true do engine.event.update() engine.thread.yield() end end)
    eventThread:run()
end

local function draw()
    --love.graphics.scale(0.75,0.75)
    engine.layer.draw()
    --love.graphics.scale(1,1)
    if engine.config.debug.frames then love.graphics.print(love.timer.getFPS(),10,10) end
    if engine.showConsole then
        love.graphics.setColor(255,255,255,128)
        for i, v in ipairs(printstack) do
            love.graphics.print(v, 10, 12 + (12*i))
        end
        love.graphics.setColor(255,255,255,255)
    end
end

local function update(dt)
    engine.tween.update(dt)
    engine.geometry.update()
    engine.thread.update()
    --engine.event.update()
    eventQueue = {}
end

local function keypressed(key, u)
    if key == "t" then print("Active threads:", engine.thread.active()) end
    if key == "f5" then engine.reset() end
    if key == "l" then print("Current layers:", engine.layer.amount()) end
    if key == "b" then
        if engine.sprite.getShowBounds() then
            engine.sprite.showBounds(false)
        else
            engine.sprite.showBounds(true)
        end
    end
    if key == "a" then
        local assets = engine.asset.getAssets()
        print("List of loaded assets:")
        for name in pairs(assets) do print(name) end
    end
    if not engine.textinput.isFinished() then
        if key == "right" then engine.textinput.moveIndex(key) end
        if key == "left" then engine.textinput.moveIndex(key) end
        if key == "backspace" then engine.textinput.delete() end
        if key == "return" then engine.textinput.finish() end
    end
end

local function textinput(t)
    if not engine.textinput.isFinished() then
        engine.textinput.insert(t)
    end
end

local function mousereleased(x,y,button)
    eventQueue["mousereleased"] = {x,y,button}
end

function engine.registerCallbacks()
    love.load = load
    love.draw = draw
    love.update = update
    love.keypressed = keypressed
    love.texinput = textinput
    love.mousereleased = mousereleased
end

function engine.getLoveEvent(Name)
    if eventQueue[Name] then
        return unpack(eventQueue[Name])
    end
end

engine.event.new("onClicked",function(sprite)
    local mx,my, button = engine.getLoveEvent("mousereleased")
    --print(mx,my,button)
    if not mx then return end
    local layer = sprite:getLayer()
    if layer and sprite:getVisible() then
        if layer:getVisible() and layer:getActive() then
            local x1,y1 = layer:toScreen(mx,my)
            return button == "l" and sprite:isInside(x1,y1)
        end
    end
end)

engine.event.new("onMouseOver", function(sprite)
    local layer = sprite:getLayer()
    if layer and sprite:getVisible() then
        if layer:getVisible() and layer:getActive() then
            local x1,y1,x2,y2 = layer:toScreen(sprite:getBBox())
            local mx, my = love.mouse.getPosition()
            if not mouseover[sprite] and mx > x1 and mx < x2 and my > y1 and my < y2 then
                mouseover[sprite] = true
                return true
            elseif not engine.event.isRegistered("onMouseOff",sprite) and mouseover[sprite] and (mx < x1 or mx > x2 or my < y1 or my > y2) then
                mouseover[sprite] = nil
                return false
            end
        end
    end
end)

engine.event.new("onMouseOff", function(sprite)
    local layer = sprite:getLayer()
    if layer and sprite:getVisible() then
        if layer:getVisible() and layer:getActive() then
            local x1,y1,x2,y2 = layer:toScreen(sprite:getBBox())
            local mx, my = love.mouse.getPosition( )
            if mouseover[sprite] and (mx < x1 or mx > x2 or my < y1 or my > y2) then
                mouseover[sprite] = nil
                return true
            elseif not engine.event.isRegistered("onMouseOver",sprite) and not mouseover[sprite] and mx > x1 and mx < x2 and my > y1 and my < y2 then
                mouseover[sprite] = true
                return false
            end
        end
    end
end)

engine.event.new("onUpdate", function()
    return true
end)

return engine