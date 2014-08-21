local grid = {}

function grid.new(W,H,Data)
    local tw, th = W or 0, H or 0
    local data = Data or {}
    local i = {}

    function i:clear()
        data = {}
        for i = 1, tw*th do
            data[i] = false
        end
    end

    function i:setData(table)
        data = table
        if #data ~= tw*th then print("Warning: Grid data is the wrong size. Should be "..tw*th..". Is "..#data..".") end
    end

    function i:setCell(x,y,v)
        data[self:getIndex(x,y)] = v
    end

    function i:setSize(w,h)
        tw, th = w,h
    end

    function i:getSize()
        return tw,th
    end

    function i:getHeight()
        return th
    end

    function i:getWidth()
        return tw
    end

    function i:getCell(x,y)
        return data[self:getIndex(x,y)]
    end

    function i:getIndex(x,y)
        x,y = x-1,y-1
        x,y = x%tw, y%th
        return (y*tw+x)+1
    end

    function i:getCoordinates(index)
        local f = math.floor
        index = index-1
        index = index%(tw*th)
        return index%tw+1,f(index/tw+1)
    end

    function i:getRow(y)
        local buffer = {}
        for x=1, tw do
            table.insert(buffer,self:getCell(x,y))
        end
        return buffer
    end

    function  i:shiftRow(y,amnt)
        if amnt > 0 then
            for i=1, amnt do
                for x=tw, 2, -1 do
                    data[self:getIndex(x,y)],data[self:getIndex(x-1,y)] = data[self:getIndex(x-1,y)], data[self:getIndex(x,y)]
                end
            end
        elseif amnt < 0 then
            for i=1, math.abs(amnt) do
                for x=1, tw-1 do
                    data[self:getIndex(x,y)],data[self:getIndex(x+1,y)] = data[self:getIndex(x+1,y)], data[self:getIndex(x,y)]
                end
            end
        end
    end

    function i:shiftCollumn(x,amnt)
        if amnt > 0 then
            for i=1, amnt do
                for y=th, 2, -1 do
                    data[self:getIndex(x,y)],data[self:getIndex(x,y-1)] = data[self:getIndex(x,y-1)], data[self:getIndex(x,y)]
                end
            end
        elseif amnt < 0 then
            for i=1, math.abs(amnt) do
                for y=1, th-1 do
                    data[self:getIndex(x,y)],data[self:getIndex(x,y+1)] = data[self:getIndex(x,y+1)], data[self:getIndex(x,y)]
                end
            end
        end
    end

    function i:getCollumn(x)
        local buffer = {}
        for y=1, th do
            table.insert(buffer,self:getCell(x,y))
        end
        return buffer
    end

    function i:getSubgrid(X,Y,W,H)
        if X+W-1 > self:getWidth() then W = self:getWidth()-X+1 end
        if Y+H-1 > self:getHeight() then H = self:getHeight()-H end
        local g = grid.new(W,H)
        local buffer = {}
        for y=Y, Y+H-1  do
            for x=X, X+W-1 do
                table.insert(buffer, self:getCell(x,y))
            end
        end
        g:setData(buffer)
        return g
    end

    function i:setRow(y, Data)
        for x=1, tw do
            self:setCell(x,y,data,Data[x])
        end
    end

    function i:setCollumn(x,Data)
        for y=1, th do
            self:setCell(x,y,data,Data[y])
        end
    end

    function i:getData()
        return data
    end

    if W and H then i:setSize(W,H) end
    return i
end

return grid