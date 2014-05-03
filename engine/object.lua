local object = {}
function object.new()
    local slaves

    local masters

    local attrib = {}

    local onChanged
    local i = {}

    function i:setAttribute(index, value)
        if index and value then attrib[index] = value end
        if onChanged then onChanged(self,index,value)end
        if slaves then
            for slave, attributes in pairs(slaves) do
                for attribute in pairs(attributes) do
                    if attribute == index then slave:setAttribute() end
                end
            end
        end
    end

    function i:getAttribute(index)
        if masters then
            for object, attributes in pairs(masters) do
                for attribute, func in pairs(attributes) do
                    if attribute == index then
                        return func()
                    end
                end
            end
        end
        return attrib[index]
    end

    function i:getRawAttribute(index)
        return attrib[index]
    end

    function i:setAttributeLink(Child, AttrA, AttrB, Func)
        AttrB = AttrB or AttrA
        Func = Func or function(a,b) return a end
        local oa = self:getAttribute(AttrA)
        local get = function()
            local a = self:getAttribute(AttrA) - oa
            local b = Child:getRawAttribute(AttrB)
            --if AttrA == "pos_x" then print(Child,a,b) end
            return Func(a,b)
        end
        self:setSlaveAttribute(Child,AttrA)
        Child:setMasterAttribute(self,AttrB,get)
    end

    function i:unsetAttributeLink(Child, AttrA, AttrB)
        AttrB = AttrB or AttrA
        self:unsetSlaveAttribute(Child,AttrA)
        Child:unsetMasterAttribute(self,AttrB)
    end

    function i:setSlaveAttribute(Slave,AttrA)
        if not slaves then slaves = {} setmetatable(slaves,{__mode="k"}) end
        if not slaves[Slave] then slaves[Slave] = {} end
        slaves[Slave][AttrA] = true
    end

    function i:unsetSlaveAttribute(Slave,AttrA)
        slaves[Slave][AttrA] = nil
    end

    function i:setMasterAttribute(Master, AttrB, Func)
        if not masters then masters = {} end
        if not masters[Master] then masters[Master] = {} setmetatable(masters,{__mode="k"}) end
        masters[Master][AttrB] = Func
    end

    function i:unsetMasterAttribute(Master, AttrB)
        masters[Master][AttrB] = nil
    end


    function i:removeAttributeLink(objectB, attr)

    end

    function i:setAttributeCallback(Func)
        onChanged = Func
    end

    return i
end

return object