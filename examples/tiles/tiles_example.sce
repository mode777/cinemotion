local cm = require(ENGINE_PATH)
local scene = {}
local tileLayers = {}

function scene.onLoad()
    local layer = cm.layer.new()
    local tileset = cm.sourceTileset.new("examples/tiles/terrain_atlas.png",32,32)
    local data = require('examples/tiles/lpc')
    local cam = cm.camera.new()
    layer:setCamera(cam)
    for i=1, 8 do
        local grid = cm.grid.new(data.width,data.height)
        tileLayers[i] = cm.sprite.new(0,0,tileset,grid)
        grid:setData(unpack(data.layers[i].data))
        layer:insertSprite(tileLayers[i])
    end
    tileLayers[8]:setBlendmode("additive")
    tileLayers[8]:setTint(255,255,255,100)
    --print(unpack(grid:getData()))
    --initialize your scene here
end

function scene.onUpdate()
    tileLayers[8]:movePos(-0.1,-0.1)
    --update your scene here.
end

function scene.onStop()
    --define what is going to happen when your scene stops
end

return scene