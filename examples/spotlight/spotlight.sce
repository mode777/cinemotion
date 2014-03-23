local cm = require(ENGINE_PATH)
local scene = {}
local layer
local spotcone
function scene:onLoad()
    layer = cm.layer.new()
    local spotbase = cm.sprite.new(320,430,cm.sourceImage.new("examples/spotlight/spot1.png"))
    spotcone = cm.sprite.new(320,50,cm.sourceImage.new("examples/spotlight/spot2.png"))
    layer:insertSprite(spotbase)
    layer:insertSprite(spotcone)
    spotcone:setTweenStyle("easeinout")
    spotcone:setPiv(73,0)
    spotbase:center()
    spotcone:setAttributeLink(spotbase,"rot","sca_x",function(a,b)
        --return(2)
        return(b/math.cos(a))
    end)
    spotcone:setAttributeLink(spotbase,"rot","pos_x",function(a,b)
        local cx,cy = spotcone:getPos()
        local px,py = spotbase:getRawAttribute("pos_x"), spotbase:getRawAttribute("pos_y")

        local s = math.sin(a)
        local c = math.cos(a)

        -- translate point back to origin:
        px = px-cx;
        py = py-cy;

        -- rotate point
        local xnew = px * c - py * s

        -- translate point back:
        px = xnew + cx

        return b+xnew

    end)

    spotcone:setAttributeLink(spotbase,"rot","piv_x",function(a,b)
        local cx,cy = spotcone:getPos()
        local px,py = spotbase:getRawAttribute("pos_x"), spotbase:getRawAttribute("pos_y")

        local s = math.sin(a)
        local c = math.cos(a)

        -- translate point back to origin:
        px = px-cx;
        py = py-cy;

        -- rotate point
        local xnew = px * c - py * s

        -- translate point back:
        px = xnew + cx

        return b-xnew/4

    end)
    --initialize your scene here
end

function scene:onUpdate()
    cm.thread.waitThread(spotcone:moveRotTo(math.rad(45),3))
    cm.thread.waitThread(spotcone:moveRotTo(math.rad(-45),3))
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene