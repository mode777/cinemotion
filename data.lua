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

data._DOC = {
    equals = {"Returns true if both variables match. If a is a table, returns true if one of its elements matches",{ {"var","a"},{"var","b"} },{ {"bool","result","True if elements match"} }},
    isTrue = {"Returns true if a is true.",{ {"var","a"} },{ {"bool","result"} }},
    greaterThan = {"Returns true if a greater than b",{ {"number","a"},{"number","b"} },{ {"bool","result"} }},
    lessThan = {"Returns true if a less than b",{ {"number","a"},{"number","b"} },{ {"bool","result"} }},
    containsThan = {"Returns true if string a contains string b",{ {"string","a"},{"string","b"} },{ {"bool","result"} }},
    filter = {"Creates a new table from a given array and a filter table",{ {"table","data","For example: t={ {name='Walter',age=54}, {name='Walter',age=18}, {name='Walter', age=22} }"},{"table","filter","For example t={ name={cine.data.equals,'Walter'}, age={cine.data.greaterThan,21} }"} },{ {"table","results","Our example would give you: t={ {name='Walter',age=54}, {name='Walter', age=22} }; All People with the name Walter and the age above 21."} }},
    find = {"Same as filter but unpacks the results, so you can do: firstresult, secondresult = cine.data.find(t,f)",{ {"table","data"},{"table","filter"} },{ {"var","results"} }},
}
return data