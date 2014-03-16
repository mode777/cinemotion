local tween = require(ENGINE_PATH.."/tween")
local event = require(ENGINE_PATH.."/event")

local geometry = {}

function geometry.new(X,Y,W,H)
    local x,y = 0,0
    local rot = 0
    local scax,scay = 1,1
    local w,h = 0,0
    local pivx, pivy = 0,0
    local lwidth
    local bbox
    local rectangle
    local tweenStyle
    local geoModel = "full"
    local layer
    local f = math.floor
    local cos = math.cos
    local sin = math.sin
    local min = math.min
    local max = math.max

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
            self:updateTransformation()
        else
            moveTween = tween.new({x,y},{x+X,y+Y},T,function(X,Y) x,y = X,Y self:updateTransformation() end,tweenStyle)
            return moveTween
        end
    end

    function i:movePosTo(X,Y,T)
        X,Y = X-x, Y-y
        return i:movePos(X,Y,T)
    end

    local pivotTween
    function i:movePiv(X,Y,T)
        if pivotTween then pivotTween:kill() end
        if not T then
            pivx,pivy = pivx+X, pivy+Y
            self:updateTransformation()
        else
            local pivotTween = tween.new({pivx,pivy},{pivx+X,pivy+Y},T,function(X,Y) pivx, pivy = X,Y self:updateTransformation() end,tweenStyle)
            return pivotTween
        end
    end

    function i:movePivTo(X,Y,T)
        X,Y = X-pivx,Y-pivy
        return i:movePiv(X,Y,T)
    end

    function i:getPiv()
        return pivx,pivy
    end

    function i:center()
        local w,h = self:getSize()
        self:movePivTo(w/2,h/2)
    end

    local movRot
    function i:moveRot(Rot,T)
        if movRot then movRot:kill() end
        if not T then
            rot = rot+Rot
            if geoModel=="full" then self:updateTransformation() end
        else
            movRot = tween.new({rot},{rot+Rot},T,function(Rot)
                rot = Rot
                if geoModel=="full" then self:updateTransformation() end
            end, tweenStyle)
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
    --todo : scaling is glitchy
    local movSca
    function i:moveSca(SX,SY,T)
        SY = SY or SX
        if movSca then movSca:kill() end
        if not T then
            scax,scay = scax*SX, scay*SY
            if geoModel=="full" then self:updateTransformation() end
        else
            movSca = tween.new({scax,scay},{scax*SX,scay*SY},T,function(SX,SY) scax,scay = SX,SY if geoModel=="full" then self:updateTransformation() end end, tweenStyle)
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
        SX,SY = SX/scax, SY/scay
        return i:moveSca(SX,SY,T)
    end

    function i:setGeometryModel(Type)
        if not (Type == "bbox" or Type == "full" or Type == "point") then error("Geometry model has to be either 'bbox','full' or 'point'") end
        geoModel = Type
        self:updateTransformation()
    end

    function i:getGeometryModel()
        return geoModel
    end

    function i:transformPoint(X,Y) --apply current transformation state to a given point
        --pivot
        X,Y = X-pivx, Y-pivy
        --scale
        if scax ~= 1 and scay ~= 1 then X,Y = X*scax, Y*scay end
        --rotate
        if rot ~= 0 then
            local c, s = cos(rot), sin(rot)
            X,Y = c*X - s*Y, s*X + c*Y
        end
        --transform
        X, Y = X+x, Y+y
        return X,Y
    end

    function i:projectPoint(X,Y) --project a arbitrary point to current geometry space (0,0,w,h)
        --transform
        X, Y = X-x, Y-y
        --rotate
        if rot ~= 0 then
            local c, s = cos(-rot), sin(-rot)
            X,Y = c*X - s*Y, s*X + c*Y
        end
        --scale
        if scax ~= 1 and scay ~= 1 then X,Y = X/scax, Y/scay end
        --pivot
        X,Y = X+pivx, Y+pivy
        return X,Y
    end

    function i:updateTransformation()
        local ox1,oy1,ox2,oy2 = self:getBBox()
        local nx1,ny1,nx2,ny2
        if geoModel == "bbox" then
            nx1,ny1,nx2,ny2 = f(x-pivx),f(y-pivy),f(x+w-pivx),f(y+h-pivy)
        elseif geoModel == "full" then
            local x1,y1 = self:transformPoint(0,0)
            local x2,y2 = self:transformPoint(w,0)
            local x3,y3 = self:transformPoint(w,h)
            local x4,y4 = self:transformPoint(0,h)
            nx1 = min(x1,x2,x3,x4)
            ny1 = min(y1,y2,y3,y4)
            nx2 = max(x1,x2,x3,x4)
            ny2 = max(y1,y2,y3,y4)
            if rot ~= 0 then rectangle = {x1,y1,x2,y2,x3,y3,x4,y4} else rectangle = nil end
        elseif geoModel == "point" then
            nx1,ny1 = f(x),f(y)
            nx2,ny2 = nx1,ny1
        end
        if not (ox1 == nx1 and oy1 == ny1 and ox2 == nx2 and oy2 == ny2 ) then
            if layer then
                layer:updateSprite(self,ox1,oy1,ox2,oy2,nx1,ny1,nx2,ny2)
            end
            event.fire("onMove",self,nx1-ox1,ny1-oy1)
        end
        bbox = {nx1,ny1,nx2,ny2}
    end

    function i:getBBox()
        return unpack(bbox)
    end

    function i:getRectangle()
        if geoModel ~= "full" or rot == 0 then
            return bbox[1],bbox[2],bbox[3],bbox[2],bbox[3],bbox[4],bbox[1],bbox[4]
        else
            return unpack(rectangle)
        end
    end

    function i:setSize(W,H)
        w,h = W,H
        self:updateTransformation()
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

    function i:getTweenStyle()
        return tweenStyle or "linear"
    end

    function i:setTweenStyle(Style)
        tweenStyle = Style
    end


    function i:setLayer(Layer, dontcall)
        layer = Layer
        if not dontcall and Layer then Layer:insert(self, true) end
    end

    function i:getLayer()
        return layer
    end

    bbox = {f(x-pivx),f(y-pivy),f(x+w-pivx),f(y+h-pivy) }
    if X and Y then i:movePosTo(X,Y) end
    if W and H then i:setSize(W,H) end
    return i
end

return geometry