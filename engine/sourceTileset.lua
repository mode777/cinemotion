local modN = "[drawableTileset]"
local drawable = require(ENGINE_PATH.."/source")
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


    local i = drawable.new(path)

    local function createSpriteBatch(Grid,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
        --determine if object if bigger than screen
        local screenW, screenH = math.ceil((sx2-sx1)/tileWidth)+1, math.ceil((sy2-sy1)/tileHeight)+1
        local gridW, gridH = Grid:getSize()
        local batchW,batchH = math.min(screenW,gridW),math.min(screenH,gridH)
        --create a grid for spritebatch quads, fill it with ids, fill the spritebatch with empty quads
        local batchGrid = grid.new(batchW,batchH)
        local batch = love.graphics.newSpriteBatch(i:getImage(),batchW*batchH)
        for y=1, batchH do
            for x=1, batchW do
                batchGrid:setCell(x,y,batch:add(0, 0, 0, 0, 0))
            end
        end
        --return all relevant data in a table. Set offset to negative grid size to force complete reconstruction of batch
        --on update
        print("created a spritebatch, size: "..tostring(batchW*batchH))
        print(batchW,batchH)
        return {batch=batch,grid=batchGrid,offsetX=-batchW-1,offsetY=-batchH-1}
    end

    local function updateSpriteBatch(Grid,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
        local batch = batches[Grid]
        local mapX, mapY = Grid:getSize()
        --normalize screen rectangle, make upper right corner of object always 0,0
        --sx1,sy1 = ox1-sx1, oy1-sy1
        --todo what happens if screen rectangle is not entirely inside object rectangle??
        --get tile coordinates for upper right corner of screen rectangle
        local offsetX, offsetY = math.floor(sx1/tileWidth), math.floor(sy1/tileHeight)
        --calculate the offset from the last update
        local deltaOffsetX, deltaOffsetY = offsetX-batch.offsetX, offsetY-batch.offsetY
        if deltaOffsetX == 0 and deltaOffsetY == 0 then return batch.batch end --stop if no update is necessary
        --print("An update is necessary. Delta offsets:", deltaOffsetX,deltaOffsetY)
        batch.offsetX, batch.offsetY = offsetX,offsetY
        batch.batch:bind()
        local batchX,batchY = batch.grid:getSize()

        for y = offsetY, min(offsetY+batchY-1,mapY-1) do
            for x = offsetX, min(offsetX+batchX-1,mapX-1) do
                local quadid = Grid:getCell(x+1,y+1) --or 0
                --print(quadid)
                if x<0 or y<0 then quadid = 0 end
                if quadid > FLIPX+FLIPY then quadid = quadid - FLIPX - FLIPY
                elseif quadid > FLIPX then quadid = quadid - FLIPX
                elseif quadid > FLIPY then quadid = quadid - FLIPY
                end
                --four cases
                if ((deltaOffsetY >= 0 and deltaOffsetX >= 0) and (x > batchX-deltaOffsetX or y > batchY-deltaOffsetY)) -- 1,1
                or ((deltaOffsetY <= 0 and deltaOffsetX <= 0) and (x < abs(deltaOffsetX) or y < abs(deltaOffsetY))) -- -1,-1
                or ((deltaOffsetY >= 0 and deltaOffsetX <= 0) and (x > batchX-deltaOffsetX or y < abs(deltaOffsetY))) -- 1,-1
                or ((deltaOffsetY <= 0 and deltaOffsetX >= 0) and (x < abs(deltaOffsetX) or y > batchY-deltaOffsetY)) -- -1,1
                then
                    if quadid ~= 0 then
                        --print("Adding new quads",batch.grid:getCell(x+1,y+1),i:getQuad(quadid),x,y)
                        batch.batch:set(batch.grid:getCell(x+1,y+1),i:getQuad(quadid),x*tileWidth,y*tileHeight)
                    else
                        --print("Adding empty quads",batch.grid:getCell(x+1,y+1),x,y)
                        batch.batch:set(batch.grid:getCell(x+1,y+1),0,0,0,0,0) --add an empty quad
                    end
                end
            end
        end
        batch.batch:unbind()
        return batch.batch
    end

    function i:draw(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
        index = index or 1
        local img = i:getImage()
        if img then
            if type(index) == "number" then --if index is a single tile
                drawq(img,quads[index],0,0)
            else --if index is a grid
                if not batches[index] then print("Creating a new sprite batch for grid"..tostring(index)) batches[index] = createSpriteBatch(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2) end
                local b = updateSpriteBatch(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2)
                drawq(b,0,0)
            end
        end
    end

    function i:getSize(index)
        if index then
            if type(index) == "number" then
                return tileWidth,tileHeight
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
    print("[sourceTileset]: Tileset loaded",path,i)
    return i
end

return drawableTileset