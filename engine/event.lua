local event = {} --interface
local events = {} --collection

function event.update()
    for name , event in pairs(events) do
        event:update()
    end
end
function event.get(Name)
    return event[Name]
end
function event.register(Name,Sprite,Callback)
    if not events[Name] then events[Name] = event.new(Name) end
    events[Name]:register(Sprite,Callback)
end
function event.fire(Name,Sprite,...)
    if events[Name] then events[Name]:fire(Sprite,...) end
end
function event.setCondition(Name,Condition)
    if events[Name] then events[Name]:setCondition(Condition)
    else error("There is no event called "..Name)
    end
end

function event.new(Name , Condition)
    local registeredSprites = {}
    setmetatable(registeredSprites, {__mode="k"})
    local condition
    local i = {}
    function i:register(Sprite, Callback)
        registeredSprites[Sprite] = Callback
    end
    function i:setCondition(Condition)
        condition = Condition
    end
    function i:update()
        for sprite , callback in pairs(registeredSprites) do
            if condition then
                if condition(sprite) then callback(sprite) end
            end
        end
    end
    function i:fire(Sprite,...)
        registeredSprites[Sprite](Sprite,...)
    end

    if Condition then i:setCondition(Condition) end
    if Name then events[Name] = i
    else error("Missing argument. Events need a unique name")
    end
    return i
end

return event