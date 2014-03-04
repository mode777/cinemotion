
local function linear (t, b, c, d)
    t = t/d
    return b+c*(t)
end

local function ease_in_out(t, b, c, d)
    t = t/d
    local ts = t*t
    local tc = ts*t
    return b+c*(-2*tc + 3*ts)
end

local function ease_in(t,b,c,d)
    t = t/d
    local tc = t*t*t
    return b+c*(tc)
end

local function ease_out(t,b,c,d)
    t = t/d
    local ts = t*t
    local tc = ts*t
    return b+c*(tc + -3*ts + 3*t);
end

local function ease_in_out_elastic(t,b,c,d)
    t = t/d
    local ts = t*t
    local tc = ts*t
    return b+c*(-9.4975*tc*ts + 31.4925*ts*ts + -36.79*tc + 15.595*ts + 0.2*t)
end

local tween = {}
function tween.new()
    local style = Style or "linear"
    local i = {}
-- t = current time (since start), b = start value, c = delta value, d = delta time
    function i:tween(currentTime, startValue, endValue, endTime,style)
        local t, b, c, d
        t = currentTime
        b = startValue
        c = endValue
        d = endTime
        if style == "linear" then return linear(t,b,c,d)
        elseif style == "easein"then return ease_in(t,b,c,d)
        elseif style == "easeout" then return ease_out(t,b,c,d)
        elseif style == "easeinout" then return ease_in_out(t,b,c,d)
        elseif style == "easeinoutelastic" then return ease_in_out_elastic(t,b,c,d)
        end
    end

    function i:setTweenStyle(str)
        style = str
    end

    function i:getTweenStyle()
        return style
    end

    return i
end

return tween