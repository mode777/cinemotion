local tweens = {}
local tween = {}

local linear = love.math.newBezierCurve( 0,0,1,1 )

function tween.update(dt)
    for i = 1, #tweens do
    if tweens[i] then
        if tweens[i]:isFinished() then
            table.remove(tweens,i)
        else
            tweens[i]:update(dt)
        end
    end
    end
end

function tween.new(StartValue, EndValue, Duration, Callback, Style)
    local style = Style or "linear"
    local i = {}
    local startValue
    local currentValue
    local endValue
    local time = 0
    local duration
    local callback
    local style
    local finished
-- t = current time (since start), b = start value, c = delta value, d = delta time
    if type(StartValue) == "number" then startValue = {StartValue} else startValue = StartValue end
    if type(EndValue) == "number" then endValue = {EndValue} else endValue = EndValue end
    if #startValue ~= #endValue then error("amount of values has to match 1:"..#startValue.." 2:"..#endValue) end
    currentValue = {}
    duration = Duration
    callback = Callback

    function i:update(dt)
        time = time + dt
        if time >= duration then time = duration finished = true end
        local _, mul = linear:evaluate(time/duration)
        for ci=1, #startValue do
            local delta = endValue[ci]-startValue[ci]
            currentValue[ci] = startValue[ci]+(delta*mul)
        end
        if callback then callback(unpack(currentValue)) end
    end

    function i:isFinished()
        return finished
    end

    function i:kill()
        finished = true
    end

    table.insert(tweens,i)
    return i
end

return tween
