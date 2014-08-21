local layer = require(ENGINE_PATH.."/layer")
local grid = require(ENGINE_PATH.."/grid")

local layerTile = {}

function layerTile.new(Source, Grid, Size)
    local f,c = math.floor, math.ceil
    local size = Size or math.min(16,Grid:getWidth(),Grid:getHeight())
    local tx, ty = Source:getTileSize()
    local instance = layer.new(tx*size,ty*size)
    local spriteGrid = grid.new(c(Grid:getWidth()/size),c(Grid:getHeight()/size))
    --creates Macrotiles
    for y = 1, Grid:getHeight(), size do
        for x = 1, Grid:getWidth(), size do
            local g = Grid:getSubgrid(x,y,size,size)
            local sprite = cine.sprite.new((x-1)*tx,(y-1)*ty,Source,g)
            sprite:setZIndex(0)
            instance:insertSprite(sprite)
            Source:createSpriteBatch(g)
            spriteGrid:setCell(f(x/size)+1,f(y/size)+1,sprite)
        end
    end

    function instance:setTile(x,y,id)
        Grid:setCell(x,y,id)
        local ox,oy = c(x/size), c(y/size)
        local sprite = spriteGrid:getCell(ox,oy)
        local subgrid = sprite:getIndex()
        local batch = Source:getBatch(subgrid)
        local nx,ny = x-(ox-1)*size,y-(oy-1)*size
        subgrid:setCell(nx,ny,id)
        local index = subgrid:getIndex(nx,ny)-1
        if id ~= 0 then
            batch:set(index,Source:getQuad(id),(nx-1)*tx,(ny-1)*ty)
        else
            batch:set(index,0,0,0,0,0)
        end
    end

    function instance:getTile(x,y)
        return Grid:getCell(x,y)
    end

    function instance:getWidth()
        return Grid:getWidth()
    end

    function instance:getHeight()
        return Grid:getHeight()
    end

    function instance:getPixelWidth()
        return Grid:getWidth()*tx
    end

    function instance:getPixelHeight()
        return Grid:getHeight()*ty
    end

    local ox,oy = 0,0
    function instance:setOffset(x,y)
        x,y = x-ox, y-oy
        local sprites = spriteGrid:getData()
        for i=1, #sprites do
            sprites[i]:movePos(x,y)
        end
    end

    function instance:getGrid()
        return Grid
    end

    local autoTiles
    local autotile_grid

    local function getAutoTile()
        --todo Very ineffective. Only set neighbouring tiles. Auto apply Autotile changes!
        local changes = {}
        for y=1, Grid:getHeight() do
            for x=1, Grid:getWidth() do
                local buffer = {}
                table.insert(buffer, autotile_grid:getCell(x,y))
                table.insert(buffer, autotile_grid:getCell(x+1,y))
                table.insert(buffer, autotile_grid:getCell(x+1,y+1))
                table.insert(buffer, autotile_grid:getCell(x,y+1))
                local id = table.concat(buffer)
                if not (Grid:getCell(x,y) == autoTiles[id]) then table.insert(changes,{x,y,autoTiles[id]}) end
            end
        end
        return changes
    end

    local function getAutotileID(id)
        for i,v in pairs(autoTiles) do
            if v == id then return i end
        end
    end

    local function createAutoTileGrid()
        local agrid = cine.grid.new(Grid:getWidth()+1,Grid:getHeight()+1)
        for y=1, Grid:getHeight() do
            for x=1, Grid:getWidth() do
                local aid = getAutotileID(Grid:getCell(x,y))
                agrid:setCell(x,y,aid and tonumber(string.sub(aid,1,1)) or 0)
                if x==Grid:getWidth() then
                    agrid:setCell(x+1,y,aid and tonumber(string.sub(aid,2,2)) or 0)
                end
                if y==Grid:getHeight() then
                    agrid:setCell(x,y+1,aid and tonumber(string.sub(aid,4,4)) or 0)
                end
                if x==Grid:getWidth() and y==Grid:getHeight() then
                    agrid:setCell(x+1,y+1,aid and tonumber(string.sub(aid,3,3)) or 0)
                end
            end
        end
        return agrid
    end

    function instance:applyAutoTile()
        local changes = getAutoTile()
        for i=1, #changes do
            self:setTile(unpack(changes[i]))
        end
    end

    function instance:createAutoTile(...)
        local t={...}
        local tiles = {
            ["0000"] = t[1],
            ["0011"] = t[2],
            ["0110"] = t[3],
            ["1001"] = t[4],
            ["1111"] = t[5],
            ["1100"] = t[6],
            ["0101"] = t[7],
            ["1010"] = t[8],
            ["0010"] = t[9],
            ["0001"] = t[10],
            ["1101"] = t[11],
            ["1110"] = t[12],
            ["0100"] = t[13],
            ["1000"] = t[14],
            ["1011"] = t[15],
            ["0111"] = t[16],
        }
        autoTiles = tiles
        autotile_grid = createAutoTileGrid()
        self:applyAutoTile()
    end

    function instance:setAutoTile(x,y,id)
        id = id==0 and 0 or 1
        autotile_grid:setCell(x,y,id)
    end

    function instance:getAutoTile(x,y)
        return autotile_grid:getCell(x,y)
    end

    return instance
end

return layerTile