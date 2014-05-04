local thread = require(ENGINE_PATH.."/thread")
local serialize = require(ENGINE_PATH.."/serialize")

local scenes = {}
--scene

local scene = {}

function scene.new(file)
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

function scene.get(name)
    return scenes[name]
end

function scene.running()
    local buffer = {}
    for name in pairs(scenes) do
        table.insert(buffer,name)
    end
    return buffer
end

scene._DOC = {
    new = {
        "Constructor for %scene% objects",{ {"string","filename","The scene file to load"} },{ {"scene","scene"} },
        INHERIT="thread",
        methods={
            loadFile={"Loads a scene",{ {"string","file","The file to load"} }},
            stop={"Stops the %scene% and calls the scene:onStop() callback"}
        }
    },
    get = {"Get's a currently loaded scene",{ {"string","name","The filename of the loaded scene"} },{ {"scene","Scene"} }},
    running={"Get a list of all currently running scenes",nil,{ {"table","list"} }}
}

return scene