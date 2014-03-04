local hash = {}
function hash.new(CellX, CellY)
    local grid
    local cellX, cellY = CellX or 100, CellY or CellX or 100
    local f = math.floor

    local i = {}

    function i:insertSprite(sprite,x,y,w,h)
        if not x then x,y = sprite:getPos() end
        if not w then w,h = sprite:getSize() end
        if not cellX then i:setCellSize(100) end
        local minCellX, maxCellX = f(x/cellX)+1,f((x+w)/cellX)+1
        local minCellY, maxCellY = f(y/cellY)+1,f((y+h)/cellY)+1

        if maxCellX > #grid[1] or maxCellY > #grid then i:extendHash(maxCellX,maxCellY) end

        for cy = minCellY, maxCellY do
            for cx = minCellX, maxCellX do
                grid[cy][cx][sprite] = true
            end
        end
        sprite:setHash(self)
    end

    function i:removeSprite(sprite,x,y,w,h)
        if not x then x,y = sprite:getPos() end
        if not w then w,h = sprite:getSize() end

        for cy = f(y/cellY)+1, f((y+h)/cellY)+1 do
            for cx = f(x/cellX)+1, f((x+w)/cellX)+1 do
                grid[cy][cx][sprite] = nil
            end
        end
        sprite:setHash(nil)
    end

    function i:updateSprite(sprite,ox,oy,nx,ny,w,h)
        if not w then w,h = sprite:getSize() end
        if f(oy/cellY)+1 == f(ny/cellY)+1 and
           f((oy+h)/cellY)+1 == f((ny+h)/cellY)+1 and
           f(ox/cellX)+1 == f(nx/cellX)+1 and
           f((ox+w)/cellX)+1 == f((nx+w)/cellX)+1 then
            return --do nothing if in same cell
        else
            i:removeSprite(sprite,ox,oy,w,h)
            i:insertSprite(sprite,nx,ny,w,h)
        end
    end

    function i:extendHash(X,Y)
        local oldY = #grid
        local oldX = #grid[1]
        for y = oldY+1, Y+1 do
            table.insert(grid, {})
            for x = 1, oldX do
                table.insert(grid[y], {})
            end
        end
        for y = 1, #grid do
            for x = oldX+1, X+1 do
                table.insert(grid[y], {})
            end
        end
        --print("Hash Extended, Old:", oldX, oldY, "New:", #grid[1],#grid)
    end

    function i:getAllSprites()
        return i:getInRange()
    end

    function i:getInRange(x,y,w,h)
        local list = {}
        local minCellX, maxCellX
        local minCellY, maxCellY
        if x then
            minCellX, maxCellX = f(x/cellX)+1,f((x+w)/cellX)+1
            minCellY, maxCellY = f(y/cellY)+1,f((y+h)/cellY)+1
            maxCellX, maxCellY = math.min(maxCellX,#grid[1]), math.min(maxCellY,#grid)
            if maxCellX < minCellX or maxCellY < minCellX then return list end
        else
            minCellX, maxCellX = 1,#grid[1]
            minCellY, maxCellY = 1,#grid
        end

        for y = minCellY, maxCellY do
            for x = minCellX, maxCellX do
                for sprite,_ in pairs(grid[y][x]) do
                    list[sprite] = true
                end
            end
        end
        return list
    end

    function i:setCellSize(W,H)
        cellX, cellY = W,H or W
        --print("New cell size",cellX,cellY)
        grid = { { {} } }
    end

    function i:getCellSize()
        return cellY, cellY
    end

    i:setCellSize(cellX, cellY)

    return i
end

return hash