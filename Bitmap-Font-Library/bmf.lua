----------------------------------------------------------------------------------------------------
---- Bitmap Font for Corona SDK (Original author: Juan Jose Sanchez Ramirez)
---- http://www.ApolloMobileApps.com
---- Copyright 2014 Apollo Mobile Apps
---- The MIT License (MIT) (see LICENSE.txt for details)
----------------------------------------------------------------------------------------------------
--
-- Date: January 2015
--
-- Version: 1.01
--
-- File name: bitmapfont.lua
--
---- Adapted from Aaron Meriwether (a.k.a. "p120ph37")'s ShoeBox / AngelCode Bitmap Font Support.
----
---- http://developer.coronalabs.com/forum/2011/02/05/bitmap-font
----
---- ShoeBox is a free Adobe Air based app for Windows and Mac OSX with game and UI related tools.
---- Each tool uses a drag and drop - or clipboard interaction for a quick workflow.
----
---- http://renderhjs.net/shoebox/
----
---- AngelCode Bitmap Font Generator allows you to generate bitmap fonts from TrueType fonts. The
---- application generates both image files and character descriptions that can be read by a game
---- for easy rendering of fonts.
----
---- The program is freeware and open source.
----
---- http://www.angelcode.com/products/bmfont/
----
---- This program supports dynamic selection of fonts. Higher resolution devices will use higher
---- resolution images. For best results, the scale factor should be equal to the used in the
---- config.lua file.
----
---- To activate dynamic selection of fonts set dynamicScaling to true. To deactivate it set
---- it to false. Be sure to have ONLY the necessary image files in your resource directory.
----
---- Update by Juan Jose Sanchez Ramirez in January 15, 2015.
----   * Added parent group parameter
----
---- Updated by Juan Jose Sanchez Ramirez in November 23, 2014.
----   * Added dynamic font scaling
----   * Fixed alignment
----
---- Updated by Michael Wilson in April 30, 2013.
----   * Updated to a table based module
----   * Moved from sprites to image sheets
----   * Added "path" from forum post by KenRogoway
----   * Removed input object
----
---- http://forums.coronalabs.com/topic/34445-shoebox-free-cross-platform-sprite-packerbitmap-font-tool/
--
----------------------------------------------------------------------------------------------------
 
 
local sbFont = {}

local sbFont_mt = { __index = sbFont }

local dynamicScaling = true
local imageSuffix = { '@2x', '@4x' }
local scaleFactor = { 1.5, 3 }

local width = display.pixelWidth
local height = display.pixelHeight

local ceil = math.ceil
local floor = math.floor

local aspectRatio = width / ( height / width > 1.5 and 320 or ceil( 480 / ( height / width ) ) )


----------------------------------------------------------------------------------------------------
-- FUNCTION LOAD NEW FONT
--
---- Specify an AngelCode Bitmap Font file (".fnt").
---- The image sheet referencing this file needs to be located in the resource directory.
---- It returns a font object that can be used when calling the sbFont:newString() function.
----------------------------------------------------------------------------------------------------

function sbFont:load( fntFile, path )
    local path = path or ''
    local function extract( s, p )
        return string.match( s, p ), string.gsub( s, p, '', 1 )
    end
    local font = {
        info = {},
        spritesheets = {},
        sprites = {},
        chars = {},
        kernings = {}
    }
    local suffix = ''
    if dynamicScaling then
        if scaleFactor[2] and aspectRatio >= scaleFactor[2] then suffix = imageSuffix[2]
        elseif scaleFactor[1] and aspectRatio >= scaleFactor[1] then suffix = imageSuffix[1]
        end
    end
    local readline = io.lines( system.pathForFile( path .. fntFile .. suffix .. '.fnt', system.ResourceDirectory ) )
    for line in readline do
        local t = {}
        local tag
        tag, line = extract( line, '^%s*([%a_]+)%s*' )
        while string.len( line ) > 0 do
            local k, v
            k, line = extract( line, '^([%a_]+)=' )
            if not k then break end
            v, line = extract( line, '^"([^"]*)"%s*' )
            if not v then
                v, line = extract( line, '^([^%s]*)%s*' )
            end
            if not v then break end
            t[ k ] = v
        end
        if tag == 'info' or tag == 'common' then
            for k, v in pairs( t ) do font.info[ k ] = v end
        elseif tag == 'page' then
            font.spritesheets[ 1 + t.id ] = { file = t.file, frames = {} }
        elseif tag == 'char' then
            t.letter = string.char( t.id )
            font.chars[ t.letter ] = {}
            for k, v in pairs( t ) do font.chars[ t.letter ][ k ] = v end
            if 0 + font.chars[ t.letter ].width > 0 and 0 + font.chars[ t.letter ].height > 0 then
                font.spritesheets[ 1 + t.page ].frames[ #font.spritesheets[ 1 + t.page ].frames + 1 ] = {
                    x = 0 + t.x,
                    y = 0 + t.y,
                    width = 0 + t.width,
                    height = 0 + t.height
                }
                font.sprites[ t.letter ] = {
                    spritesheet = 1 + t.page,
                    frame = #font.spritesheets[ 1 + t.page ].frames
                }
            end
        elseif( tag == 'kerning' ) then
            font.kernings[ string.char( t.first ) .. string.char( t.second ) ] = 0 + t.amount
        end
    end
    for k, v in pairs( font.spritesheets ) do
        font.spritesheets[ k ].sheet = graphics.newImageSheet( path .. v.file, v )
    end
    for k, v in pairs( font.sprites ) do
        font.sprites[ k ].frame = v.frame
    end
    return font
