local cm = require(ENGINE_PATH)
local scene = {}

function scene.onLoad()
    --initialize your scene here
    local layer = cm.layer.new()
    local font = cm.sourceFont.new()
    local text = cm.sprite.new(100,100,font,"Hello World")
    local cam = cm.camera.new()

    layer:insertSprite(text)
    layer:setCamera(cam)
end

function scene.onUpdate()
    --update your scene here.
end

function scene.onStop()
    --define what is going to happen when your scene stops
end

return scene