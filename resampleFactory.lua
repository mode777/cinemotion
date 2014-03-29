love.image = require("love.image")
love.filesystem = require("love.filesystem")

local function resampleImage(path,filename,w,h)
    local oim = love.image.newImageData(path..filename)
    h = h or oim:getHeight()*(w/oim:getWidth())
    local nim = love.image.newImageData(w,h)
    local fx, fy = oim:getWidth()/nim:getWidth(),oim:getHeight()/nim:getHeight()
    local f, c, m= math.floor, math.ceil,math.min
    for y=0, nim:getHeight()-1 do
        for x=0, nim:getWidth()-1 do
            local px, py = x*fx,y*fy
            local minx, miny  = m(f(px),oim:getWidth()-1), m(f(py),oim:getHeight()-1)
            local maxx, maxy  = m(c(px),oim:getWidth()-1), m(c(py),oim:getHeight()-1)
            local v = { {oim:getPixel(minx,miny)},{oim:getPixel(maxx,miny)},{oim:getPixel(maxx,maxy)},{oim:getPixel(minx,maxy)} }
            if miny == maxy then maxy = maxy+1 end
            if minx == maxx then maxx = maxx+1 end
            local result = {}
            for c=1,4 do
                local linA = (maxx-px)/(maxx-minx)*v[1][c] + (px-minx)/(maxx-minx)*v[2][c]
                local linB = (maxx-px)/(maxx-minx)*v[4][c] + (px-minx)/(maxx-minx)*v[3][c]
                local value = (maxy-py)/(maxy-miny)*linA  + (py-miny)/(maxx-minx)*linB
                result[c] = f(value)
            end
            nim:setPixel(x,y,unpack(result))
        end
    end

    nim:encode(filename, "jpg")
    print("Resampling finished: "..filename)
end

local channel = love.thread.getChannel("resample")
while true do
    if channel:getCount() > 0 then
        resampleImage(unpack(channel:pop()))
    end
end