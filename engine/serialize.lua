local fs = love.filesystem
local serialize = {}

local function serializeTable(Table)
    local str = "\r\n{\r\n"
    local count = 0
    for i, v in pairs(Table) do
        if type(i) == "string" then
            str = str.."[\""..i.."\"]".."="
        end
        if type(v) == "string" then
            str = str.."[["..v.."]]"
        elseif type(v) == "number" then
            str = str..v
        elseif type(v) == "table" then
            str = str..serializeTable(v)
        elseif type(v) == "boolean" then
            if v then str = str.."true"
            else str = str.."false"
            end
        end
        str = str..",\r\n"
        count = count + 1
    end
    if count ~= 0 then str = string.sub(str,0,-2) end
    str = str.."\r\n}\r\n"
    return str
end

function serialize.save(Table, Name)
    local str = "return "..serializeTable(Table)
    fs.write( Name, str )
    print("[serialize]: Serialized Table", Table, Name)
    --local file = io.open(Name, "w")
    --file:write(str)
    --file:close()
end

function serialize.load(Name)
    return assert(assert(fs.load( Name ))())
end

return serialize