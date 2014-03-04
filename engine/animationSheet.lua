local serialize = require(ENGINE_PATH.."/serialize")

local animationSheet = {}

function animationSheet.new()
    local animations = {}
    local i = {}
    function i:addAnimation(Name,...)
        animations[Name] = {... }
    end
    function i:loadSheet(Name)
        animations = serialize.load(Name)
    end

    function i:save(File)
        serialize.save(animations, File..".ani")
    end

    function i:get(Name)
        for i,v in ipairs(animations) do
            print(i,v)
        end
        return animations[Name]
    end
    return i

end

function animationSheet.load(Name)
    local a = animationSheet.new()
    a:loadSheet(Name)
    return a
end

function animationSheet.save(Sheet, Name)
    Sheet:save(Name)
end

return animationSheet