local floor = math.floor
local zcount = 0

local hash = require(ENGINE_PATH.."/hash")
local cineCamera = require(ENGINE_PATH.."/camera")
local layer = {}
local layers = {}

function layer.new(cellW, cellH)
    local cam
    local instance = cellW ~= "NOHASH" and hash.new(cellW,cellH) or {}
    local lastSprites = {}
    local visible = true
    local active = true
    local x1,y1,x2,y2
    local zIndex = zcount
    zcount = zcount + 1

    function instance:setVisible(bool)
        visible = bool
    end

    function instance:getVisible()
        return visible
    end

    function instance:setZIndex(z)
        zIndex = z
    end

    function instance:getZIndex()
        return zIndex
    end

    local screenX,screenY = love.window.getWidth(), love.window.getHeight()
    function instance:draw()
        love.graphics.push()
        local sx1,sy1,sx2,sy2 = 0,0,screenX,screenY
        local camera = cam
        if camera then
            camera:updateTransformation()
            sx1,sy1,sx2,sy2 = camera:getBBox()
            local camX, camY = camera:getPos()
            local scx, scy = camera:getSca()
            local rot = camera:getRot()
            local pivx,pivy = camera:getPiv()
            love.graphics.translate(pivx,pivy)
            love.graphics.rotate(rot)
            love.graphics.scale(1/scx,1/scy)
            love.graphics.translate(-camX,-camY)
        end
        local spritelist = self:getInRange(sx1,sy1,sx2,sy2)

        local drawlist = {}

        for sprite,_ in pairs(spritelist) do
            table.insert(drawlist,sprite)
            --if not lastSprites[sprite] then
                --sprite:fireEvent("onScreen")
            --else
                --lastSprites[sprite] = nil
            --end
        end

        if x1 then love.graphics.setScissor(x1,y1,x2-x1,y2-y1) end --limit viewport
        table.sort(drawlist,function(a,b) return a:getZIndex() < b:getZIndex() end)
        for i=1, #drawlist do
            drawlist[i]:draw(sx1,sy1,sx2,sy2)
        end
        if x1 then love.graphics.setScissor() end
        love.graphics.pop()
        --for sprite,_ in pairs(lastSprites) do
            --sprite:fireEvent("offScreen")
        --end
        --lastSprites = spritelist
    end

    function instance:getBBox()
        local camera = cam
        if camera then
            return camera:getBBox()
        else
            local sw,sh = love.window.getDimensions()
            return 0,0,sw,sh
        end
    end

    function instance:toLayer(x,y)
        local camera = cam

        if self.name then
            --local ox,oy = cam:transformPoint(x,y)
            --local nx,ny = parallaxCam:transformPoint(x,y)
            --print(self.name,ox,oy,nx,ny)
        end
        if camera then
            return camera:transformPoint(x,y)
        else
            return x,y
        end
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
        local camera = cam
        if camera then
            for i=1, #data-1 do
                data[i],data[i+1] = camera:projectPoint(data[i],data[i+1])
            end
        end
        return unpack(data)
    end


    function instance:setActive(bool)
        active = bool
    end

    function instance:getActive( )
        return active
    end

    function instance:getVisibleSprites()
        return lastSprites
    end

    table.insert(layers,instance)
    return instance
end

function layer.draw()
    table.sort(layers,function(a,b) return a:getZIndex() < b:getZIndex() end)
    for i = 1, #layers do
        if layers[i]:getVisible() then
            layers[i]:draw()
        end
    end
end

function layer.clearAll()
    layers = {}
end

function layer.getAll()
    return layers
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

function layer.insert(layer)
    table.insert(layers,layer)
end

function layer.toBackground(Layer)
    Layer:setZIndex(0)
end

function layer.toForeground(Layer)
    Layer:setZIndex(zcount)
    zcount = zcount+1
end

return layer