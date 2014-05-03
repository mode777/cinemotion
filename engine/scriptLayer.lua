local layer = require(ENGINE_PATH.."/layer")
local scriptLayer = {}

function scriptLayer.new(Callback)
    local i = layer.new("NOHASH")
    local callback

    function i:draw()
        if callback then
            callback()
        end
    end

    function i:setCallback(Callback)
        callback = Callback
    end

    function i:getBBox()
        local sw,sh = love.window.getDimensions()
        return 0,0,sw,sh
    end

    function i:getCamera()
    end

    function i:toScreen(...)
    end

    function i:getParallax()
    end

    function i:setParallax(x,y)
    end

    function i:getVisibleSprites()
    end

    if Callback then i:setCallback(Callback) end
return i
end

return scriptLayer