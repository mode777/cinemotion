local serialize = require(ENGINE_PATH.."/serialize")
local dialog = {}
local onOption = function() end
local onSay = function() end

function dialog.load(filename)
    local indices = {}
    local ignore = {}
    local data = serialize.CSVToArray(filename,";")
    for i=1, #data do
        if data[i][1]~="" then
            indices[data[i][1]] = i
        end
        data[i][5] = data[i][5] ~= "" and nil or data[i][5]
    end

    local i = {}

    function i:run()
        local options = {}
        local index = 1
        local line = data[index]
        while data[index] do
            line = data[index]
            local type = line[2]
            if ignore[index] then type = "" end --blank the line if it is ignored
            if #options > 0 and (type ~= "opt" and type ~= "") then --first line after options that is not blank
                local id = onOption(options)
                options = {}
                index = indices[id]
            elseif type == "opt" then
                options[#options+1] = {line[3],line[5] }
                index = index + 1
            elseif type == "say" then
                onSay(line[3],line[4])
                index = line[5] or index+1
            elseif type == "red" then
                data[indices[line[2]]][5] = line[4] --replace the jump command at given index
                index = indices[line[5]] or index+1
            elseif type == "tgl" then
                if line[4] == "on" then
                    ignore[indices[line[3]]] = true
                elseif line[4] == "off" then
                    ignore[indices[line[3]]] = nil
                end
                index = indices[line[5]] or index+1
            elseif type == "scr" then
                assert(loadstring(line[3]))()
                index = indices[line[5]] or index+1
            elseif type == "con" then
                local cond = loadstring(line[3])
                if cond() then
                    index = indices[4]
                else
                    index = indices[5]
                end
            else
                index = index+1
            end
        end
    end

    return i
end

function dialog.registerCallbacks(option,say)
    onOption = option
    onSay = say
end

return dialog