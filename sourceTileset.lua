local modN = "[drawableTileset]"
local sourceImage = require(ENGINE_PATH.."/sourceImage")
local grid = require(ENGINE_PATH.."/grid")
local drawq = love.graphics.draw
local min = math.min
local abs = math.abs
local drawableTileset = {}

function drawableTileset.new(path, Tilewidth, Tileheight)
    local quads
    local batches = {}
    local FLIPX, FLIPY = 2147483648, 1073741824
    setmetatable(batches,{__mode="k"})
    local tileWidth, tileHeight


    local i = sourceImage.new(path)

    function i:createSpriteBatch(Grid)
        --create a grid for spritebatch quads, fill it with ids, fill the spritebatch with empty quads
        local tx,ty = Grid:getSize()
        local batch = love.graphics.newSpriteBatch(i:getImage(),tx*ty,"dynamic")
        batch:bind()
        for y = 0, ty-1 do
            for x = 0, tx-1 do
                local flipx,flipy = 1,1
                local quadid = Grid:getCell(x+1,y+1) --or 0
                if quadid > FLIPX+FLIPY then quadid = quadid - FLIPX - FLIPY flipx=-1 flipy=-1
                elseif quadid > FLIPX then quadid = quadid - FLIPX flipx = -1
                elseif quadid > FLIPY then quadid = quadid - FLIPY flipy = -1
                end
                if quadid ~= 0 then
                    --batch:add(0,0,0,0,0)
                    local qx,qy = x*tileWidth,y*tileHeight
                    if flipx == -1 then qx = qx+tileWidth end
                    if flipy == -1 then qy = qy+tileHeight end
                    batch:add(i:getQuad(quadid),qx,qy,0,flipx,flipy)
                else
                    batch:add(0,0,0,0)
                end
            end
        end
        batch:unbind()
        batches[Grid] = batch
    end


    function i:draw(sprite)
        local index = sprite:getIndex() or 1
        if index.getIndex then index = index:getIndex() end
        local img = i:getImage()
        if img then
            if type(index) == "number" then --if index is a single tile
                drawq(img,quads[index],0,0)
            else --if index is a grid
                if not batches[index] then print("Creating a new sprite batch for grid"..tostring(index)) self:createSpriteBatch(index) end
                drawq(batches[index],0,0)
            end
        end
    end

    function i:getSize(sprite)
        local index = sprite:getIndex()
        if index then
            if type(index) == "number" then
                return tileWidth,tileHeight
            elseif index.getIndex then
                index = index:getIndex()
            else
                local w,h = index:getSize()
                return w*tileWidth,h*tileHeight
            end
        else
            local img = i:getImage()
            if img then return img:getWidth(), img:getHeight() end
        end
    end

    function i:getQuad(no)
        return quads[no]
    end

    function i:getBatch(grid)
        return batches[grid]
    end

    function i:setTileSize(tw,th)
        quads = { }
        th = th or tw
        tileWidth,tileHeight = tw, th
        local img = i:getImage()
        if not img then error("You have to load an Image before you can set the tilesize") end
        local w,h = img:getWidth(), img:getHeight()
        for y=0,h/th-1 do
            for x=0,w/tw-1 do
                local px, py = x*tw, y*th
                table.insert( quads,love.graphics.newQuad(px,py,tw,th,w,h) )
            end
        end
        print(modN,#quads.." Tiles created")
    end

    function i:getTileSize()
        return tileWidth,tileHeight
    end

    if Tilewidth then i:setTileSize(Tilewidth, Tileheight) end
    i:getImage():setFilter('nearest','nearest') --border fix
    print("[sourceTileset]: Tileset loaded",path,i)
    return i
end

return drawableTileset