end
 
----------------------------------------------------------------------------------------------------
-- LOCAL FUNCTION ACCESSORIZE
----------------------------------------------------------------------------------------------------

local function accessorize( t )
    local mt = getmetatable( t )
    setmetatable( t, {
        __index = function( t, k )
            if rawget( t, 'get_' .. k ) then
                return rawget(t, 'get_' .. k )( t, k )
            elseif rawget( t, 'raw_' .. k ) then
                return rawget( t, 'raw_' .. k )
            elseif mt.__index then
                return mt.__index( t, k )
            else
                return nil
            end
        end,
        __newindex = function( t, k, v )
            if rawget( t, 'set_' .. k ) then
                rawget( t, 'set_' .. k )( t, k, v )
            elseif rawget( t, 'raw_' .. k ) then
                rawset( t, 'raw_' .. k, v )
            elseif mt.__newindex then
                mt.__newindex( t, k, v )
            else
                rawset( t, 'raw_' .. k, v )
            end
        end
    } )
end
 
----------------------------------------------------------------------------------------------------
-- LOCAL FUNCTION REMOVERIZE
----------------------------------------------------------------------------------------------------

local function removerize( t )
    local old = t.removeSelf
    t.removeSelf = function( o )
        for i = o.numChildren, 1, -1 do o[ i ]:removeSelf() end
        old( o )
    end
end
 
----------------------------------------------------------------------------------------------------
-- FUNCTION NEW STRING
--
---- Pass a font object and a string. Group parameter is optional.
---- It returns a display object of the rendered string.
---- Fields 'font', 'text' and 'align' can be read and modified.
---- Text can be aligned to the left, right, or center.
----------------------------------------------------------------------------------------------------

function sbFont:newString( group, font, text, align )
    local obj = display.newGroup()
    if type(font) == 'string' then
        align = text
        text = font
        font = group
    else
        group:insert(obj)
    end
    accessorize( obj )
    removerize( obj )
    obj.set_font = function( t, k, v ) obj.raw_font = v end
    obj.set_align = function( t, k, v )
        local width = t.contentWidth
        local w = width
        if dynamicScaling then
            if scaleFactor[2] and aspectRatio >= scaleFactor[2] then w = width * 4
            elseif scaleFactor[1] and aspectRatio >= scaleFactor[1] then w = width * 2
            end
        end
        t.raw_align = v
        if t.raw_align == 'right' then
            for i = 1, t.numChildren do
                t[i].x = t[i].x - w
            end
        elseif t.raw_align == 'center' then
            for i = 1, t.numChildren do
                t[i].x = t[i].x - floor( w * 0.5 )
            end
        elseif t.raw_align == 'left' then
            for i = 1, t.numChildren do
                t[i].x = t[i].x
            end
        end
    end
    obj.set_text = function( t, k, v )
        t.raw_text = v
        for i = t.numChildren, 1, -1 do t[i]:removeSelf() end
        local x = 0
        local y = 0
        local last = ''
        local xMax = 0
        local yMax = 0
        if t.raw_font then
            for c in string.gmatch( t.raw_text..'\n', '(.)' ) do
                if c == '\n' then
                    x = 0; y = y + t.raw_font.info.lineHeight
                    if y >= yMax then
                        yMax = y
                    end
                elseif t.raw_font.chars[c] then
                    if 0 + t.raw_font.chars[c].width > 0 and 0 + t.raw_font.chars[c].height > 0 then
                        local letter = display.newImage( font.spritesheets[ t.raw_font.sprites[c].spritesheet ].sheet, t.raw_font.sprites[c].frame)
                        letter.anchorX, letter.anchorY = 0, 0
                        if t.raw_font.kernings[ last .. c ] then
                            x = x + font.kernings[ last .. c ]
                        end
                        letter.x = t.raw_font.chars[c].xoffset + x
                        letter.y = t.raw_font.chars[c].yoffset - t.raw_font.info.base + y - ceil( t.raw_font.info.lineHeight * 0.5 )
                        t:insert( letter )
                        last = c
                    end
                    x = x + t.raw_font.chars[c].xadvance
                    if x >= xMax then
                        xMax = x
                    end
                end
            end
        end
        t.align = obj.align
    end
    obj.font = font
    obj.align = align or 'left'
    obj.text = text or ''
    local scale = 1
    if dynamicScaling then
        if scaleFactor[2] and aspectRatio >= scaleFactor[2] then scale = 0.25
        elseif scaleFactor[1] and aspectRatio >= scaleFactor[1] then scale = 0.5
        end
    end
    obj.xScale = scale
    obj.yScale = scale
    return obj
end

----------------------------------------------------------------------------------------------------
-- FUNCTION DESTROY
----------------------------------------------------------------------------------------------------

function sbFont:destroy()
end
 
return sbFont
