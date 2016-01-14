----------------------------------------------------------------------------------------------------
---- New Calendar View for Corona SDK (Original author: Juan Jose Sanchez Ramirez)
---- http://www.ApolloMobileApps.com
---- Copyright 2016 Apollo Mobile Apps
---- The MIT License (MIT) (see LICENSE.txt for details)
----------------------------------------------------------------------------------------------------
--
-- Date: January 6, 2015
--
-- Version: 1.0
--
-- File name: main.lua
--
---- App core file. It should be placed in the project's base directory.
--
----------------------------------------------------------------------------------------------------


-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- Get month and year
local date = os.date('*t')
local month = date.month
local year = date.year

-- Constnats
local _W = display.contentWidth
local _H = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Background
local background = display.newRect(centerX, centerY, _W, _H)
background:setFillColor(
	math.random(5,9)*0.1, math.random(5,9)*0.1, math.random(7,9)*0.1)

-- Create calendar widget
local newCalendarView = require('newCalendarView')
local view = newCalendarView.new(month, year)
