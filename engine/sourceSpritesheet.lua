local sourceImage = require(ENGINE_PATH.."/sourceImage")
local drawq = love.graphics.draw
local drawableSpritesheet = {}

function drawableSpritesheet.new(path)
    local quads

    local i = sourceImage.new(path)

    function i:draw(sprite)
        local index = sprite:getIndex() or 1
        local img = i:getImage()
        if img then drawq(img,quads[index],0,0) end
    end

    function i:getSize(index)
        local img = i:getImage()
        local w,h
        if index then
            _,_,w,h = quads[id]:getViewport()
        else
            return img:getWidth(), img:getHeight()
        end
    end

    function i:getQuad(no)
        return quads[no]
    end

    function i:addQuad(x,y,w,h,id)
        if not quads then quads = {} end
        local sw,sh = i:getImage():getWidth(),i:getImage():getHeight()
        local quad = love.graphics.newQuad(x,y,w,h,sw,sh)
        if id then
            quads[id] = quad
        else
            table.insert(quads, quad)
        end
    end
    print("[drawableSpritesheet]: Sheet loaded",path,i)
    return i
end

return drawableSpritesheet