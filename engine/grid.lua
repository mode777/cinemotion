local grid = {}

function grid.new(w,h)
    local tw, th = w or 0, h or 0
    local data = {}
    local i = {}

    function i:clear()
        data = {}
        for cell = 1, w*h do
            data[cell] = 0
        end
    end

    function i:setData(...)
        data = {...}
    end

    function i:setCell(x,y,v)
        data[((y-1)*(tw+1)+x)] = v
    end

    function i:setSize(w,h)
        tw, th = w,h
    end

    function i:getSize()
        return tw,th
    end

    function i:getCell(x,y)
        return data[((y-1)*(tw+1))+x]
    end

    function i:getData()
        return data
    end

    return i
end

return grid