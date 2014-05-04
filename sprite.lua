local time = love.timer.getTime
local setColor = love.graphics.setColor
local setBlendMode = love.graphics.setBlendMode
local floor = math.floor

local tween = require (ENGINE_PATH.."/tween")
local geometry = require(ENGINE_PATH.."/geometry")
local event = require(ENGINE_PATH.."/event")

local showBounds = false

local sprite = {}

function sprite.showBounds(bool)
    showBounds = bool
end

function sprite.getShowBounds()
    return showBounds
end

function sprite.new(X,Y,Source,Index)
    --print("sprite:",X,Y,Source,Index)
    local source
    local index
    local tint
    local layer
    local z_index = 0
    local animation
    local blendmode
    local visible = true


    local i = geometry.new(X,Y)
    function i:setSource(Source)
        if index then i:setSize(Source:getSize(index)) end
        source = Source
        self:updateTransformation()
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

    local tintTween
    function i:setTint(r,g,b,a)
        if tintTween then tintTween:kill() end
        tint = {r or 255,g or 255, b or 255, a or 255}
    end

    function i:moveTint(r,g,b,a,T)
        if tintTween then tintTween:kill() end
        if not tint then i:setTint(255,255,255,255) end
        if not T then
            tint = {tint[1]+r, tint[2]+g, tint[3]+b, tint[4]+a }
        else
            local style = self:getTweenStyle()
            tintTween = tween.new(
                {tint[1], tint[2], tint[3], tint[4]},
                {tint[1]+r, tint[2]+g, tint[3]+b, tint[4]+a},
                T,
                function(r,g,b,a)
                    if not i.index then
                    end
                    tint[1] = r
                    tint[2] = g
                    tint[3] = b
                    tint[4] = a
                end,
                style
            )
            return tintTween
        end
    end

    function i:moveTintTo(r,g,b,a,T)
        if not tint then i:setTint(255,255,255,255) end
        r,g,b,a = r-tint[1],g-tint[2],b-tint[3],a-tint[4]
        return i:moveTint(r,g,b,a,T)
    end

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
        event.register(Name,Func,self)
    end

    function i:fireEvent(Name, ...)
        event.fire(Name,self,...)
    end

    function i:setVisible(bool)
        visible = bool
        --local children = i:getChildren() end

    end

    function i:getVisible(bool)
        return visible
end

    function i:draw()
        if visible then
            love.graphics.push()
            local x,y = i:getPos()
            local pivx,pivy = i:getPiv()
            love.graphics.translate(floor(x+0.5),floor(y+0.5))
            love.graphics.rotate(i:getRot())
            love.graphics.scale(i:getSca())
            love.graphics.translate(-pivx,-pivy)
            if blendmode then setBlendMode(blendmode) end
            if tint then setColor(unpack(tint)) end
            local ox1,oy1,ox2,oy2 = self:getBBox()
            if source then source:draw(self) end
            setColor(255,255,255,255)
            love.graphics.setBlendMode("alpha")
            love.graphics.pop()
            --debug
            if showBounds then
                love.graphics.setPointSize(5)
                love.graphics.point(x,y)
                if self:getGeometryModel() ~= "point" then
                    love.graphics.setLineWidth(1)
                    love.graphics.setColor(255,0,0,255)
                    local c1,c2,c3,c4,c5,c6,c7,c8 = self:getRectangle()
                    love.graphics.line(c1,c2,c3,c4,c5,c6,c7,c8,c1,c2)
                    love.graphics.setColor(255,255,255,255)
                    love.graphics.rectangle("line",ox1,oy1,ox2-ox1,oy2-oy1)
                end
            end
        end
    end

    function i:isGroup()
        return false
end

    if Source then i:setSource(Source) end
    if Index then i:setIndex(Index) else i:setIndex(1) end
    i:updateTransformation()
    return i
end

sprite._DOC = {
    new = {
        "Constructor for %sprite%",{ {"number","X"},{"number","Y"},{"source","Source","A source type object that can be drawn"},{"var","Index","Index that tells the drawable what to draw."} },{ {"sprite","Sprite"} },
        INHERIT="geometry",
        methods={
            getSource={"Gets the source used by drawing by this sprite",nil,{ {"source","Source"} }},
            setSource={"Sets the source for this Sprite",{ {"source","Source"} }},
            setIndex={"Sets the index for this Sprite",{ {"var","Index"} }},
            getIndex={"Returns the index for this Sprite",nil,{ {"var","Index"} }},
            getZIndex={"Returns the Z_index used by the layer to depth sort sprites. Higher numbers mean further on the top.",nil,{ {"number","Z-Index"} }},
            setZIndex={"Sets the Z_index used by the layer to depth sort sprites. Higher numbers mean further on the top.",{ {"number","Z-Index"} }},
            setBlendMode={"Sets the blending mode to be used when drawing the sprite. See here for available blendmodes: http://www.love2d.org/wiki/BlendMode",{ {"string","BlendMode"} }},
            getTint={"Gets the current color(RGBA) the sprite is drawn with.",nil,{ {"number","r"},{"number","g"},{"number","b"},{"number","a"} }},
            setTint={"Sets the current color(RGBA) the sprite is drawn with.",{ {"number","r"},{"number","g"},{"number","b"},{"number","a"} }},
            moveTint={"Shifts current color(RGBA) of the sprite by suplied amount.Can be animated by supplying a fifth argument.",{ {"number","r"},{"number","g"},{"number","b"},{"number","a"},{"number","T","Time in seconds"} },{ {"tween","Animation","A tween representing the animation"} }},
            moveTintTo={"Changes the current color(RGBA) to the new value supplied.Can be animated by providing a fifth argument.",{ {"number","r"},{"number","g"},{"number","b"},{"number","a"},{"number","T","Time in seconds"} },{ {"tween","Animation","A tween representing the animation"} }},
            setVisible={"Makes the %sprite% visible or not",{ {"bool","visible"} }},
            getVisible={"Gets the current visiblity.",nil,{ {"bool","visible"} }},
            draw={"Draws the sprite to the screen. To be used internally or with a %scriptLayer%."},
        }
    },
    showBounds = {"Draws debug lines for all sprites",{ {"bool","Show"} }},
    getShowBounds = {"Returns true if debug lines are currently drawn",nil,{ {"bool","Show"} }}
}

return sprite

