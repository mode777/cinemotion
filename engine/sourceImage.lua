local drawable = require(ENGINE_PATH.."/source")
local drawableImage = {}

function drawableImage.new(path)
    local i = drawable.new(path)

    function i:draw(x,y)
        local img = i:getImage()
        if img then love.graphics.draw(img,x,y) end
    end

    function i:getSize()
        local img = i:getImage()
        if img then return img:getWidth(), img:getHeight() end
    end
    print("[drawableImage]: Image loaded",path,i)
    return i
end

return drawableImage