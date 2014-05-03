 local data = {}

function data.equals(a,b)
    if type(a) == "table" then
        for i=1, #a do
            if a[i] == b then
                return true
            end
        end
    else
    return a == b
    end
end

function data.isTrue(a)
    return a
end

function data.equalsNot(a,b)
     if type(a) == "table" then
         for i=1, #a do
             if a[i] ~= b then
                 return true
             end
         end
     else
         return a ~= b
     end
end

function data.greaterThan(a,b)
    return a > b
end

function data.lessThan(a,b)
    return a < b
end

function data.contains(a,str)
    return a:find(str)
end

function data.isOneOf(a, t)
    for i=1, #t do
        if data.equals(a,t[i]) then return true end
    end
end

function data.filter(t, filter)
    local results = {}
    for i=1, #t do
        local add = true
        for field, value in pairs(filter) do
            --print(field,t[i][field],value[2])
            if not value[1](t[i][field],value[2]) then
                add = false
            end
        end
        if add then table.insert(results, t[i]) end
    end
    return results
end

function data.find(t,filter)
    local results = {}
    for i=1, #t do
        local add = true
        for field, value in pairs(filter) do
            if not value[1](t[i][field],value[2]) then
                add = false
            end
        end
        if add then table.insert(results, i) end
    end
    return unpack(results)
end

 --example: cm.data.filter( database.games,{filename={cm.data.equals,name}} )
return data