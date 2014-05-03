local cm = require(ENGINE_PATH)

local function createDocumentation()
    local doc
    if love.filesystem.exists("documentation.lua") then
        doc = cm.serialize.load("documentation.lua")
    else
        doc = {}
    end
    local function getDescriptor(name)
        return {Description="",Usage=name,Arguments={{type="",value="",description=""}},Returns={{type="",value="",description=""}}}
    end
    --let's read the api
    for name, interface in pairs(cm) do
        if type(interface) == "function" then
            if not doc["functions"] then doc["functions"] = {} end
            if not doc["functions"][name] then doc["functions"][name] = getDescriptor("cine."..name) end
        elseif type(interface) == "table" then
            print("interface",name)
            if not doc[name] then doc[name] = {} end
            for funcname, f in pairs(interface) do
                if funcname ~= "new" then
                    if not doc[name]["functions"] then doc[name]["functions"] = {} end
                    if not doc[name]["functions"][funcname] then doc[name]["functions"][funcname] = getDescriptor("cine."..name.."."..funcname) end
                else
                    if not doc[name]["constructor"] then doc[name]["constructor"] = {} end
                    if not doc[name]["constructor"][funcname] then doc[name]["constructor"][funcname] = getDescriptor("cine."..name.."."..funcname) end
                    print("creating instance",funcname)
                    local instance = f()
                    for methname, _ in pairs(instance) do
                        if not doc[name]["methods"] then doc[name]["methods"] = {} end
                        if not doc[name]["methods"][methname] then doc[name]["methods"][methname] = getDescriptor(name..":"..methname) end
                    end
                end
            end
        end
    end
    cm.serialize.save(doc,"documentation.lua")
end

local scene = {}
local layer

function scene:onLoad()
    local layer = cm.layer.new()
    local font = cm.sourceFont.new("vera.ttf",30)
    local items = {}
    local function newItem(Name,Callback)
        local sprite = cm.sprite.new(100,#items*30,font,Name)
        sprite:registerEvent("onClicked",Callback,sprite)
        sprite:registerEvent("onMouseOver",function(self) self:moveTintTo(255,0,0,255) end,sprite)
        sprite:registerEvent("onMouseOff",function(self) self:moveTintTo(255,255,255,255) end,sprite)
        table.insert(items,sprite)
        layer:insertSprite(sprite)
        return sprite
    end

    newItem("Create Documentation",createDocumentation)


    --initialize your scene here
end

function scene:onUpdate()
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene