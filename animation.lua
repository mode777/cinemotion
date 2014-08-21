local spriteSheet = require(ENGINE_PATH.."/sourceSpritesheet")
local animation = {}
local animations = {}

function animation.update(dt)
    local remove = {}
    for i = 1, #animations do
        if animations[i]:isFinished() then
            table.insert(remove,i)
        else
            if animations[i]:getStatus() ~= "pause" then
                animations[i]:update(dt)
            end
        end
    end
    for i=1, #remove do
        table.remove(animations,remove[i])
    end
end

function animation.loadAnimationSheet(file)
    local a = {}
    local sheet = spriteSheet.new(file:sub(1,-5)..".png")

    local t = cine.serialize.CSVToDictionary(file,";")
    local offsetx,offsety

    for i=1, #t do
        if i==1 then
            offsetx,offsety = t[i].ox,t[i].oy
        end
        if not a[t[i].animation] then
            a[t[i].animation] = {delay=t[i].delay, offsets={},indices={}}
        end
        table.insert(a[t[i].animation].offsets,{t[i].ox-offsetx,t[i].oy-offsety})
        table.insert(a[t[i].animation].indices,t[i].index)
        sheet:addRectangle(t[i].x,t[i].y,t[i].w,t[i].h,t[i].index)
    end
    for i,v in pairs(a) do
        a[i] = animation.newAnimation(v.delay,v.indices,v.offsets)
    end
    return sheet, a
end

function animation.newAnimation(delay, indices, offsets)
    local a = {}
    offsets = offsets or {}

    function a:newPlayer(sprite,style,delay)
        local i = {}
        local delay = delay or 0.1
        local time = 0
        local finished
        local index = 1
        local style = style or "once"
        local status = "stop"
        local sprite = sprite

        local lastIndex
        local lastOffset

        function i:update(dt)
            time = time + dt
            index = math.floor(time/delay)+1
            if index > #indices and style == "once" then
                finished = true
                index = #indices
            else
                index = index%(#indices+1) == 0 and 1 or index%(#indices+1)
            end

            if index ~= lastIndex then
                sprite:setIndex(indices[index])
                lastIndex = index
            end

            if offsets[index] then
                if not lastOffset then lastOffset = {0,0} end
                if lastOffset[1] ~= offsets[index][1] or lastOffset[2] ~= offsets[index][2] then
                    local ox,oy = offsets[index][1]-lastOffset[1],offsets[index][2]-lastOffset[2]

                    sprite:movePos(0,0)
                    lastOffset = {offsets[index][1],offsets[index][2]}
                end
            end
        end

        function i:getStatus()
            return status
        end

        function i:setStyle(Style)
            style = Style
        end

        function i:getStyle()
            return style
        end

        function i:play()
            if status == "stop" then
                status = "play"
                table.insert(animations,self)
            elseif status == "pause" then
                status = "play"
            end
        end

        local lastIndex

        function i:getIndex()
            local hasChanged = lastIndex ~= indices[index]
            lastIndex = indices[index]
            local x,y = 0,0
            if offsets then
                x,y = unpack(offsets[index])
            end
            return indices[index], hasChanged, x,y
        end

        function i:getFrame()
            return index
        end

        function i:getIndices()
            return indices
        end

        function i:stop()
            self:kill()
        end

        function i:isFinished()
            return finished
        end

        function i:kill()
            index = 1
            status = "stop"
            finished = true
        end

        function i:seek(index)
            index = index%#indices+1 == 0 and 1 or index%#indices+1
        end

        return i
    end

    return a
end

return animation
