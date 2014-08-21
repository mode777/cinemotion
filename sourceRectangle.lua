local sourceRectangle = {}

function sourceRectangle.new(LineWidth, LineColor)
    local lineColor
    local lineWidth
    local i = {}
    function i:draw(sprite)
        local index = sprite:getIndex()
        if index then
            love.graphics.rectangle("fill",0,0,unpack(index))
            if lineWidth then
                if lineColor then love.graphics.setColor( unpack(lineColor) ) end
                love.graphics.setLineWidth(lineWidth)
                love.graphics.rectangle( "line",0,0,unpack(index) )
            end
        end
    end
    function i:setLineColor( r, g, b, a )
        lineColor = {r,g,b,a }
    end
    function i:setLineWidth( w )
        lineWidth = w
    end
    function i:getSize(sprite)
        local index = sprite:getIndex()
        --if type(index) ~= "table" then return error("sourceRectangle needs a table as index. Given: "..tostring(index)) end
        if index then
            return index[1],index[2]
        else
            return 0,0
        end
    end
    if LineWidth then i:setLineWidth(LineWidth) else i:setLineWidth(1) end
    if LineColor then i:setLineColor(unpack(LineColor)) end
    return i
end

return sourceRectangle