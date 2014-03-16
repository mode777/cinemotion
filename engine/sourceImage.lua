local drawable = require(ENGINE_PATH.."/source")
local drawableImage = {}

function drawableImage.new(path)
    local i = drawable.new(path)

    function i:draw()
        local img = i:getImage()
        if img then love.graphics.draw(img,0,0) end
    end

    function i:getSize()
        local img = i:getImage()
        print("image",img)
        if img then print(img:getWidth(), img:getHeight()) return img:getWidth(), img:getHeight() end
    end
    print("[drawableImage]: Image loaded",path,i)
    return i
end

return drawableImage