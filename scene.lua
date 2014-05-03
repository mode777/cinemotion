local thread = require(ENGINE_PATH.."/thread")
local serialize = require(ENGINE_PATH.."/serialize")

local scenes = {}
--scene

local class = {}

function class.new(file)
    local stop
    local func
    local filename

    local i = thread.new()

    function i:loadFile(file)
        local sce = love.filesystem.load(file)()
        filename = file
        func = function()
            if sce.onLoad then sce.onLoad(self) end
            if sce.onUpdate then
                while not stop do
                    sce.onUpdate(self)
                    thread.yield()
                end
            end
            if sce.onStop then sce.onStop(self) end
            scenes[file] = nil
        end
        i:setFunction(func)
    end

    function i:stop()
        stop = true
    end
    if file then i:loadFile(file) scenes[file] = i end

    return i
end

function class.get(name)
    return scenes[name]
end

function class.running()
    local buffer = {}
    for name in pairs(scenes) do
        table.insert(buffer,name)
    end
end

return class