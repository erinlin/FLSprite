-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local FLSprite = require "FLSprite"

-- FLSprite.load( filePath [,optional: system.ResourceDirectory etc. ][, optional: isPreload boolean ] )
-- preload texture in memory
local sheetInfo = FLSprite.load("demo.json", true)
local sheet = sheetInfo:getImageSheet()

-- newImage
local girl = display.newImage( sheet, sheetInfo:getFrameIndex("Character Horn Girl.png" ))
girl.x = 100; girl.y = 100

-- newImageRect
local frameIndex, frameData = sheetInfo:getFrameData("Character Horn Girl.png")
local girl1 = display.newImage( sheet, frameIndex, frameData.width, frameData.height )
girl1.x = 180; girl1.y = 100

-- sprite
local data = sheetInfo:getSequenceData("ppl01_act1")
-- rewrite loopCount, default is loop
data.loopCount = 3
-- rewrite loopDirection
data.loopDirection = "bounce"
local sp = display.newSprite( sheet , data )
sp.x = 180; sp.y = 240
sp:play()


-- sprite for all actions
local index = 2
local data1 = sheetInfo:getSequenceData()
local sp1 = display.newSprite( sheet , data1 )
sp1.x = 120; sp1.y = 320
sp1:play()

local function swapSheet()
    sp1:setSequence( "ppl01_act"..index )
    index = index==2 and 1 or 2
    sp1:play()
end

timer.performWithDelay( 2000, swapSheet, 0 )

-- clear cache
-- FLSprite.clear("demo.json")

