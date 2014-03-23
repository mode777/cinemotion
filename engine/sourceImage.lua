local asset = require(ENGINE_PATH.."/asset")
local drawableImage = {}

function drawableImage.new(Path)
    local i = {}
    local img

    function i:draw()
        local img = i:getImage()
        if img then love.graphics.draw(img,0,0) end
    end

    function i:getSize()
        local img = i:getImage()
        print("image",img)
        if img then print(img:getWidth(), img:getHeight()) return img:getWidth(), img:getHeight() end
    end

    function i:getImage()
        return img
    end

    function i:setImage(Filename)
        img = love.graphics.newImage(Filename)
        asset.set(Filename, img)
    end

    if Path then i:setImage(Path) end
    return i
end

return drawableImage