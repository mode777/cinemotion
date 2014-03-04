local e = require("engine")
local scene = {}

local currentMenu
local layer     = e.layer.new()
local font      = e.drawableFont.new()
local label     = e.sprite.new(100,100,font,"")

layer:insertSprite(label)

local newMenu = function(X,Y,Title)
    local title
    local m = e.menu.new()

    function m:activate()
        if currentMenu then currentMenu:deactivate() end
        m:setVisible(true)
        currentMenu = self
        label:setIndex(self:getTitle())
    end
    function m:deactivate()
        m:setVisible(false)
        currentMenu = nil
        label:setIndex("")
    end
    function m:addItem(Name, Callback)
        local item = e.sprite.new(X,Y+15*self:getLength(),font,Name)
        item:setTint(255,255,255,128)
        item:registerEvent("onSelect",function(self) self:setTint(255,255,255,255) end)
        item:registerEvent("onDeselect",function(self) self:setTint(255,255,255,128) end)
        item:registerEvent("onExecute",Callback)
        m:addChild(item)
        if m:getLength() == 1 then m:selectItem(1) end
        return item
    end

    m:setTitle(Title)
    m:setVisible(false)
    layer:insertSprite(m)
    return m
end

function scene:onLoad()
    local mainMenu = newMenu(100,150,"Main Menu")
    local sceneMenu = newMenu(100,150,"Scene Menu")
    local configMenu = newMenu(100,150,"Config Menu")

    mainMenu:addItem("Run Scene", function() sceneMenu:activate() end)
    mainMenu:addItem("Config", function() configMenu:activate() end)
    mainMenu:addItem("Exit", function() love.event.quit() end)

    for _,file in ipairs(love.filesystem.getDirectoryItems(".")) do
        local file, ext = string.match(file,"(.+).(...)")
        if ext == "sce" then
            print("found")
            sceneMenu:addItem(file)
        end
    end

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
    end
end

function scene:onStop()
    --deconstructon logic here
end

return scene