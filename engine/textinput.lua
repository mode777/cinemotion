local target
local index
local finished = true

local textinput = {}

function textinput.setTarget(strg)
    target = strg
    finished = false
    index = string.len(strg)+1
end

function textinput.getTarget(cursor)
    if cursor then
        return string.sub(target,1,index-1).."|"..string.sub(target,index,-1)
    else
        return target
    end
end

function textinput.insert(t)
    target = string.sub(target,1,index-1)..t..string.sub(target,index,-1)
    index = index+1
end

function textinput.delete()
    target = string.sub(target,1,index-2)..string.sub(target,index,-1)
    index = index - 1
end

function textinput.finish()
    finished = true
end

function textinput.isFinished()
    return finished
end

function textinput.moveIndex(dir)
    if dir == "left" then
        if index > 1 then index = index - 1 end
    elseif dir == "right" then
        if index <= string.len(target) then index = index + 1 end
    end
end

return textinput