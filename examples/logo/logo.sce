local cm = require(ENGINE_PATH)
local scene = {}

local layer = cm.layer.new()
function scene:onLoad()
    local posx,posy = 215,170
    local size = 16
    local sourceLogo = cm.sourceTileset.new("examples/logo/logo.png", size,size)
    local data = {}
    local iw,ih = sourceLogo:getSize()
    iw, ih = iw/size, ih/size
    for i=1,iw*ih do table.insert(data, i) end
    local grid = cm.grid.new(iw, ih)
    grid:setData(unpack(data))
    local sprites={}
    for i=1, iw*ih do
        local s = cm.sprite.new(math.random(love.window.getWidth()),math.random(love.window.getHeight()),sourceLogo,i)
        s:setGeometryModel("point")
        s:moveRot(-3+math.random(30)/10)
        s:moveScaTo(0.5+math.random(30)/10)
        table.insert(sprites,s)
        layer:insertSprite(s)
    end
    local fade = layer:insertSprite(cm.sprite.new(0,0,cm.sourceRectangle.new(),{love.window.getWidth(),love.window.getHeight()}))
    fade:setTweenStyle("easein")
    fade:moveTintTo(255,255,255,0,2)
    for y = 1, grid:getHeight() do
        for x = 1, grid:getWidth() do
            sprites[grid:getCell(x,y)]:setTweenStyle("easeinout")
            sprites[grid:getCell(x,y)]:movePosTo(posx+x*size,posy+y*size,10)
            sprites[grid:getCell(x,y)]:moveRotTo(0,10)
            sprites[grid:getCell(x,y)]:moveScaTo(1,1,10)
        end
    end
    cm.thread.wait(14)
    self:stop()
    --initialize your scene here
end

function scene:onStop()
    cm.layer.remove(layer)
    --define what is going to happen when your scene stops
end

return scene