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

    local i = {}

    function i:setPos(X,Y)
        x,y = X,Y
        self:updateBBOx()
    end

    function i:getPos()
        return x,y
    end

    local moveTween
    function i:movePos(X,Y,T)
        if moveTween then moveTween:kill() end
        if not T then
            x,y = x+X, y+Y
            self:updateBBox()
        else
            local moveTween = tween.new({x,y},{x+X,y+Y},T,function(X,Y) x,y = X,Y self:updateBBox() end)
            return moveTween
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
            local movRot = tween.new({rot},{rot+Rot},T,function(Rot) rot = Rot end)
            return movRot
        end
    end
    function i:moveRotTo(Rot,T)
        Rot = Rot - rot
        self:moveRot(Rot,T)
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
            local movSca = tween.new({scax,scay},{scax+SX,scay+SY},T,function(SX,SY) scax,scay = SX,SY end)
            return movSca
        end
    end

     function i:setSca(SX,SY)
         scax,scay = SX,SY
     end

    function i:getSca()
        return scax,scay
    end

    function i:moveScaTo(SX,SY,T)
        SY = SY or SX
        SX,SY = SX-scax, SY-scay
        return i:moveSca(SX,SY,T)
    end

    function i:updateBBox()
        if hash then
            local ox1,oy1,ox2,oy2 = self:getBBox()
            hash:updateSprite(self,ox1,oy1,ox2,oy2,x-pivx,y-pivy,x+w-pivx,y+h-pivy)
        end
        bbox = {f(x-pivx),f(y-pivy),f(x+w-pivx),f(y+h-pivy)}
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