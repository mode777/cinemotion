local hash = {}
function hash.new(CellX, CellY)
    local data = {}
    local cellX, cellY = CellX or 100, CellY or CellX or 100
    local f = math.floor
    local c = math.ceil

    local i = {}

    function i:insertSprite(sprite,x1,y1,x2,y2)
        if not y2 then x1,y1,x2,y2 = sprite:getBBox() end
        if not cellX then i:setCellSize(100) end
        local minCellX, maxCellX = f(x1/cellX),f(x2/cellX)
        local minCellY, maxCellY = f(y1/cellY),f(y2/cellY)

        for cy = minCellY, maxCellY do
            if not data[cy] then data[cy] = {} end
            for cx = minCellX, maxCellX do
                if not data[cy][cx] then data[cy][cx] = {} end
                data[cy][cx][sprite] = true
            end
        end
        if sprite:isGroup() then
            for _,child in ipairs(sprite:getChildren()) do
                self:insertSprite(child)
            end
        end

        sprite:setLayer(self,true)
        return sprite
    end

    function i:removeSprite(sprite,x1,y1,x2,y2)
        if not y2 then x1,y1,x2,y2 = sprite:getBBox() end
        for cy = f(y1/cellY), f(y2/cellY) do
            for cx = f(x1/cellX), f(x2/cellX) do
                data[cy][cx][sprite] = nil
            end
        end
        if sprite:isGroup() then
            for _,child in ipairs(sprite:getChildren()) do
                self:removeSprite(child)
            end
        end
        sprite:setHash(nil)
    end

    function i:updateSprite(sprite,x1,y1,x2,y2,x3,y3,x4,y4)
        if f(y1/cellY) == f(y3/cellY) and
           f(y2/cellY) == f(y4/cellY) and
           f(x1/cellX) == f(x3/cellX) and
           f(x2/cellX) == f(x4/cellX) then
            return --do nothing if in same cell
        else
            i:removeSprite(sprite,x1,y1,x2,y2)
            i:insertSprite(sprite,x3,y3,x4,y4)
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

    function i:getInRange(x1,y1,x2,y2)
        local list = {}
        local minCellX, maxCellX
        local minCellY, maxCellY
        minCellX, maxCellX = f(x1/cellX),f(x2/cellX)
        minCellY, maxCellY = f(y1/cellY),f(y2/cellY)
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