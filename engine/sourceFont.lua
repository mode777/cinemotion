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

    function i:getSize(index, lineWidth)
        if index then
            local width, lines = fnt:getWrap(index, lineWidth or math.huge)
            return width, lines*fnt:getHeight()
        else
            return 0, fnt:getHeight()
        end
    end

    function i:draw(text)
        text = text or ""
        local ofnt = love.graphics.getFont()
        if fnt then love.graphics.setFont(fnt) end
        love.graphics.print(text,0,0)
        love.graphics.setFont(ofnt)
    end

    if path or size then i:setFont(path, size) end
    print("[drawableFont]: Font loaded",path,size,i)
    return i
end
return drawableFont
