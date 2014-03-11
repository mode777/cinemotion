local cm = require(ENGINE_PATH)
local scene = {}

local layer
local sprites = {}
local r = math.random
local w,h = love.window.getDimensions()
function scene:onLoad()
    layer = cm.layer.new()
    local font = cm.sourceFont.new()
    for i=1, 250 do
        local sprite = cm.sprite.new(r(w),r(h),font,"Hello World")
        layer:insertSprite(sprite)
        sprite:movePosTo(r(w),r(h),1)
        table.insert(sprites,sprite)
    end

    --initialize your scene here
end

function scene:onUpdate()
    for i=1, #sprites do sprites[i]:movePosTo(r(w),r(h),5) end
    cm.thread.wait(10)
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene