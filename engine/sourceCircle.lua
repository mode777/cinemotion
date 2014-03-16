local sourceCircle = {}
local circle = love.graphics.circle

function sourceCircle.new(Mode)
    local i = {}
    local mode
    function i:draw(index)
       if index then circle(mode, index,index,index) end
    end
    function i:getSize(index)
        return index*2, index*2
    end
    function i:setMode(Mode)
        mode = Mode
    end
    function i:getMode()
        return mode
    end
    if Mode then i:setMode(Mode) else i:setMode("line") end
    return i
end

return sourceCircle