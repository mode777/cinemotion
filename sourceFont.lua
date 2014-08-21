local drawableFont = {}
local asset = require(ENGINE_PATH.."/asset")
function drawableFont.new(path, size)
    local i = {}
    local fnt
    function i:getFont()
        return fnt
    end

    function i:setFont(path, size)
        path = path or "standartFont"
        fnt = love.graphics.newFont(path, size)
        asset.set(path,fnt)
    end

    function i:getSize(sprite)
        local index = sprite:getIndex()
        if index then
            local width, lines = fnt:getWrap(index, sprite.getLineWidth() or math.huge)
            return width, lines*fnt:getHeight()
        else
            return 0, fnt:getHeight()
        end
    end

    function i:getLineHeight()
        return fnt:getHeight()
    end

    function i:draw(sprite)
        local text = sprite:getIndex() or ""
        local w,_ = sprite:getSize()
        local ofnt = love.graphics.getFont()
        if fnt then love.graphics.setFont(fnt) end
        love.graphics.printf( text, 0, 0, w)
        love.graphics.setFont(ofnt)
    end

    if path or size then i:setFont(path, size) else
        fnt = love.graphics.getFont()
    end
    print("[drawableFont]: Font loaded",path,size,i)
    return i
end
return drawableFont
