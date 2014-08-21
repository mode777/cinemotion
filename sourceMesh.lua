local sourceMesh = {}
local sourceImage = require(ENGINE_PATH.."/sourceImage")
local grid = require(ENGINE_PATH.."/grid")

function sourceMesh.new(filename, subX, subY)
    local i = sourceImage.new(filename)
    local subX, subY = subX or 1, subY or 1
    local img = i:getImage()
    local w,h = img:getWidth(), img:getHeight()

    local vertices = {}

    for y=0,subY do
        for x=0,subX do
            local vertex ={}
            vertex[1] = x*(w/subX)
            vertex[2] = y*(h/subY)
            vertex[3] = x*(1/subX)
            vertex[4] = y*(1/subY)
            table.insert(vertices,vertex)
        end
    end

    local grid = grid.new(subX+1,subY+1,vertices)

    local list = {}

    for y=1, subY do
        for x=1, subX do --create patches
            local p1, p2, p3, p4 = grid:getIndex(x,y), grid:getIndex(x+1,y), grid:getIndex(x+1,y+1), grid:getIndex(x,y+1)
            table.insert(list, p1)
            table.insert(list, p2)
            table.insert(list, p3)
            table.insert(list, p1)
            table.insert(list, p3)
            table.insert(list, p4)
        end
    end

    local mesh = love.graphics.newMesh( vertices, img, "triangles" )
    mesh:setVertexMap(list)

    function i:draw()
        love.graphics.draw(mesh,0,0)
    end

    function i:moveVertex(x,y,ox,oy)
        local vertex = grid:getCell(x,y)
        vertex[1] = vertex[1]+ox
        vertex[2] = vertex[2]+oy
        mesh:setVertex(grid:getIndex(x,y), vertex[1], vertex[2], vertex[3], vertex[4])
    end

    function i:applyTransformation(t)
        for i=1, (subX+1)*(subY+1) do
            if t[i] then
                local vertex = grid:getData()[i]
                mesh:setVertex(i, vertex[1]+t[i][i], vertex[2]+t[i][2], vertex[3], vertex[4])
            end
        end
    end

    function i:applySine(a,o,s,fx,fy,switch,ignoreX,ignoreY)
        --a = amplitude
        --o = offset
        --s = scale
        --fx = scale factor x
        --fy = scale factor y
        --switch = switch x,y
        --ignore = ignore edges
        local o = o or 0
        local s = s or 1
        local lowerX,lowerY,upperX,upperY = 1,1,grid:getWidth() ,grid:getHeight()
        if ignoreX == "left" then
            lowerX = lowerX+1
        elseif ignoreX == "right" then
            upperX = upperX-1
        elseif ignoreX == "all" then
            upperX = upperX-1
            lowerX = lowerX+1
        end
        if ignoreY == "top" then
            lowerY = lowerY+1
        elseif ignoreY == "bottom" then
            upperY = upperY-1
        elseif ignoreY == "all" then
            upperY = upperY-1
            lowerY = lowerY+1
        end
        for y=lowerY, upperY do
            for x=lowerX,upperX do
                local lx = switch and (y/grid.getWidth())*(math.pi*s) or (x/grid.getWidth())*(math.pi*s)
                local ly = math.sin(lx+o)*a
                local vertex = grid:getCell(x,y)
                mesh:setVertex(grid:getIndex(x,y), vertex[1]+ly*fx, vertex[2]+ly*fy, vertex[3], vertex[4])
            end
        end
    end

    return i
end

return sourceMesh