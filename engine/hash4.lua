local hash = {}
function hash.new(CellX, CellY)
    local data = {}
    local sprites = {}
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
            if not data[cy] then data[cy] = {} end
            for cx = minCellX, maxCellX do
                if not data[cy][cx] then data[cy][cx] = {} end
                data[cy][cx][sprite] = true
                if not sprites[sprite] then sprites[sprite] = {} end
                table.insert(sprites[sprite],{cx, cy})
            end
        end
        sprite:setHash(self)
    end

    function i:removeSprite(sprite)
        for i=1, #sprites[sprite] do
            local x, y = unpack(sprites[sprite][i])
            data[y][x][sprite] = nil
        end
        sprites[sprite] = nil
        sprite:setHash(nil)
    end

    function i:updateSprite(sprite)
        self:removeSprite(sprite)
        self:insertSprite(sprite)
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
                if data[y] then
                    if data[y][x] then
                        for sprite in pairs(data[y][x]) do
                            list[sprite] = true
                        end
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