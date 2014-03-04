local geo = require(ENGINE_PATH.."/geometry")
local camera = {}

function camera.new(X,Y)
    local i = geo.new(X,Y)
    i:setSize(love.window.getDimensions())
    return i
end

return camera