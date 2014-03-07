local e = require("engine")
local scene = {}

local size = love.window.getHeight()/10
local currentMenu
local layer     = e.layer.new()
local font      = e.sourceFont.new("Vera.ttf",size)
local label     = e.sprite.new(100,100,font,"")


local newMenu = function(X,Y,Title)
    local parent
    local box = e.sprite.new(0,Y-30,e.sourcePolyline.new(5))
    local m = e.menu.new()

    function m:activate()
        if currentMenu then currentMenu:deactivate() end
        m:setVisible(true)
        currentMenu = self
        label:setIndex(self:getTitle())
        e.thread.wait(0.25)
    end
    function m:deactivate()
        m:setVisible(false)
        currentMenu = nil
        label:setIndex("")
    end
    function m:addItem(Name, Callback)
        local item = e.sprite.new(X,Y+size*self:getLength(),font,Name)
        item:setTint(255,255,255,128)
        item:registerEvent("onSelect",function(self) self:setTint(255,255,255,255) end)
        item:registerEvent("onDeselect",function(self) self:setTint(255,255,255,128) end)
        item:registerEvent("onMouseOver", function(self) m:selectItem(self) end)
        item:registerEvent("onExecute",Callback)
        item:registerEvent("onClicked",Callback)
        m:addChild(item)
        if m:getLength() == 1 then m:selectItem(1) end
        box:setIndex({0,0,love.window.getWidth(),0})
        return item
end
    function m:setParent(p)
        parent = p
    end
    function m:getParent()
        return parent
end
    m:setTitle(Title)
    m:setVisible(false)
    layer:insertSprite(box)
    layer:insertSprite(m)
    return m
end

function scene:onLoad()
    local backButton = e.sprite.new(0,0,font,"<--")
    layer:insertSprite(backButton)
    backButton:registerEvent("onClicked",function(self)
        local p = currentMenu:getParent()
        if p then p:activate() end
        e.thread.wait(0.25)
    end)

    layer:insertSprite(label)

    local mainMenu = newMenu(100,200,"Main Menu")
    local sceneMenu = newMenu(100,200,"Scene Menu")
    local configMenu = newMenu(100,200,"Config Menu")

    sceneMenu:setParent(mainMenu)
    configMenu:setParent(mainMenu)

    mainMenu:addItem("Run Scene", function() sceneMenu:activate() end)
    mainMenu:addItem("Config", function() configMenu:activate() end)
    mainMenu:addItem("Exit", function() love.event.quit() end)

    local function findScenes(Dir)
        for _,file in ipairs(love.filesystem.getDirectoryItems(Dir)) do
            if love.filesystem.isDirectory(Dir.."/"..file) then
                findScenes(Dir.."/"..file)
            end
            local name, ext = string.match(file,"(.+).(...)")
            if ext == "sce" then
                sceneMenu:addItem(name, function()
                    layer:setVisible(false)
                    local sce = e.scene.new(Dir.."/"..file)
                    sce.run()
                    e.thread.waitThread(sce)
                    layer:setVisible(true)
                end)
            end
        end
    end
    findScenes("")
    mainMenu:activate()
end

function scene:onUpdate()
    if love.keyboard.isDown("down") then
        currentMenu:nextItem()
        e.thread.wait(0.25)
    elseif love.keyboard.isDown("up") then
        currentMenu:prevItem()
        e.thread.wait(0.25)
    elseif love.keyboard.isDown("return") then
        currentMenu:execute()
        e.thread.wait(0.25)
    elseif love.keyboard.isDown("escape") then
        local p = currentMenu:getParent()
        if p then p:activate() end
        e.thread.wait(0.25)
    end
end

function scene:onStop()
    --deconstructon logic here
end

return scene