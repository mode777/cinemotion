local fs = love.filesystem
local serialize = {}

local function serializeTable(Table)
    local buffer = {}
    local function add(str)
        table.insert(buffer,str)
    end
    local type,pairs,string = type,pairs,string
    --add("\r\n{\r\n")
    add("{")
    local count = 0
    for i, v in pairs(Table) do
        if type(i) == "string" then
            add(string.format("[%q]=",i))
        end
        if type(v) == "string" then
            add("[["..v.."]]")
        elseif type(v) == "number" then
            add(v)
        elseif type(v) == "table" then
            add(serializeTable(v))
        elseif type(v) == "boolean" then
            if v then add("true")
            else add("false")
            end
        end
        --add(",\r\n")
        add(",")
        count = count + 1
    end
    if count ~= 0 then table.remove(buffer,#buffer) end
    --add("\r\n}\r\n")
    add("}")
    return table.concat(buffer)

end

function serialize.save(Table, Name)
    local t = love.timer.getTime()
    print("start serializing")
    local str = "return "..serializeTable(Table)
    fs.write( Name, str )
    print("finished "..love.timer.getTime()-t)
end

function serialize.saveString(Str, Name)
    fs.write( Name, Str )
end

function serialize.load(Name)
    if not fs.exists(Name) then return end
    return assert(assert(fs.load( Name ))())
end

local function split(self, pat)
    local st, g = 1, self:gmatch("()("..pat..")")
    local function getter(self, segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
    end
    local function splitter(self)
        if st then return getter(self, st, g()) end
    end
    return splitter, self
end

function serialize.CSVToArray(Name, Separator)
    local data = {}
    for line in fs.lines(Name) do
        local subdata = {}
        for parsed in split(line,Separator) do
            if parsed == tostring(tonumber(parsed)) then
                parsed = tonumber(parsed)
            elseif parsed == "true" or parsed == "false" then
                parsed = parsed=="true" and true or false
            end
            table.insert(subdata,parsed)
        end
        table.insert(data, subdata)
    end
    return data
end

function serialize.CSVToDictionary(Name, Separator)
    local array = cine.serialize.CSVToArray(Name,Separator)
    local dict = {}
    for i=2, #array do
        local newitem = {}
        for j=1, #array[1] do
            newitem[array[1][j]] = array[i][j]
        end
        table.insert(dict,newitem)
    end
    return dict
end

function serialize.CSVToPairs(Name, Separator)
    local array = cine.serialize.CSVToArray(Name,Separator)
    local pairs = {}
    for i=1, #array do
        pairs[array[i][1]] = array[i][2]
    end
    return pairs
end

function serialize.CSVToColumn(Name, Separator, index)
    index = index or 1
    local array = serialize.CSVToArray(Name, Separator)
    local list = {}
    for i=1, #array do
       table.insert(list, array[i][index])
    end
    return list
end

function serialize.CSVToRow(Name, Separator, index)
    index = index or 1
    local array = serialize.CSVToArray(Name, Separator)
    local list = {}
    for i=1, #array[index] do
        table.insert(list, array[index][i])
    end
    return list
end

function serialize.dictionaryToCSV(dict,Name,Separator)
    local buffer = {}
    local categories = {}
    local allCategories = {}
    for i=1, #dict do --collect all possible values
        for index in pairs(dict[i]) do
            if not allCategories[index] then
                table.insert(categories,index)
                table.insert(buffer,index..Separator)
                allCategories[index] = true
            end
        end
    end
    table.insert(buffer,"\r\n")
    for i=1, #dict do
        for _,cat in ipairs(categories) do
            local value = dict[i][cat] or ""
            if type(value) == "string" then
                table.insert(buffer,value..Separator)
            elseif type(value) == "number" then
                table.insert(buffer,value..Separator)
            elseif type(value) == "boolean" then
                value = true and "true" or "false"
                table.insert(buffer,value ..Separator)
            else
                error("Cannot serialize "..type(value))
            end
        end
        table.insert(buffer,"\r\n")
    end
    local str = table.concat(buffer)
    serialize.saveString(str,Name)
end

return serialize