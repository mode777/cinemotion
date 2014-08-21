local tween = {}
local tweens = {}
local curves = {}
curves.easeinout = love.math.newBezierCurve( 0,0,0.5,0,0.5,1,1,1 )
curves.flash = love.math.newBezierCurve( 0,0, 0.25,0, 0.25,1, 0.5,1, 0.75,1, 0.75,0, 0,0)
curves.easein = love.math.newBezierCurve( 0,0,0.5,0,1,1 )
curves.easeout = love.math.newBezierCurve( 0,0,0.5,1,1,1 )
curves.linear = love.math.newBezierCurve( 0,0,1,1 )

function tween.update(dt)
    local remove = {}
    for i = 1, #tweens do
        if tweens[i]:isFinished() then
            table.insert(remove,i)
        else
            tweens[i]:update(dt)
        end
    end
    for i=1, #remove do
        table.remove(tweens,remove[i])
    end
end

function tween.new(StartValue, EndValue, Duration, Callback, Style)
    local style = Style or "linear"
    local i = {}
    local startValue
    local currentValue = {}
    local endValue
    local time = 0
    local duration
    local callback
    local finished

    function i:update(dt)
        time = time + dt
        if startValue and endValue and duration then
            if time >= duration then time = duration finished = true end
            local _, mul = curves[style]:evaluate(time/duration)
            for ci=1, #startValue do
                local delta = endValue[ci]-startValue[ci]
                currentValue[ci] = startValue[ci]+(delta*mul)
            end
        end
        if callback then callback(unpack(currentValue)) end
    end

    function i:isFinished()
        return finished
    end

    function i:kill()
        finished = true
    end

    function i:setValues(StartValue,EndValue)
        if type(StartValue) == "number" then startValue = {StartValue} else startValue = StartValue end
        if type(EndValue) == "number" then endValue = {EndValue} else endValue = EndValue end
        if #startValue ~= #endValue then error("amount of values has to match 1:"..#startValue.." 2:"..#endValue) end
    end

    function i:setDuration(Duration)
        duration = Duration
    end

    function i:setCallback(Callback)
        callback = Callback
    end

    if StartValue and EndValue then i:setValues(StartValue,EndValue) end
    if Duration then i:setDuration(Duration) end
    if Callback then i:setCallback(Callback) end

    table.insert(tweens,i)
    return i
end

return tween
