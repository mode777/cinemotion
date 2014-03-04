local hash = {}
function hash.new(CellX, CellY)
    local data = {}
    local cellX, cellY = CellX or 100, CellY or CellX or 100
    local f = math.floor
    local c = math.ceil

    local i = {}

    function i:insertSprite(sprite,x,y,w,h)
        if not x then x,y = sprite:getPos() end
        if not w then w,h = sprite:getSize() end
        if not cellX then i:setCellSize(100) end
        local minCellX, maxCellX = f(x/cellX),f((x+w)/cellX)
        local minCellY, maxCellY = f(y/cellY),f((y+h)/cellY)

        for cy = minCellY, maxCellY do
            for cx = minCellX, maxCellX do
                if not data[cx.."|"..cy] then data[cx.."|"..cy] = {} end
                data[cx.."|"..cy][sprite] = true
            end
        end
        sprite:setHash(self)
    end

    function i:removeSprite(sprite,x,y,w,h)
        if not x then x,y = sprite:getPos() end
        if not w then w,h = sprite:getSize() end

        for cy = f(y/cellY), f((y+h)/cellY) do
            for cx = f(x/cellX), f((x+w)/cellX) do
                data[cx.."|"..cy][sprite] = nil
            end
        end
        sprite:setHash(nil)
    end

    function i:updateSprite(sprite,ox,oy,nx,ny,ow,oh,nw,nh)
        if not ow then ow,oh = sprite:getSize() end
        nw, nh = nw or ow, nh or oh
        if f(oy/cellY) == f(ny/cellY) and
           f((oy+oh)/cellY) == f((ny+nh)/cellY) and
           f(ox/cellX) == f(nx/cellX) and
           f((ox+ow)/cellX) == f((nx+nw)/cellX) then
            return --do nothing if in same cell
        else
            i:removeSprite(sprite,ox,oy,ow,oh)
            i:insertSprite(sprite,nx,ny,nw,nh)
        end
    end

    function i:getAllSprites()
        local list = {}
        for _, cell in pairs(data) do
            for sprite in pairs(cell) do
                list[sprite] = true
            end
        end
        return list
    end

    function i:getInRange(x,y,w,h)
        local list = {}
        local minCellX, maxCellX
        local minCellY, maxCellY
        minCellX, maxCellX = f(x/cellX),f((x+w)/cellX)
        minCellY, maxCellY = f(y/cellY),f((y+h)/cellY)
        for y = minCellY, maxCellY do
            for x = minCellX, maxCellX do
                if data[x.."|"..y] then
                    for sprite in pairs(data[x.."|"..y]) do
                        list[sprite] = true
                    end
                end
            end
        end

        return list
    end

    function i:getCellSize()
        return cellY, cellY
    end

    return i
end

return hash