local thread = require(ENGINE_PATH.."/thread")
local animation = {}
function animation.new(Sprite,Style,Delay, ...)
    local keys = {}
    local delay = delay or 0.25
    local style = style or "once"
    local pause
    local stop
    local currentKey = 1
    local sprite = Sprite

    local cr = thread.new(function()
        while true do
            if pause then thread.yield() end
            if stop then stop = false return end
            currentKey = currentKey+1
            thread.wait(delay)
        end
    end)
     cr:run()
     return cr
    end

    return i
end
return animation
