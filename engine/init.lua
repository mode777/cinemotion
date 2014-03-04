ENGINE_PATH = ENGINE_PATH or "engine"

local engine = {}

engine.showConsole = false
engine.showFrames = false

local oldprint = print
local printstack = {}

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
engine.layerTiles = require(ENGINE_PATH.."/layerTiles")
engine.sourceImage = require(ENGINE_PATH.."/drawableImage")
engine.sourceTileset = require(ENGINE_PATH.."/drawableTileset")
engine.sourceFont = require(ENGINE_PATH.."/drawableFont")
engine.spriteSheet = require(ENGINE_PATH.."/spriteSheet")
engine.animationSheet = require(ENGINE_PATH.."/animationSheet")
engine.geometry = require(ENGINE_PATH.."/geometry")
engine.camera = require(ENGINE_PATH.."/geometry")
engine.sprite = require(ENGINE_PATH.."/sprite")
engine.group = require(ENGINE_PATH.."/group")
engine.menu = require(ENGINE_PATH.."/menu")
engine.textinput = require(ENGINE_PATH.."/textinput")
engine.scene = require(ENGINE_PATH.."/scene")

function engine.reset()
    engine.layer.clearAll()
    engine.thread.clearAll()
    local scene = engine.scene.new(engine.config.startScene)
    scene:run()
end

local function load()
    local cfg = {
    startScene = "init.sce",
    debug = {console=true, lines=false, frames=true },
    fullscreen = false,
    resolution = {x=640,y=480}
    }
    --engine.serialize.save(cfg,"engine.cfg")
    if love.keyboard.isDown("f8") then
        engine.config = cfg
    else
        engine.config = cfg--engine.serialize.load("engine.cfg")
    end
    engine.config.resolution = engine.config.resolution or {x=640,y=480}
    love.window.setMode(engine.config.resolution.x,engine.config.resolution.y, {fullscreen = engine.config.fullscreen})
    engine.showConsole = engine.config.debug.console
    engine.sprite.showBounds(engine.config.debug.lines)
    engine.reset()
end

local function draw()
    engine.layer.draw()
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
    engine.thread.update()
end

local function keypressed(key, u)
    if key == "t" then print("Active threads:", engine.thread.active()) end
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

function engine.registerCallbacks()
    love.load = load
    love.draw = draw
    love.update = update
    love.keypressed = keypressed
    love.texinput = textinput
end

return engine
