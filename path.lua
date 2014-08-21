local path = {}

function path.find(grid, source, target)
    local nc = 0
    local insert = table.insert
    local remove = table.remove
    local sort = table.sort
    local maxX, maxY = grid:getSize()
    local sx,sy = unpack(source)
    local tx,ty = unpack(target)
    local g = cine.grid.new(maxX,maxY)
    local ol = {}
    local resort = true
    local X,Y,PARENT,G,H,F,CLOSED = 1,2,3,4,5,6,7

    local t = love.timer.getTime()

    local function node(x,y,parent,cost)
        local abs = math.abs
        local n = {}
        n[X] = x
        n[Y] = y
        n[PARENT] = parent or nil
        n[G] = parent and parent[G] + cost or 0
        n[H] = ( abs(tx-x) + abs(ty-y) ) * 10
        n[F] = n[G] + n[H]
        return n
    end

   local function setParent(node, parent,cost)
        node[PARENT] = parent
        node[G] = parent[G] + cost
        node[F] = node[G]+node[H]
   end

    local function getNeighbours(Node) --so called successor function
        local x,y = Node[X],Node[Y]
        --define directions
        local n = { {x,y-1,10}, {x,y+1,10}, {x-1,y,10}, {x+1,y,10}, {x+1,y+1,14}, {x+1,y-1,14}, {x-1,y+1,14},{x-1,y-1,14} }
        for i =1, #n do
            local x,y,cost = n[i][1], n[i][2],n[i][3]
            local occupied = g:getCell(x,y)
            --print(occupied and occupied[CLOSED])
            local passable = x > 0 and y > 0 --not wall
                    and x <= maxX and y <= maxY
                    and grid:getCell(x,y) == 0 --passable
                    and not (occupied and occupied[CLOSED])--not in closed list
            if passable then
                local oldNode = occupied
                if oldNode then --note already exists
                    if Node[G]+cost < oldNode[G] then
                        setParent(oldNode,Node,cost)
                    end
                else
                    local newNode = node(x,y,Node,cost)
                    g:setCell(x,y,newNode)
                    insert(ol,newNode)
                end
            end
        end
    end
    --[[
    local function passable(x,y)
        --local occupied = g:getCell(x,y)
        return x > 0 and y > 0 --not wall
                and x <= maxX and y <= maxY
                and grid:getCell(x,y) == 0 --passable
                --and not (occupied and occupied[CLOSED])--not in closed list
    end

    local function jump(X,Y,dX,dY,Node,cost)
        local x = X+dX
        local y = Y+dY
        --print(x,y)
        --local diagonal

        if not passable(x,y) then return end

        if x == target[X] and y == target[Y] then return node(x,y,Node,cost) end

        local oX = x
        local oY = y

        --Diagonal case
        if dX ~= 0 and dY ~= 0 then
            while true do
                if (passable(oX - dX, oY + dY) and
                   not passable(oX - dX, oY)) or
                   (passable(oX - dX, oY - dY) and
                   not passable(oX, oY - dY))
                then
                    return node(oX,oY,Node,cost)
                end

                if (jump(oX,oY, dX, 0, Node,cost+10) or jump(oX,oY,0,dY, Node,cost+10)) then
                    return node(oX,oY,Node,cost)
                end

                oX = oX + dX
                oY = oY + dY

                if not passable(oX,oY) then
                    return
                end

                if oX == target[X] and oY == target[Y] then
                    return node(oX,oY,Node,cost)
                end
            end
            cost = cost + 14
        else -- Straight case

            if dX ~= 0 then
                while true do
                    if (passable(oX + dX, y + 1) and
                        not passable(oX, Y + 1)) or
                       (passable(oX + dX, y - 1) and
                       not passable (oX, y -1))
                    then
                        return node(oX,y,Node,cost)
                    end

                    oX = oX + dX

                    if not passable(oX, y) then
                        return
                    end

                    if oX == target[X] and y == target[y] then
                        return node(oX, y, Node, cost)
                    end
                end
            else
                while true do
                    if (passable(x + 1, oY + dY) and
                       not passable(x + 1, oY)) or
                       (passable(x - 1, oY + dY) and
                       not passable(x - 1, oY))
                    then
                        return node(x, oY)
                    end

                    oY = oY + dY

                    if not passable(x, oY) then
                        return
                    end

                    if x == target[X] and oY == target[Y] then
                        return node(x, oY)
                    end
                end
            end
            cost = cost +10
        end
        return jump(x,y,dX,dY, Node, cost)
    end

    local function getNeighbours(Node) --so called successor function
        local x,y = Node[X],Node[Y]
        --define directions
        local n = { {x,y-1,10}, {x,y+1,10}, {x-1,y,10}, {x+1,y,10}, {x+1,y+1,14}, {x+1,y-1,14}, {x-1,y+1,14},{x-1,y-1,14} }
        for i =1, #n do
            local dX = math.min(math.max(-1, n[i][X] - Node[X]), 1)
            local dY = math.min(math.max(-1, n[i][Y] - Node[Y]), 1)

            local result = jump(Node[X],Node[Y],dX,dY,Node,n[i][3])
            if result then
                insert(ol,result)
            end
        end
    end
    ]]
    --start
    local startNode = node(sx,sy)
    g:setCell(sx,sy,startNode)
    insert(ol, startNode)

    local currentNode
    local result

    while true do
        local lowest = ol[1][F]
        local index = 1
        for i=2, #ol do
            if ol[i][F] < lowest then
                lowest = ol[i][F]
                index = i
            end
        end
        currentNode = ol[index]
        if not currentNode then result="fail" break end
        --remove lowest from cl and add to cl
        local lx,ly = currentNode[X],currentNode[Y]
        currentNode[CLOSED] = true
        if lx == tx and ly == ty then result="success" break end
        resort = false
        getNeighbours(currentNode)
        remove(ol,index)
        nc = nc+1
    end
    print(love.timer.getTime()-t, "Nodes visited:", nc)
    if result == "success" then
        local path = {}
        local currentNode = g:getCell(tx,ty)
        while currentNode[PARENT] do
            insert(path, 1, {currentNode[X], currentNode[Y]})
            currentNode = currentNode[PARENT]
        end
        return path
    else
        return nil
    end
end

return path