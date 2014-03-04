local layer = require(ENGINE_PATH.."/layer")
local grid = require(ENGINE_PATH.."/grid")

local layerTiles = {}

function layerTiles.new(tw,th)
    local batch
    local offsetX, offsetY = 0,0
    local FLIPX, FLIPY = 2147483648, 1073741824
    local tileset
    local tileX, tileY = tw or 0,th or tw or 0
    local screenX, screenY = love.window.getWidth(), love.window.getHeight()
    local collGrid
    local tileGrid
    local i = layer.new()

    function i:setDrawable(Drawable)
        tileset = Drawable
    end

    function i:getDrawable()
        return tileset
    end

    function i:setCollisionGrid(w,h,...)
        if type(w) == "table" then
            collGrid = w
        else
            collGrid = grid.new(w,h)
            collGrid:setData(...)
        end
        return collGrid
    end

    function i:getCollisionGrid()
        return collGrid
    end

    function i:setTileGrid(w,h,...)
        if type(w) == "table" then
            tileGrid = w
        else
            tileGrid = grid.new(w,h)
            tileGrid:setData(...)
        end
        return tileGrid
    end

    function i:getTileGrid()
        return tileGrid
    end

    function i:setTileSize(tx,ty)
        tileX, tileY = tx, ty or tx
    end

    function i:updateBatch()
        if not tileGrid or not tileset then return end
        local tw,th = tileX, tileY
        local gw, gh = tileGrid:getSize()
        local batchX, batchY = math.ceil(screenX/tw),math.ceil(screenY/th)

        if offsetX+batchX > gw then
            if gw-offsetX > 0 then batchX = gw-offsetX else return end
        end

        if offsetY+batchY > gh then
            if gh-offsetY > 0 then batchY = gh-offsetY else return end
        end

        local function makeBatch(update)
            batch:bind()
            local c = 0

            for y = offsetY, offsetY+batchY do
                for x = offsetX, offsetX+batchX do
                    local quadid = tileGrid:getCell(x+1,y+1) --or 0
                    if quadid > FLIPX+FLIPY then
                        quadid = quadid - FLIPX - FLIPY
                    elseif quadid > FLIPX then
                        quadid = quadid - FLIPX
                    elseif quadid > FLIPY then
                        quadid = quadid - FLIPY
                    else
                    end

                    if quadid ~= 0 then
                       if update then
                           batch:set(c,tileset:getQuad(quadid),x*tw,y*th)
                       else
                           batch:add(tileset:getQuad(quadid),x*tw,y*th)
                       end
                    elseif not update then
                        batch:add(tileset:getQuad(1),-tw,-th)
                    end
                    c = c+1
                end
            end
            batch:unbind()
        end

        if not batch then
            batch = love.graphics.newSpriteBatch(tileset:getImage(), (batchX+1)*(batchY+1), "static")
            makeBatch()
        else
            makeBatch(true)
        end
    end

    local oldDraw = i.draw
    function i:draw()
        love.graphics.push()
        local newOffsetX,newOffsetY
        local camX, camY = 0,0
        local px,py = self:getParallax()
        local cam = self:getCamera()
        if cam then
            camX,camY = cam:getPos()
            local tw,th = tileX, tileY
            newOffsetX,newOffsetY = math.floor((camX*px)/tw),math.floor((camY*px)/th)
            if newOffsetX ~= offsetX or newOffsetY ~= offsetY then
                offsetX, offsetY = newOffsetX, newOffsetY
                self:updateBatch()
            end
            love.graphics.translate(-camX*px, -camY*px)
        end
        if not batch then self:updateBatch() end
        if batch then love.graphics.draw(batch,0,0) end
        love.graphics.pop()
        oldDraw(self)
    end

    local oldUpdate = i.update

    function i:update()
        local f = math.floor
        if collGrid then
            for sprite,_ in pairs(self:getAllSprites()) do
                local x1,y1,x2,y2 = sprite:getBBox()
            end
        end
    end

    return i
end

return layerTiles