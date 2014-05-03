local grid = {}

function grid.new(W,H)
    local tw, th = W or 0, H or 0
    local data = {}
    local i = {}

    function i:clear()
        data = nil
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
        local f = math.floor
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

    function i:getCollumn(x)
        local buffer = {}
        for y=1, th do
            table.insert(buffer,self:getCell(x,y))
        end
        return buffer
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