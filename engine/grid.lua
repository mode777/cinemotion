local grid = {}

function grid.new(W,H)
    local tw, th = W or 0, H or 0
    local data = {}
    local i = {}

    function i:clear()
        data = {}
        for cell = 1, W*H do
            data[cell] = 0
        end
    end

    function i:setData(...)
        data = {... }
        if #data ~= tw*th then error("Grid data is the wrong size. Should be "..tw*th..". Is "..#data..".") end
    end

    function i:setCell(x,y,v)
        if x < 0 then x = x+1 end
        if y < 0 then y = y+1 end
        x,y = x%tw, y%tw
        if x == 0 then x = tw end
        if y == 0 then y = th end
        data[((y-1)*tw)+x] = v
    end

    function i:setSize(w,h)
        tw, th = w,h
    end

    function i:getSize()
        return tw,th
end

    function i:getCell(x,y)
        if x < 0 then x = x+1 end
        if y < 0 then y = y+1 end
        x,y = x%tw, y%th
        if x == 0 then x = tw end
        if y == 0 then y = th end
        if x>tw or y>th then error("Data out of range "..x.." "..y.." "..tw.." "..th) end
        return data[((y-1)*tw)+x]
    end

    function i:getData()
        return data
    end


    if W and H then i:setSize(W,H) end
    return i
end

return grid