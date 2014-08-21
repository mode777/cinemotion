local sourceImage = require(ENGINE_PATH.."/sourceImage")
local serialize = require(ENGINE_PATH.."/serialize")
local drawq = love.graphics.draw
local drawableSpritesheet = {}

function drawableSpritesheet.loadAnimationSheet()
end

function drawableSpritesheet.load(name)
    local sheet
    local fs = love.filesystem
    sheet = serialize.CSVToDictionary(name..".csv",";")
    local drawable = drawableSpritesheet.new(name..".png")-- TODO: LOAD DRAWABLE OBJECT DRAWABLE SPRITESHEET

    for i, frame in ipairs ( sheet ) do
        drawable:addRectangle(frame.x,frame.y,frame.w,frame.h,frame.name,frame.originalw,frame.originalh,frame.offsetx,frame.offsety)
    end
    return drawable
end

function drawableSpritesheet.new(path)
    local rectangles = {}
    local rectanglesList = {}
    print(path)
    local i = sourceImage.new(path)
    function i:draw(sprite)
        local index = sprite:getIndex()
        index = type(index) == "string" and index or rectanglesList[index]
        local img = i:getImage()
        if index and img then
            if img then drawq(img,rectangles[index],0,0) end
        end
    end

    function i:getSize(sprite)
        local index = sprite:getIndex()
        index = type(index) == "string" and index or rectanglesList[index]
        local img = i:getImage()
        local w,h
        if index then
            _,_,w,h = rectangles[index]:getViewport()
            return w,h
        else
            return img:getWidth(), img:getHeight()
        end
    end

    function i:getRectangle(id)
        return rectangles[id]
    end

    function i:addRectangle(x,y,w,h,id)
        local sw,sh = i:getImage():getWidth(),i:getImage():getHeight()
        local rect = love.graphics.newQuad(x,y,w,h,sw,sh)
        rectangles[id] = rect
        table.insert(rectanglesList, id)
    end

    function i:getIndices()
        local index = {}
        for i,_ in pairs(rectangles) do
            table.insert(index,i)
        end
        return index
    end

    print("[drawableSpritesheet]: Sheet loaded",path,i)
    return i
end

return drawableSpritesheet