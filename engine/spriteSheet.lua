local modN = "[spriteSheet]"
local serialize = require(ENGINE_PATH.."/serialize")
local drawableSpritesheet = require(ENGINE_PATH.."/sourceSpritesheet")

local Node = {}
local count = 0

Node.new = function(parent)
    local id = count
    count = count +1
    local instance = {}
    local child = {}
    local occupied

    instance.rc = {}
    if parent then setmetatable(instance.rc,{__index=parent.rc}) end

    function instance.getSize()
        return instance.rc.x2, instance.rc.y2
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
        else
            --parent:grow()
        end
    end
    function instance:insert(w,h)
        if not parent and not instance.rc.x1 then
            local rw, rh = 2,2
            while rw < w do rw = rw*2 end
            while rh < h do rh = rh*2 end
            instance.rc = {x1 = 0, y1 = 0, x2 = rw, y2 = rh }
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

local spriteSheet = {}

function spriteSheet.load(name)
    local sheet
    local fs = love.filesystem
    sheet = serialize.load(name)

    local function hasChanged()
        local count = 0
        for _,file in pairs(fs.getDirectoryItems (sheet.path)) do
            if not (file == "." or file == "..") then count = count +1 end
        end
        if not (count == #sheet.sprites) then return true end
        for _,v in pairs(sheet.sprites) do
            if not (fs.getLastModified(sheet.path.."//"..v.name) == v.mod) then return true end
        end
        return false
    end

    if fs.isDirectory (sheet.path) then --check spritesheet and update if necessary
        print(modN, name, "(dynamic sheet)")
        if hasChanged() then
            print(modN, name, "(has changed, rebuilding...)")
            spriteSheet.create(sheet.path, name)
            return spriteSheet.load(name)
        end
    else
        print(modN, name, "(static sheet)")
    end

    local drawable = drawableSpritesheet.new(sheet.img)-- TODO: LOAD DRAWABLE OBJECT DRAWABLE SPRITESHEET

    for i, frame in ipairs ( sheet.sprites ) do
        drawable:addQuad(frame.x,frame.y,frame.w,frame.h,frame.name)
    end

  return drawable
end

function spriteSheet.create(folder, name)
    local filesystem = love.filesystem
    local image = love.image
    local max = math.max
    local files = {}

    for _,file in pairs(filesystem.getDirectoryItems(folder)) do --iterate all files in folder
        if not (file == "." or file == "..") then
            local img = image.newImageData(folder.."//"..file)
            local w,h = img:getWidth(),img:getHeight()
            table.insert(files,{img=img,name=file,mod=filesystem.getLastModified(folder.."//"..file),w=w,h=h})
        end
    end

    table.sort(files, function(i1,i2) --sort images by largest side
        if max(i1.w, i1.h) > max(i2.w, i2.h) then return true end
    end)

    local spritesheet = Node.new() --create root for binary tree
    local layout = {}
    for _, file in ipairs(files) do
        local x,y
        x,y = spritesheet:insert(file.w,file.h)
        while not x do --if no room, grow the spritesheet
            spritesheet:grow()
            x,y = spritesheet:insert(file.w,file.h)
        end
        if x then file.x, file.y = x,y end
    end

    local spriteImage = image.newImageData(spritesheet:getSize()) --create the new spritesheet image

    for _, file in ipairs(files) do
        spriteImage:paste(file.img,file.x,file.y,0,0,file.w,file.h)
        file.img = nil --delete the image
    end
    local w,h = spritesheet:getSize()
    serialize.save({img = name..".png", name = name, path=folder, w=w, h=h, sprites=files},name..".spr")
    spriteImage:encode(name..".png")
    print("spritesheet created. size:",w,h)
end

return spriteSheet
