local asset = {}
local datas = {}
setmetatable(datas,{__mode="v"})
local names = {}
setmetatable(names,{__mode="k"})

function asset.getData(Filename)
    return datas[Filename]
end

function asset.getName(Data)
    return names[Data]
end

function asset.set(Filename,Data)
    if datas[Filename] then
        if datas[Filename] ~= Data then
            local i = 2
            while datas[Filename.."("..i..")"] do i = i+1 end
            names[Data] = Filename.."("..i..")"
            datas[Filename.."("..i..")"] = Data
        else
            return
        end
    else
        names[Data] = Filename
        datas[Filename] = Data
    end
end

function asset.getAssets()
    return datas
end

return asset