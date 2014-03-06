local group = require(ENGINE_PATH.."/group")

local menu = {
    new = function(X,Y,Title)
        local currentIndex = 1
        local title

        local i = group.new(X,Y)

        function i:getCurrentItem()
            local content = self:getChildren()
            return content[currentIndex]
        end

        function i:getCurrentIndex()
            return currentIndex
        end

        function i:getLength()
            local content = self:getChildren()
            return #content
        end

        function i:execute()
            local content = self:getChildren()
            if content[currentIndex] then
                content[currentIndex]:fireEvent("onExecute")
            end
        end

        function i:selectItem(id, Dir)
            local content = self:getChildren()
            if #content >= 1 then
                for i,v in ipairs(content) do
                end
                content[currentIndex]:fireEvent("onDeselect",Dir)
                if type(id) == "number" and content[id] then
                    currentIndex = id
                else
                    for i,v in ipairs(content) do
                        if v == id then currentIndex = id end
                    end
                end
                content[currentIndex]:fireEvent("onSelect",Dir)
            end
        end

        function i:nextItem()
            local content = self:getChildren()
            if currentIndex == #content then
                self:selectItem(1, "first")
            else
                self:selectItem(currentIndex+1, "next")
            end
        end

        function i:prevItem()
            local content = self:getChildren()
            if currentIndex == 1 then
                self:selectItem(#content, "last")
            else
                self:selectItem(currentIndex-1, "prev")
            end
        end

        function i:setTitle(Title)
            title = Title
        end

        function i:getTitle()
            return title
        end

        if Title then i:setTitle(Title) end

        return i
    end
}

return menu