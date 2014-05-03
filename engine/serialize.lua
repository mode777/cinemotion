local fs = love.filesystem
local serialize = {}

local function serializeTable(Table)
    local buffer = {}
    local function add(str)
        table.insert(buffer,str)
    end
    local type,pairs,string = type,pairs,string
    add("\r\n{\r\n")
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
        add(",\r\n")
        count = count + 1
    end
    if count ~= 0 then table.remove(buffer,#buffer) end
    add("\r\n}\r\n")
    return table.concat(buffer)

end

function serialize.save(Table, Name)
    local t = love.timer.getTime()
    print("start serializing")
    local str = "return "..serializeTable(Table)
    fs.write( Name, str )
    print("finished "..love.timer.getTime()-t)
end

function serialize.load(Name)
    if not fs.exists(Name) then return end
    return assert(assert(fs.load( Name ))())
end

return serialize