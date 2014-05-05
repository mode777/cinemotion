local tween = require(ENGINE_PATH.."/tween")
local event = require(ENGINE_PATH.."/event")
local object = require(ENGINE_PATH.."/object")

local update = {}

local geometry = {}

local geometryUpToDate = false

function geometry.update()
    for geo, _ in pairs(update) do
        geo:updateTransformation()
        update[geo] = nil
    end
end

function geometry.new(X,Y,W,H)
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

    local i = object.new{}

    i:setAttribute("pos_x",0)
    i:setAttribute("pos_y",0)
    i:setAttribute("rot",0)
    i:setAttribute("sca_x",1)
    i:setAttribute("sca_y",1)
    i:setAttribute("piv_x",0)
    i:setAttribute("piv_y",0)
    i:setAttribute("size_x",0)
    i:setAttribute("size_y",0)
    i:setAttributeCallback(function(self,attr)
        local model = self:getGeometryModel()
        if not attr then update[self] = true end
        if model == "full" then
            update[self] = true
            geometryUpToDate = false
        elseif model == "bbox" and attr == "pos_x" or attr == "pos_y" or attr == "piv_x" or attr == "piv_y" then
            update[self] = true
            geometryUpToDate = false
        elseif model == "point" and attr == "pos_x" or attr == "pos_y" then
            update[self] = true
            geometryUpToDate = false
        end
    end)

    function i:setChild(Geometry)
        self:setAttributeLink(Geometry,"pos_x",nil,function(a,b) return a+b end)
        self:setAttributeLink(Geometry,"pos_y",nil,function(a,b) return a+b end)
        self:setAttributeLink(Geometry,"rot",nil,function(a,b) return a+b end)
        self:setAttributeLink(Geometry,"sca_x",nil,function(a,b) return (1+a)*b end)
        self:setAttributeLink(Geometry,"sca_y",nil,function(a,b) return (1+a)*b end)
    end

    function i:removeChild(Geometry)
        local x, y = Geometry:getPos()
        local rot = Geometry:getRot()
        local scax,scay = Geometry:getSca()
        self:unsetAttributeLink(Geometry,"pos_x")
        self:unsetAttributeLink(Geometry,"pos_y")
        self:unsetAttributeLink(Geometry,"rot")
        self:unsetAttributeLink(Geometry,"sca_x")
        self:unsetAttributeLink(Geometry,"sca_y")
        Geometry:setPos(x,y)
        Geometry:setRot(rot)
        Geometry:setSca(scax,scay)
    end

    local moveTween

    local function setPos(X,Y)
        i:setAttribute("pos_x",X)
        i:setAttribute("pos_y",Y)
    end

    function i:setPos(X,Y)
        if moveTween then moveTween:kill() end
        setPos(X,Y)
        --x,y = X,Y
    end

    function i:stopMoving()
        if moveTween then moveTween:kill() end
    end

    function i:getPos()
        return self:getAttribute("pos_x"), self:getAttribute("pos_y")
    --return x,y
    end

    function i:movePos(X,Y,T)
        if moveTween then moveTween:kill() end
        if not T then
            local x,y = self:getRawAttribute("pos_x"), self:getRawAttribute("pos_y")
            if x then setPos(x+X, y+Y)
            else setPos(X, Y) end
            --x,y = x+X, y+Y
        else
            local x, y = self:getRawAttribute("pos_x"), self:getRawAttribute("pos_y")
            moveTween = tween.new({x,y},{x+X,y+Y},T,function(X,Y) setPos(X, Y) end,tweenStyle)
            return moveTween
        end
    end

    function i:movePosTo(X,Y,T)
        local x,y = self:getPos()
        if x then X,Y = X-x, Y-y end
        return i:movePos(X,Y,T)
    end

    local pivotTween
    function i:movePiv(X,Y,T)
        if pivotTween then pivotTween:kill() end
        local pivx, pivy = self:getPiv()
        if not T then
            self:setPiv(pivx+X, pivy+Y)
        else
            local pivotTween = tween.new({pivx,pivy},{pivx+X,pivy+Y},T,function(X,Y) self:setPiv(X,Y) end,tweenStyle)
            return pivotTween
        end
    end

    function i:movePivTo(X,Y,T)
        local pivx, pivy = self:getPiv()
        X,Y = X-pivx,Y-pivy
        return i:movePiv(X,Y,T)
    end

    function i:getPiv()
        return self:getAttribute("piv_x"), self:getAttribute("piv_y")
    end

    function i:setPiv(X,Y)
        self:setAttribute("piv_x",X)
        self:setAttribute("piv_y",Y)
    end

    function i:center(hor,ver)
        local x, y
        local w,h = self:getSize()
        if hor == "left" then x = 0
        elseif hor == "middle" then x = w/2
        elseif hor == "right" then x = w
        else x = w/2
        end
        if ver == "top" then y = 0
        elseif ver == "middle" then y = h/2
        elseif ver == "bottom" then y = h
        else y = h/2
        end
        self:movePivTo(x,y)
    end

    local movRot
    function i:moveRot(Rot,T)
        local rot = self:getRot()
        if movRot then movRot:kill() end
        if not T then
            self:setRot(rot+Rot)
        else
            movRot = tween.new({rot},{rot+Rot},T,function(Rot) self:setRot(Rot) end, tweenStyle)
            return movRot
        end
    end

    function i:moveRotTo(Rot,T)
        local rot = self:getRot()
        Rot = Rot - rot
        return self:moveRot(Rot,T)
    end

    function i:setRot(Rot)
        self:setAttribute("rot",Rot)
    end

    function i:getRot()
        return self:getAttribute("rot")
    end

    local movSca
    function i:moveSca(SX,SY,T)
        SY = SY or SX
        local scax,scay = self:getSca()
        if movSca then movSca:kill() end
        if not T then
            self:setSca(scax*SX, scay*SY)
        else
            movSca = tween.new({scax,scay},{scax*SX,scay*SY},T,function(SX,SY) self:setSca(SX,SY) end, tweenStyle)
            return movSca
        end
    end

    function i:setSca(SX,SY)
        SY = SY or SX
        self:setAttribute("sca_x",SX)
        self:setAttribute("sca_y",SY)
    end

    function i:getSca()
        return self:getAttribute("sca_x"), self:getAttribute("sca_y")
