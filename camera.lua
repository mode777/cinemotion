local geo = require(ENGINE_PATH.."/geometry")
local camera = {}

function camera.new(X,Y)
    local i = geo.new(X,Y)
    local sw,sh = love.window.getDimensions()
    local bounds

    function i:follow(sprite)
        self:setPos(sprite:getPos())
        sprite:setAttributeLink(self,"pos_x",nil,function(a,b) return a+b end)
        sprite:setAttributeLink(self,"pos_y",nil,function(a,b) return a+b end)
    end

    i:setSize(sw,sh)
    --i:center()
    --i:movePos(sw/2,sh/2)
    --i:setGeometryModel("bbox")

    return i
end

camera._DOC = {
    new = {
        "Constructor for a camera",{ {"number","Y","number","Y"} },{ {"camera","Camera"} },
        INHERIT="geometry",
    },
}

return camera