local asset = require(ENGINE_PATH.."/asset")
local drawableImage = {}

function drawableImage.new(Path)
    local i = {}
    local img

    function i:draw(sprite)
        local img = i:getImage()
        local iw,ih = self:getSize()
        local sw,sh = sprite:getSize()

        if img then love.graphics.draw(img,0,0,0,sw/iw,sh/ih) end
    end

    function i:getSize()
        local img = i:getImage()
        if img then return img:getWidth(), img:getHeight() end
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