end

    function i:moveScaTo(SX,SY,T)
        local scax,scay = self:getSca()
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
        local pivx, pivy = self:getPiv()
        local scax, scay = self:getSca()
        local rot = self:getRot()
        local x,y = self:getPos()
        --pivot
        X,Y = X-pivx, Y-pivy
        --scale

        if scax ~= 1 or scay ~= 1 then X,Y = X*scax, Y*scay end
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
        local pivx, pivy = self:getPiv()
        local scax, scay = self:getSca()
        local rot = self:getRot()
        local x,y = self:getPos()
        --transform
        X, Y = X-x, Y-y
        --rotate
        if rot ~= 0 then
            local c, s = cos(-rot), sin(-rot)
            X,Y = c*X - s*Y, s*X + c*Y
        end
        --scale
        if scax ~= 1 or scay ~= 1 then X,Y = X/scax, Y/scay end
        --pivot
        X,Y = X+pivx, Y+pivy
        return X,Y
    end

    function i:setSize(W,H)
        self:setAttribute("size_x",W)
        self:setAttribute("size_y",H)
    end

    function i:getSize()
        return self:getAttribute("size_x"), self:getAttribute("size_y")
    end

    function i:updateTransformation()
        --todo: skip recalculating if geometry is up to date but still update hash.
        --if geometryUpToDate then return end
        local w,h = self:getSize()
        local x,y = self:getPos()
        local rot = self:getRot()
        local scax,scay = self:getSca()
        local pivx,pivy = self:getPiv()

        local ox1,oy1,ox2,oy2 = unpack(bbox)
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
        bbox = {nx1,ny1,nx2,ny2 }
        geometryUpToDate = true
    end

    function i:getBBox()
        if not geometryUpToDate then i:updateTransformation() end
        return unpack(bbox)
    end

    function i:getRectangle()
        if not geometryUpToDate then i:updateTransformation() end
        local rot = self:getRot()
        if geoModel ~= "full" or rot == 0 then
            return bbox[1],bbox[2],bbox[3],bbox[2],bbox[3],bbox[4],bbox[1],bbox[4]
        else
            return unpack(rectangle)
        end
    end

    function i:isInside(X,Y)
        local w,h = self:getSize()
        local rot = self:getRot()
        if geoModel == "point" then
            local x,y = self:getPos()
            return x == X and y == Y
        elseif geoModel == "bbox" or rot == 0 then
            return X > bbox[1] and X < bbox[3] and Y > bbox[2] and Y < bbox[4]
        else --full transformation
            local X,Y = self:projectPoint(X,Y)
            return X > 0 and X < w and Y > 0 and Y < h
        end
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

    bbox = {0,0,0,0}
    if X and Y then i:movePosTo(X,Y) end
    if W and H then i:setSize(W,H) end

    return i
end

geometry._DOC={
    update={"Updates all geometry that has been changed since the last cycle."},
    new={
        INHERIT="object",
        "Creates a new %geometry% object.",{ {"number","X"},{"number","Y"},{"number","W"},{"number","H"} },{ {"geometry","Geometry"} },
        methods = {
            setChild = {"Link another %geometry% object to this object. E.G. if you move the parent, the child will move by the same amount."},
            getLayer = {"Returns the layer which is hosting the object."},
            setLayer = {"Links the object to a layer."},
            getTweenStyle = {},
            setTweenStyle = {},
            isInside = {},
            getBBox = {},
            getRectangle = {},
            updateTransformation = {},
            getSize = {},
            setSize = {},
            projectPoint = {},
            transformPoint = {},
            setChild = {},
            removeChild = {},
            setPos = {},
            getPos = {},
            movePos = {},
            movePosTo = {},
            setPiv = {},
            getPiv = {},
            movePiv = {},
            movePivTo = {},
            setRot = {},
            getRot = {},
            moveRot = {},
            moveRotTo = {},
            setSca = {},
            getSca = {},
            moveSca = {},
            moveScaTo = {},
            setGeometryModel = {},
            getGeometryModel = {},
        }
    }
}

return geometry