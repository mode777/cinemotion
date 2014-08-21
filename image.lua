local serialize = require(ENGINE_PATH.."/serialize")
local drawableSpritesheet = require(ENGINE_PATH.."/sourceSpritesheet")

local Node = {}
local count = 0

Node.new = function(parent,ssw,ssh)
    local id = count
    count = count +1
    local instance = {}
    local child = {}
    local occupied

    instance.rc = {}
    if parent then setmetatable(instance.rc,{__index=parent.rc}) end

    function instance.getSize()
        return ssw,ssh
    end

    function instance.print()
        print(instance.rc.x2, instance.rc.y2)
        for i,v in pairs(child) do
            v.print()
        end
    end

    function instance:grow()
        if not parent then
            if instance.rc.x2 > instance.rc.y2 then  instance.rc.y2 = instance.rc.y2*2
            else instance.rc.x2 = instance.rc.x2*2
            end
            print(instance.rc.x2,instance.rc.y2)
        else

            --parent:grow()
        end
    end

    function instance:insert(w,h)
        if not parent and not instance.rc.x1 then
            --local rw, rh = 2,2
            --while rw < w do rw = rw*2 end
            --while rh < h do rh = rh*2 end
            --rw,rh = 1024,1024
            instance.rc = {x1 = 0, y1 = 0, x2 = ssw, y2 = ssh }
        end
        if child[1] then --if we're not a leaf then
            local x,y = child[1]:insert(w,h) --try inserting into first child
            if x then return x,y end
            return child[2]:insert(w,h) --no room, insert into second
        else
            if occupied then return nil --if there's already a lightmap here, return
            elseif instance.rc.x2 - instance.rc.x1 < w or instance.rc.y2 - instance.rc.y1 < h then return nil --if we're too small, return
            elseif instance.rc.x2 - instance.rc.x1 == w and instance.rc.y2 - instance.rc.y1 == h then --if we're just right, accept
                occupied = true
                return instance.rc.x1,instance.rc.y1
            else --otherwise, gotta split this node and create some kids
                child[1] = Node.new(instance)
                child[2] = Node.new(instance)
                --decide which way to split
                local dw = instance.rc.x2 - instance.rc.x1 - w
                local dh = instance.rc.y2 - instance.rc.y1 - h
                if dw > dh then
                    child[1].rc.x2 = instance.rc.x1+w
                    child[2].rc.x1 = instance.rc.x1+w
                else
                    child[1].rc.y2 = instance.rc.y1+h
                    child[2].rc.y1 = instance.rc.y1+h
                end
                return child[1]:insert(w,h)   --insert into first child we created
            end
        end
    end
    return instance
end

local image = {}

function image.loadSpritesheet(name, imgname)
    local sheet
    local fs = love.filesystem
    sheet = serialize.load(name)
    local drawable = drawableSpritesheet.new(imgname)-- TODO: LOAD DRAWABLE OBJECT DRAWABLE SPRITESHEET

    for i, frame in ipairs ( sheet.sprites ) do
        drawable:addRectangle(frame.x,frame.y,frame.w,frame.h,frame.name,frame.originalw,frame.originalh,frame.offsetx,frame.offsety)
    end
  return drawable
end

function image.crop(img)
    local x1, y1, x2, y2
    local h,w = img:getHeight(),img:getWidth()
    for y=0, h-1 do
        for x=0, w-1 do
            local _,_,_,a = img:getPixel(x,y)
            if a ~= 0 then
                x1 = x1==nil and x or math.min(x1,x)
                x2 = x2==nil and x or math.max(x2,x)
                y1 = y1==nil and y or math.min(y1,y)
                y2 = y2==nil and y or math.max(y2,y)
            end
        end
    end
    local ox,oy = x1,y1

    local newImg = love.image.newImageData(x2+1-x1,y2+1-y1)
    newImg:paste(img,0,0,x1,y1,x2+1-x1,y2+1-y1)
    return newImg,ox,oy
end

function image.cropSymmetrical(list)
    local x1, y1, x2, y2
    local h,w = list[1]:getHeight(),list[1]:getWidth()
    for i=1, #list do
        for y=0, h-1 do
            for x=0, w-1 do
                local _,_,_,a = list[i]:getPixel(x,y)
                if a ~= 0 then
                    x1 = x1==nil and x or math.min(x1,x)
                    x2 = x2==nil and x or math.max(x2,x)
                    y1 = y1==nil and y or math.min(y1,y)
                    y2 = y2==nil and y or math.max(y2,y)
                end
            end
        end
    end
    --x1 = math.min(x1,w-x2) == x1 and x1 or w-x2
    --x2 = w-x1
    --y1 = math.min(y1,h-y2) == y1 and y1 or h-y2
    --y2 = h-y1

    local newList = {}
    print("Cropping symmetrical",x1,x2,y1,y2)
    for i=1, #list do
        local newImg = love.image.newImageData(x2+1-x1,y2+1-y1)
        newImg:paste(list[i],0,0,x1,y1,x2+1-x1,y2+1-y1)
        table.insert(newList,newImg)
    end
    return newList
