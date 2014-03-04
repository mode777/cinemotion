local modN = "[drawableTileset]"
local drawable = require(ENGINE_PATH.."/source")
local drawq = love.graphics.draw
local drawableTileset = {}

function drawableTileset.new(path, Tilewidth, Tileheight)
    local quads
    local batches = {}
    setmetatable(batches,{__mode="k"})
    local tileWidth, tileHeight


    local i = drawable.new(path)

    function i:updateSpriteBatch(Grid)
        if not batches[Grid] then
            batches[Grid] = {}
        end
    end

    function i:draw(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
        index = index or 1
        local img = i:getImage()
        if img then
            if type(index) == "number" then --if index is a single tile
                drawq(img,quads[index],0,0)
            else --if index is a grid
                local b = i:updateBatch(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
            end
        end
    end

    function i:getSize(index)
        if index then
            return tileWidth,tileHeight
        else
            local img = i:getImage()
            if tileWidth then return tileWidth, tileHeight end
            if img then return img:getWidth(), img:getHeight() end
        end
    end

    function i:getQuad(no)
        return quads[no]
    end

    function i:setTileSize(tw,th)
        quads = {}
        th = th or tw
        tileWidth,tileHeight = tw, th
        local img = i:getImage()
        if not img then error("You have to load an Image before you can set the tilesize") end
        local w,h = img:getWidth(), img:getHeight()
        for y=0,h/th-1 do
            for x=0,w/tw-1 do
                local px, py = x*tw, y*th
                table.insert(quads,love.graphics.newQuad(px,py,tw,th,w,h))
            end
        end
        print(modN,#quads.." Tiles created")
    end

    if Tilewidth then i:setTileSize(Tilewidth, Tileheight) end
    print("[drawableTileset]: Tileset loaded",path,i)
    return i
end

return drawableTileset