local sourceImage = require(ENGINE_PATH.."/sourceImage")
local sourceSpritefont = {}

function sourceSpritefont.new(filename)
    local i = sourceImage.new(filename..".png")

    local fnt = require (filename)
    local space = 0
    local kern = 0
    local height = fnt.height
    local ascender = fnt.metrics.ascender
    local chars = {}
    for _, v in ipairs(fnt.chars) do
        chars[v.char] = {width = v.width, offset = {x = v.ox,y = v.oy}, quad = love.graphics.newQuad(v.x,v.y,v.w,v.h,i:getImage():getWidth(),i:getImage():getHeight()), kerning={}}
    end
    if fnt.kernings then
        for _, v in ipairs(fnt.kernings) do
            chars[v.from].kerning[v.to] = v.offset
        end
    end

    local textFormat = {} --buffer for text metadata
    setmetatable(textFormat,{__mode="k"})

    local function getWrap(width,text)
        local pos = 0
        local y = 0
        local i = 1
        local last = 0
        local lastwidth = 0
        local line={}
        local width = width or math.huge
        for c in text:gmatch"." do
            if c == "\n" then
                table.insert(line,{last = i, width = pos})
                pos = 0
            elseif pos > width then
                table.insert(line,{last = last, width = lastwidth})
                pos = pos-lastwidth
            end
            if chars[c] then
                local lkern
                if i < text:len() then
                    lkern = chars[c].kerning[text:sub(i+1,i+1)]
                end
                lkern = lkern or 0
                pos = pos + chars[c].width + lkern + kern
                if c == " " then last = i lastwidth = pos end
            end
            i = i+1
        end
        table.insert(line,{last = text:len(), width = pos})
        --if #self.line == 1 then self.width = self.line[1].width end
        return line
    end

    local function getTextFormat(text,align,width)
        local line = getWrap(width,text)
        local height = #line * height
        return {text=text,align=align,width=width or line[1].width ,line=line,height=height}
    end

    local function getSpriteBatch(textFormat)
        local spriteBatch = love.graphics.newSpriteBatch(i:getImage(), textFormat.text:len(), "static")

        local pos = 0
        local i = 1
        local ol = 0

        spriteBatch:bind()
        local line = 1
        for c in textFormat.text:gmatch(".") do
            if i > textFormat.line[line].last then line = line+1 pos = 0 end
            ol = 0--self.line[line+1].width
            if textFormat.align == "right" then ol = textFormat.width-textFormat.line[line].width
            elseif textFormat.align == "center" then ol = (textFormat.width-textFormat.line[line].width)/2
            end
            ol = math.floor(ol)

            if chars[c] then
                --if i <= self.trunc then
                spriteBatch:add( chars[c].quad, ol+pos+chars[c].offset.x, -chars[c].offset.y+(line*(height+space)))
                --end
                local lkern
                if i < textFormat.text:len() then
                    lkern = chars[c].kerning[textFormat.text:sub(i+1,i+1)]
                end
                lkern = lkern or 0
                pos = pos + chars[c].width + lkern + kern
            end
            i = i+1
        end
        spriteBatch:unbind()
        return spriteBatch
    end

    local spriteBatches = {} --Buffer for spritebatches
    setmetatable(spriteBatches,{__mode="k"})

    function i:getSize(sprite)
        local text = sprite:getIndex()
        local align = sprite:getTextAlign() or "left"
        local width = sprite:getTextWidth()
        if not textFormat[sprite] then
            textFormat[sprite] = getTextFormat(text,align,width)
        end
        if text ~= textFormat[sprite].text or
          align ~= textFormat[sprite].align or
          width ~= textFormat[sprite].width then
            textFormat[sprite] = getTextFormat(text,align,width)
            if text and text ~= "" then spriteBatches[sprite] = getSpriteBatch(textFormat[sprite]) end
        end
        return textFormat[sprite].width,textFormat[sprite].height
    end

    function i:getLineHeight()
        return height
    end

    function i:draw(sprite)
        local text = sprite:getIndex()
        if not text or text == "" then return end
        local align = sprite:getTextAlign() or "left"
        local width = sprite:getTextWidth() or textFormat[sprite].width
        if not spriteBatches[sprite] then
            spriteBatches[sprite] = getSpriteBatch(textFormat[sprite])
        end
        love.graphics.draw(spriteBatches[sprite], 0,0)
    end

    return i
end

return sourceSpritefont