local z_count = 0

local time = love.timer.getTime
local setColor = love.graphics.setColor
local setBlendMode = love.graphics.setBlendMode

local thread = require (ENGINE_PATH.."/thread")
local geometry = require(ENGINE_PATH.."/geometry")

local showBounds = false

local sprite = {}

function sprite.showBounds(bool)
    showBounds = bool
end

function sprite.getShowBounds()
    return showBounds
end

function sprite.new(X,Y,Source,Index)
    local source
    local index
    local tint
    local layer
    local z_index = z_count
    local animation
    local event
    local blendmode
    local visible = true

    z_count = z_count+1

    local i = geometry.new(X,Y)

    function i:setSource(Source)
        i:setSize(Source:getSize(index or 1))
        source = Source
    end

    function i:getSource()
        return source
    end

    function i:setIndex(Index)
        if source then i:setSize(source:getSize(Index)) end
        index = Index
    end

    function i:getIndex()
        return index
    end

    function i:getZIndex()
        return z_index
    end

    function i:setZIndex(z)
        z_index = z
    end

    function i:setBlendmode(bm)
        blendmode = bm
    end

    function i:getTint(r,g,b,a)
        return unpack(tint)
end

    local movTint

    function i:setTint(r,g,b,a)
        if movTint then movTint:kill() end
        tint = {r or 255,g or 255, b or 255, a or 255}
    end

    function i:moveTint(r,g,b,a,T)
        if movTint then movTint:kill() end
        if not tint then i:setTint(255,255,255,255) end
        T = T or 0
        movTint = thread.new(function()
            local style = self:getTweenStyle()
            local startT = time()
            local oldr, oldg, oldb, olda = unpack(tint)
            ---print(r,g,b,a)
            while T+startT > time() do
                tint[1] = i:tween(time()-startT, oldr, r, T,style)
                tint[2] = i:tween(time()-startT, oldg, g, T,style)
                tint[3] = i:tween(time()-startT, oldb, b, T,style)
                tint[4] = i:tween(time()-startT, olda, a, T,style)
                thread.yield()
            end
        end)
        movTint:run()
        return movTint
    end

    function i:moveTintTo(r,g,b,a,T)
        if not tint then i:setTint(255,255,255,255) end
        r,g,b,a = r-tint[1],g-tint[2],b-tint[3],a-tint[4]
        return i:moveTint(r,g,b,a,T)
    end

    --[[
    function i:setLayer(Layer, dontcall)
        layer = Layer
        if not dontcall then Layer:insert(self, true) end
    end

    function i:getLayer()
        return layer
    end
    ]]

    function i:playAnimation(Animation, Delay, Style, Dir)
        if animation then self:stopAnimation() end
        animation = thread.new(function()
        local loop = true
                while loop do
                    for i=1, #Animation do
                        self:setIndex(Animation[i])
                        thread.wait(Delay)
                    end
                    if Style ~= "loop" then loop = false end
                end
            end)

        animation:run()
    end

    function i:stopAnimation()
        animation:kill()
    end

    function i:registerEvent(Name, Func)
        if not event then event = {} end
        if Func then event[Name] = Func end
    end

    function i:event(Name, ...)
        if event then
            if event[Name] then event[Name](self,...) end
        end
    end

    function i:setVisible(bool)
        visible = bool
    end

    function i:getVisible(bool)
        return visible
    end

    function i:draw(sx1,sy1,sx2,sy2)
        if visible then
            love.graphics.push()
            love.graphics.translate(i:getPos())
            love.graphics.rotate(i:getRot())
            love.graphics.scale(i:getSca())
            if blendmode then setBlendMode(blendmode) end
            if tint then setColor(unpack(tint)) end
            local ox1,oy1,ox2,oy2 = self:getBBox()
            if source then source:draw(index,sx1,sy1,sx2,sy2,ox1,oy1,ox2,oy2) end
            setColor(255,255,255,255)
            love.graphics.setBlendMode("alpha")
            love.graphics.pop()
            --debug
            if showBounds then
                local x,y = self:getPos()
                love.graphics.rectangle("line",ox1,oy1,ox2-ox1,oy2-oy1)
                love.graphics.setPointSize(5)
                love.graphics.point(x,y)
            end
        end
    end

    function i:isGroup()
        return false
    end

    if Source then i:setSource(Source) end
    if Index then i:setIndex(Index) end
    return i
end

return sprite