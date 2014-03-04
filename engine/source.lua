local drawable = {}

function drawable.new(path,ind)
    local img, index
    local i = {}
    function i:setImage(path)
        img = love.graphics.newImage(path)
    end

    function i:getImage()
        return img
    end

    if path then i:setImage(path) end

    return i
end

return drawable

