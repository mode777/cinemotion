local data = {}

function data.equals(a,b)
    return a == b
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
            if not value[1](t[i][field],value[2]) then
                add = false
                break
            end
        end
        if add then table.insert(results, t[i]) end
    end
    return results
end

function data.filter(t, field,func,...)
    if type(t) == "table" then if #t == 0 then error("You need an array for filtering") end else error("You need an array for filtering") end
    local results = {}
    for i=1, #t do
       if not t[i][field] then break end
       if func(t[i][field],...) then
           table.insert(results,t[i])
       end
    end
    return results
end

return data