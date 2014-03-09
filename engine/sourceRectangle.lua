local sourceRectangle = {}

function sourceRectangle.new()
    local i = {}
    function i:draw(index)
        if index then love.graphics.rectangle("fill",0,0,unpack(index)) end
    end
    function i:getSize(index)
        if type(index) ~= "table" then return error("sourceRectangle needs a table as index. Given: "..tostring(index)) end
        if index then
            return index[1],index[2]
        else
            return 0,0
        end
    end
    return i
end

return sourceRectangle