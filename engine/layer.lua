local hash = require(ENGINE_PATH.."/hash")
local layer = {}
local layers = {}

function layer.new(cellW, cellH)
    local px, py = 1,1 --parallax
    local cam
    local instance = hash.new(cellW,cellH)
    local lastSprites = {}
    local visible = true

    function instance:setVisible(bool)
        visible = bool
    end

    function instance:getVisible()
        return visible
    end

    function instance:draw()
        love.graphics.push()
        local screenX,screenY = love.window.getWidth(), love.window.getHeight()
        local sx1,sy1,sx2,sy2 = 0,0,screenX,screenY
        if cam then
            sx1,sy1,sx2,sy2 = cam:getBBox()
            local camX, camY = cam:getPos()
            --print(cam:getBBox())
            if cam then love.graphics.translate(-camX*px, -camY*py) end
            --todo parallax scrolling is probably broken
        end
        local spritelist = self:getInRange(sx1,sy1,sx2,sy2)

        local drawlist = {}
        for sprite,_ in pairs(spritelist) do
            table.insert(drawlist,sprite)
            if not lastSprites[sprite] then
                sprite:event("onScreen")
            else
                lastSprites[sprite] = nil
            end
        end
        table.sort(drawlist,function(a,b) return a:getZIndex() < b:getZIndex() end)
        for i=1, #drawlist do
            drawlist[i]:draw(sx1,sy1,sx2,sy2)
        end
        love.graphics.pop()
        for sprite,_ in pairs(lastSprites) do
            sprite:event("offScreen")
        end
        lastSprites = spritelist
    end

    function instance:setCamera(camera)
        cam = camera
        cam:updateBBox()
    end

    function instance:getCamera()
        return cam
    end

    function instance:getParallax()
        return px,py
    end

    function instance:setParallax(x,y)
        px,py = x,y
    end

    function instance:getSprites()
        return sprites
    end

    table.insert(layers,instance)
    function instance:_created()
        print("[layer]: Layer created", instance)
    end
    instance:_created()
    return instance
end

function layer.draw()
    for i = 1, #layers do
        if layers[i]:getVisible() then
            layers[i]:draw()
        end
    end
end

function layer.clearAll()
    layers = {}
end

function layer.remove(layer)
    for i=1, #layers do
        if layers[i] == layer then
            table.remove(layers, i)
        end
    end
end

return layer