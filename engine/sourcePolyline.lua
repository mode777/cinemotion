local sourcePoyline = {}
local line = love.graphics.line
local setLineWidth = love.graphics.setLineWidth

function sourcePoyline.new(W)
    local i = {}
    local lineWidth = 1
    function i:draw(index)
       setLineWidth(lineWidth)
       if type(index) == "table" then line(unpack(index)) end
    end
    function i:setLineWidth(w)
        lineWidth = w
    end
    function i:getSize(index)
        if type(index) == "number" then return 0,0 end
        local x1,y1,x2,y2
        for i=1, #index do
            if i%2 == 0 then --x
                if not x1 then x1 = index[i] end
                if not x2 then x2 = index[i] end
                if index[i] < x1 then x1 = index[i] end
                if index[i] > x2 then x2 = index[i] end
            else --y
                if not y1 then y1 = index[i] end
                if not y2 then y2 = index[i] end
                if index[i] < y1 then y1 = index[i] end
                if index[i] > y2 then y2 = index[i] end
            end
        end
        return x2-x1,y2-y1
    end
    if W then i:setLineWidth(W) end
    return i
end

return sourcePoyline