end

function image.createAnimationSheet(folder,name,delay,crop,folderOut)
    local filesystem = love.filesystem
    local max = math.max
    local files = {}
    local names = {}
    folderOut = folderOut and folderOut.."/" or ""

    for _,file in pairs(filesystem.getDirectoryItems(folder)) do --iterate all files in folder
        --print(name,file,file:match(name..".....png"))
        if file:match(name..".....png") then
            local img = love.image.newImageData(folder.."/"..file)
            table.insert(files,img)
            table.insert(names,file)
        end
    end
    files = image.cropSymmetrical(files)

    for i=1, #files do
        local img = files[i]
        local ox,oy,ow,oh = 0,0,img:getWidth(),img:getHeight()
        if crop then
            --img,ox,oy = image.crop(img)
        end
        local w,h = img:getWidth(),img:getHeight()
        files[i] = {img=img,w=w,h=h,x=0,y=0,index=names[i],ox=ox,oy=oy,animation=name,ow=ow,oh=oh}
    end

    if #files == 0 then error("Animation "..name.." not found.") end

    table.sort(files, function(i1,i2) --sort images by largest side
        if i1.w * i1.h > i2.w * i2.h then return true end
    end)

    local spritesheet = Node.new() --create root for binary tree
    local layout = {}
    for i, file in ipairs(files) do
        local x,y
        x,y = spritesheet:insert(file.w,file.h)
        while not x do --if no room, grow the spritesheet
            spritesheet:grow()
            x,y = spritesheet:insert(file.w,file.h)
        end
        if x then
            file.x, file.y = x,y
        end
    end

    local spriteImage = love.image.newImageData(spritesheet:getSize()) --create the new spritesheet image

    for _, file in ipairs(files) do
        spriteImage:paste(file.img,file.x,file.y,0,0,file.w,file.h)
        file.img = nil --delete the image
    end
    table.sort(files,function(i1,i2) return i1.index < i2.index end)
    local w,h = spritesheet:getSize()
    serialize.dictionaryToCSV(files,folderOut..name..".csv",";")
    spriteImage:encode(folderOut..name..".png")
    print("spritesheet created. size:",w,h)
end

function image.createSpritesheet(folder, name, crop)
    local filesystem = love.filesystem
    local image = love.image
    local max = math.max
    local files = {}

    for _,file in pairs(filesystem.getDirectoryItems(folder)) do --iterate all files in folder
        if not (file == "." or file == "..") then
            local img = image.newImageData(folder.."//"..file)
            local ox,oy,oh,ow = 0,0,img:getHeight(),img:getWidth()
            if crop then
                local x1, y1, x2, y2
                local stop
                for y=0, img:getHeight()-1 do
                    for x=0, img:getWidth()-1 do
                        local _,_,_,a = img:getPixel(x,y)
                        if a ~= 0 then
                            x1 = x1==nil and x or math.min(x1,x)
                            x2 = x2==nil and x or math.max(x2,x)
                            y1 = y1==nil and y or math.min(y1,y)
                            y2 = y2==nil and y or math.max(y2,y)
                        end
                    end
                end
                ox,oy = x1,y1

                local newImg = love.image.newImageData(x2+1-x1,y2+1-y1)
                newImg:paste(img,0,0,x1,y1,x2+1-x1,y2+1-y1)
                img = newImg
            end
            local w,h = img:getWidth(),img:getHeight()
            table.insert(files,{img=img,name=file,offsetx=ox,offsety=oy,originalw=ow,originalh=oh,mod=filesystem.getLastModified(folder.."//"..file),w=w,h=h})
        end
    end

    table.sort(files, function(i1,i2) --sort images by largest side
        if i1.w * i1.h > i2.w * i2.h then return true end
    end)

    local layout = {}
    local sucess
    local ssw,ssh = 2,2
    local spritesheet
    while not sucess do
        spritesheet = Node.new(nil,ssw,ssh) --create root for binary tree
        sucess =true
        for _, file in ipairs(files) do
            local x,y
            local w,h = file.w,file.h
            x,y = spritesheet:insert(w,h)
            if not x then
                sucess = false
                if math.min(ssw,ssh) == ssw then
                    ssw = ssw*2
                else
                    ssh = ssh*2
                end
                break
            end
            if x then file.x, file.y = x,y end
        end
    end
    local spriteImage = image.newImageData(spritesheet:getSize()) --create the new spritesheet image

    for _, file in ipairs(files) do
        spriteImage:paste(file.img,file.x,file.y,0,0,file.w,file.h)
        file.img = nil --delete the image
    end
    local w,h = spritesheet:getSize()
    --serialize.save({img = name..".png", name = name, path=folder, w=w, h=h, sprites=files},name..".lua")
    serialize.dictionaryToCSV(files,name..".csv",";")
    spriteImage:encode(name..".png")
end

return image
