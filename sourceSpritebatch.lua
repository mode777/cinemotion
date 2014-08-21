local sourceSpritesheet = require(ENGINE_PATH.."/sourceSpritesheet")
local data = require(ENGINE_PATH.."/data")
local sourceSpritebatch = {}

function sourceSpritebatch.load(file)
    local ss = sourceSpritesheet.load(file)
    return sourceSpritebatch.new(ss)
end

function sourceSpritebatch.new(file)
    local i
    if type(file) == "table" then
        i = file
    else
        i = sourceSpritesheet.new(file)
    end

    local batches = {}
    setmetatable(batches,{__mode="k"})
    local layouts = {}
    setmetatable(layouts,{__mode="k"})

    function i:getSize(sprite)
        local index = sprite:getIndex()
        if index then
            local w,h = 0,0
            for i=1, #index do
                if index[i][1] then
                    local _,_,lw,lh = self:getRectangle(index[i][1]):getViewport()
                    local x,y = index[i][2] or 0, index[i][3] or 0
                    local lx2,ly2 = x+lw, y+lh
                    w = math.max(lx2,w)
                    h = math.max(ly2,h)
                end
            end
            return w,h
        else
            return 0,0
        end
    end

    local function checkForUpdates(sprite)
        if not layouts[sprite] then
            layouts[sprite] = data.clone(sprite:getIndex())
            return "rebuild"
        end
        if #layouts[sprite] ~= #sprite:getIndex() then
            layouts[sprite] = data.clone(sprite:getIndex())
            return "rebuild"
        else
            local changes = {}
            local index = sprite:getIndex()
            local oldindex = layouts[sprite]
            for i=1, #index do
                if not data.compare(index[i],oldindex[i]) then
                    table.insert(changes,i)
                    oldindex[i] = data.clone(index[i])
                end
            end
            if #changes == 0 then return "ok"
            else return "update", changes
            end
        end
    end

    local function updateBatch(sprite)
        local type, changes = checkForUpdates(sprite)
        if type == "rebuild" then
            print(type)
            local batch = love.graphics.newSpriteBatch(i:getImage(),#layouts[sprite],"dynamic")
            batch:bind()
            for id,t in ipairs(layouts[sprite]) do
                love.graphics.setColor(255,20,0,255)
                if t[1] then
                    batch:add( i:getRectangle(t[1]), t[2] or 0, t[3] or 0, t[4], t[5], t[6], t[7], t[8], t[9], t[10] )
                else
                    batch:add(0,0,0,0)
                end
            end
            batch:unbind()
            batches[sprite] = batch
        elseif type == "update" then
            print(type)
            for i=1, #changes do
                local batch = batches[sprite]
                local id = changes[i]-1
                local data = layouts[changes[i]]
                batch:bind()
                if data[1] then
                    batch:set(id,i:getRectangle(data[1]), data[2] or 0, data[3] or 0, data[4], data[5], data[6], data[7], data[8], data[9], data[10])
                else
                    data[1]:set(0,0,0,0)
                end
                batch:unbind()
            end
        end
    end

    function i:draw(sprite)
        local index = sprite:getIndex()
        if index then
            updateBatch(sprite)
            love.graphics.draw(batches[sprite],0,0)
        end
    end

    return i
end

return sourceSpritebatch