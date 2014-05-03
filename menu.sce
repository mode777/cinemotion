local cm = require(ENGINE_PATH)

local layer

local scene = {}

function scene:onLoad()
    local source = cm.sourceImage.new("logo.png")
    layer = cm.layer.new()
    local sprite = cm.sprite.new(100,100,source,1)
    local sprite2 = cm.sprite.new(100,200,source,1)
    local ghost = {}
    setmetatable(ghost, {__index=sprite})
    --ghost.movePos = sprite2.movePos
    ghost:movePos(100,100,10)
    layer:insertSprite(ghost)
    --layer:insertSprite()


end

function scene:onUpdate()
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene