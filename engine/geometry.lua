local time = love.timer.getTime
local thread = require(ENGINE_PATH.."/thread")
local tween = require(ENGINE_PATH.."/tween")

local geometry = {}

function geometry.new(X,Y,W,H)
    local visible = true
    local x,y = 0,0
    local rot = 0
    local scax,scay = 1,1
    local w,h = 0,0
    local hash
    local f = math.floor
    local lwidth
    local pivx, pivy = 0,0
    local bbox = {0,0,0,0}

    local i = tween.new()

    function i:setPos(X,Y)
        --TODO: Broken!
        --x,y = math.max(X,0),math.max(Y,0)
    end

    function i:getPos()
        return x,y
    end

    local movPos
    function i:movePos(X,Y,T)
        if movPos then movPos:kill() end
        if not T then
            x,y = x+X, y+Y
            self:updateBBox()
        else
            movPos = thread.new(function()
                local startT = time()
                local oldx, oldy = x,y
                local style = self:getTweenStyle()
                local t = time()
                while T+startT > t do
                    t = time()
                    local nx,ny = i:tween(t-startT, oldx, X, T,style), i:tween(t-startT, oldy, Y, T,style)
                    if nx~=x or ny~=y then
                        x,y = nx, ny
                        self:updateBBox()
                    end
                    thread.yield()
                end
                x,y = oldx+X, oldy+Y
                self:updateBBox()
            end)
            movPos:run()
            return movPos
        end
    end

    function i:movePosTo(X,Y,T)
        X,Y = X-x, Y-y
        return i:movePos(X,Y,T)
    end

    local movRot
    function i:moveRot(Rot,T)
        if movRot then movRot:kill() end
        if not T then
            rot = rot+Rot
        else
            movRot = thread.new(function()
                local startT = time()
                local oldrot = rot
                local style = self:getTweenStyle()
                while T+startT > time() do
                    rot = i:tween(time()-startT, oldrot, Rot, T,style)
                    thread.yield()
                end
            end)
            movRot:run()
        end
        return movRot
    end

    function i:setRot(Rot)
        rot = Rot
    end

    function i:getRot()
        return rot
    end

    local movSca
    function i:moveSca(SX,SY,T)
        SY = SY or SX
        if movSca then movSca:kill() end
        if not T then
            scax,scay = scax+SX, scay+SY
        else
            movSca = thread.new(function()
                local style = self:getTweenStyle()
                local startT = time()
                local oldx, oldy = scax,scay
                while T+startT > time() do
                    scax,scay = i:tween(time()-startT, oldx, SX, T,style), i:tween(time()-startT, oldy, SY, T,style)
                    thread.yield()
                end
            end)
            movSca:run()
        end
        return movSca
    end

     function i:setSca(SX,SY)
         scax,scay = SX,SY
     end

    function i:getSca()
        return scax,scay
    end

    function i:moveScaTo(SX,SY,T)
        SX,SY = SX-scax, SY-scay
        return i:moveSca(SX,SY,T)
    end

    function i:setHash(Hash)
        hash = Hash
    end

    function i:getHash()
        return hash
    end

    function i:updateBBox()
        if hash then
            local ox1,oy1,ox2,oy2 = self:getBBox()
            hash:updateSprite(self,ox1,oy1,ox2,oy2,x-pivx,y-pivy,x+w-pivx,y+h-pivy)
        end
        bbox = {x-pivx,y-pivy,x+w-pivx,y+h-pivy}
    end

    function i:getBBox()
        return unpack(bbox)
    end

    function i:setSize(W,H)
        w,h = W,H
        self:updateBBox()
    end

    function i:getSize()
        return w,h
    end

    function i:setLineWidth(W) --only in connection with text drawables
        lwidth = W
    end

    function i:getLineWidth()
        return lwidth
    end

    if X and Y then i:movePosTo(X,Y) end
    if W and H then i:setSize(W,H) end
    i:updateBBox()
    return i
end

return geometry