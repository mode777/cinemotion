local sprite = require(ENGINE_PATH.."/sprite")

local group = {}

function group.new(X,Y)
    local children = {}
    local visible = true

    local i = sprite.new(X,Y)

    function i:addChild(Child)
        table.insert(children,Child)
        Child:setVisible(visible)
        local layer = self:getLayer()
        if layer then layer:insertSprite(Child) end
    end

    function i:removeChild(Child)
        if type(s) == "number" then
            table.remove(children, Child)
        else
            for i, child in ipairs(children) do
                if Child == child then table.remove(children,i) end
            end
        end
    end

    function i:getChildren()
        return children
    end

    function i:setVisible(bool)
        visible = bool
        for i, child in ipairs(children) do
            child:setVisible(bool)
        end
    end

    function i:getVisible(bool)
        return visible
    end

    local movePos = i.movePos --extending movePos
    function i:movePos(X,Y,T)
        for _, child in pairs(children) do
            child:movePos(X,Y,T)
        end
        return movePos(self,X,Y,T)
    end

    function i:isGroup()
        return true
    end

    function i:draw()
        --dummy function to prevent group drawing
        --todo: debug lines?
    end

    return i
end

return group