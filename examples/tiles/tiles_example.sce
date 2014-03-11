local cm = require(ENGINE_PATH)
local scene = {}
local tileLayers = {}
local cam
local layer
function scene:onLoad()
    layer = cm.layer.new()
    local tileset = cm.sourceTileset.new("examples/tiles/terrain_atlas.png",32,32)
    local data = require('examples/tiles/tiletest_cm')
    cam = cm.camera.new()
    layer:setCamera(cam)
    for i=1, 3 do
        local grid = cm.grid.new(data.width,data.height)
        tileLayers[i] = cm.sprite.new(0,0,tileset,grid)
        grid:setData(unpack(data.layers[i].data))
        layer:insertSprite(tileLayers[i])
    end
    --tileLayers[8]:setBlendmode("additive")
    --tileLayers[8]:setTint(255,255,255,100)
    --print(unpack(grid:getData()))
    --initialize your scene here
    cm.thread.waitThread(cam:movePosTo(512,512,5))
    self:stop()
end

function scene.onUpdate()
    --cm.thread.waitThread(cam:movePosTo(0,0,3))
    --update your scene here.
end

function scene.onStop()
   cm.layer.remove(layer)
    --define what is going to happen when your scene stops
end

return scene