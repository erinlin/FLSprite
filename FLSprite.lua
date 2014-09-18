--[[
    FLSpriteSheet.lua
    Copyright (c) 2014 Erin Lin
    erinylin@gmail.com
    Licensed under the MIT license.
]]--

-- output example
-- M.sequenceData =
-- {
--     name="walking",
--     start=3,
--     count=6,
--     loopCount = 0    -- Default is 0 (loop indefinitely)
-- }

-- M.sheet =
-- {       
--     frames =
--     {
--         --frame 1
--         {
--             x = 0,
--             y = 0,
--             width = 203,
--             height = 256,
--             sourceX = 60,
--             sourceY = 11,
--             sourceWidth = 277,
--             sourceHeight = 276
--         },
--         --frame 2
--         {
--             x = 203,
--             y = 0,
--             width = 247,
--             height = 262,
--             sourceX = 16,
--             sourceY = 5,
--             sourceWidth = 277,
--             sourceHeight = 276
--         },
--     },
--     sheetContentWidth = 450,
--     sheetContentHeight = 262
-- }



local json = require "json"

local next = next
local ceil = math.ceil
local find = string.find
local sub = string.sub
local len = string.len

local M = {}
M.__cachelist = {}

local SheetInfo = {
    image = nil, 
    sheet = nil,
    sheetData = {
        frames = {}
    },
    sequenceData = {},
    frameIndex = {}
}
local SheetInfo_m = {__index=SheetInfo}

function SheetInfo.new()
    return setmetatable( {}, SheetInfo_m  )
end

function SheetInfo:getImageSheet()
    if self.sheet then return self.sheet end
    self.sheet =  graphics.newImageSheet( self.image, self.sheetData )
    return self.sheet
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

function SheetInfo:getFrameData(name)
    local index = self.frameIndex[name]
    return index, self.sheetData.frames[ index ];
end

function SheetInfo:getSequenceData(name, frameRate )
    local frameRate = frameRate or 24
    if name then
        for i,v in next,(self.sequenceData) do
            if v.name==name then
                v.time = v.count * ceil(1000/frameRate)
                return v
            end
        end
        return nil
    else
        local rate = ceil(1000/frameRate)
        for i,v in next,(self.sequenceData) do
            v.time = v.count * rate
        end
        return self.sequenceData
    end
end

local loadFile = function( filename, baseDir )
    local path = system.pathForFile( filename, baseDir )
    local f = io.open( path, 'r' )
    local data = f:read( "*a" )
    f:close()
    -- local result = json.decode( data )
    return json.decode( data )
end

function M.clear(name)
    if name then
        M.__cachelist[name] = nil
    else
        M.__cachelist = {}
    end
end


local function parse( data )
    local options = SheetInfo.new()
    assert( data.frames, "Wrong Flash Sprite Sheet output format. It must be a JSON-Array format.")
    options.image = data.meta.image
    options.sheet = nil
    options.sheetData = {
        frames = {},
        sheetContentWidth = data.meta.size.w,
        sheetContentHeight = data.meta.size.h
    }
    options.sequenceData = {}
    options.frameIndex = {}

    local tempName = ""
    local tempData = {}

    for i=1,#data.frames do
        local o = {}
        local frameData = data.frames[i]
        o.x, o.y, o.width, o.height = frameData.frame.x, frameData.frame.y, frameData.frame.w, frameData.frame.h

        options.frameIndex[frameData.filename] = i
        options.sheetData.frames[i] = o

        local checkStr = sub( frameData.filename, -4 )
        -- to check is animation or not.
        if tonumber( checkStr ) then
            o.sourceX = frameData.spriteSourceSize.x
            o.sourceY = frameData.spriteSourceSize.y
            o.sourceWidth = frameData.spriteSourceSize.w
            o.sourceHeight = frameData.spriteSourceSize.h
            if checkStr=="0000" then
                tempData = {}
                local l = len(frameData.filename)
                tempData.name = sub( frameData.filename,1, l-4 )
                tempData.start = i
                tempName = tempData.name
                tempData.count = 1
                tempData.loopCount = 0
                options.sequenceData[#options.sequenceData+1] = tempData
            elseif tempData.name==tempName then
                tempData.count = tempData.count + 1
            end
        end 
    end

    return options
end

function M.load( path , baseDir, preload )
    if M.__cachelist[path] then
        return M.__cachelist[path]
    end
    local tp = type(baseDir)
    local isPreload = tp=="boolean" or preload
    local baseDir = tp=="userdata" and baseDir or system.ResourceDirectory
    local data = loadFile( path, baseDir )
    local result = parse(data)
    
    if isPreload then
        M.__cachelist[path] = result
        result:getImageSheet()
    end

    return result
end

return M