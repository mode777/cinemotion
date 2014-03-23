local floor = math.floor

local hash = require(ENGINE_PATH.."/hash")
local layer = {}
local layers = {}

function layer.new(cellW, cellH)
    local px, py = 1,1 --parallax
    local cam
    local instance = hash.new(cellW,cellH)
    local lastSprites = {}
    local visible = true
    local active = true
    local x1,y1,x2,y2

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
            if cam then love.graphics.translate(floor(-camX-0.5),floor(-camY-0.5)) end
            --todo parallax scrolling is probably broken
        end
        local spritelist = self:getInRange(sx1,sy1,sx2,sy2)

        local drawlist = {}
        for sprite,_ in pairs(spritelist) do
            table.insert(drawlist,sprite)
            if not lastSprites[sprite] then
                sprite:fireEvent("onScreen")
            else
                lastSprites[sprite] = nil
            end
        end
        if x1 then love.graphics.setScissor(x1,y1,x2-x1,y2-y1) end --limit viewport
        table.sort(drawlist,function(a,b) return a:getZIndex() < b:getZIndex() end)
        for i=1, #drawlist do
            drawlist[i]:draw(sx1,sy1,sx2,sy2)
        end
        if x1 then love.graphics.setScissor() end
        love.graphics.pop()
        for sprite,_ in pairs(lastSprites) do
            sprite:fireEvent("offScreen")
        end
        lastSprites = spritelist
    end

    function instance:setCamera(camera)
        cam = camera
        cam:updateTransformation()
    end

    function instance:getCamera()
        return cam
    end

    function instance:setViewport(X1,Y1,X2,Y2)
       x1,y1,x2,y2 = X1,Y1,X2,Y2
    end

    function instance:toScreen(...)
        local data = {...}
        local cx,cy = 0,0
        if cam then cx,cy = cam:getBBox() end
        for i=1, #data do
            if i%2 == 0 then --x
                data[i] = data[i] - cx
            else --y
                data[i] = data[i] - cy
            end
        end
        return unpack(data)
    end

    function instance:getParallax()
        return px,py
    end

    function instance:setParallax(x,y)
        px,py = x,y
    end


    function instance:setActive(bool)
        active = bool
    end

    function instance:getActive( )
        return active
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

function layer.amount()
    return #layers
end

function layer.remove(layer)
    for i=1, #layers do
        if layers[i] == layer then
            table.remove(layers, i)
        end
    end
end

return layer