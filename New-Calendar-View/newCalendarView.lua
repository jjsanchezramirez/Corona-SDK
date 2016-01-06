----------------------------------------------------------------------------------------------------
---- New Calendar View for Corona SDK (Original author: Juan Jose Sanchez Ramirez)
---- http://www.ApolloMobileApps.com
---- Copyright 2016 Apollo Mobile Apps
---- The MIT License (MIT) (see LICENSE.txt for details)
----------------------------------------------------------------------------------------------------
--
-- Date: January 6, 2016
--
-- Version: 1.0
--
-- File name: newCalendarView.lua
--
---- Adapted from joelwe's Calendar Sample for Corona SDK (support@joolify.se) and Jose Llausas'
---- A Better SlideView for Corona SDK (jose@zunware.com).
----
---- http://web-b1.anscamobile.com/code/calendar-sample
---- http://www.josellausas.com/2013/05/a-better-slideview-for-corona-sdk/
----
---- New Calendar Viewis a simple calendar widget for Corona SDK. It displays the current month and
---- uses swipe gestures to switch month.
----
---- Last updated by Juan Jose Sanchez Ramirez on January 6, 2016.
----   * Switched from center aligment to top-left alignment
----   * Rewrote most of the calendar sample to remove any unnecessary variables and methods while
----     keeping most of the original algorithms
----   * Rewrote a substantial amount of the slide view to remove any unnecessary variables and
----     methods while keeping most of the original algorithms
----   * Edited slide view to use objects instead of images
----   * Edited slide view to update the calendar when done moving to allow an infinite amount of
----     movement in any direction
----   * Removed the slide view event listener when moving to prevent graphical glitches when
----     updating the calendar
--
----------------------------------------------------------------------------------------------------


module(..., package.seeall)

-- Settings
local minimumDragTolerance = 60 

-- Constants
local _W = display.contentWidth
local _H = display.contentHeight
local pad = 20

-- Time-related variables
local date = os.date('*t')
local month = date.month
local year = date.year

-- Creates a calendar object
local function create_calendar( month, year )
    
	-- Group
	local group = display.newGroup()
	group.days = {}
	group.weekdays = {}
	group.circle = nil

	-- Constants
	local months = {
		'January', 'February', 'March', 'April', 'May', 'June',
		'July', 'August', 'September', 'October', 'November', 'December' }
	local months_abbr = {
		'jan', 'feb', 'mar', 'apr', 'may', 'jun',
		'jul', 'aug', 'sep', 'oct', 'nov', 'dec' }
	local days = { 'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat' }

    -- Calculate amount of days per month
	local function get_days_in_month( month, year )
	    return os.date('*t', os.time{ year=year, month=month+1, day=0 })['day']
	end

	-- Calculate first day of the month
	local function get_init_day( month, year )
	    return tonumber(os.date('%w', os.time{ year=year, month=month, day=1 }))
	end

	-- Calculate last day of the month
	local function get_end_day( month, year )
	    return tonumber(get_days_in_month(month, year))
	end
	
	-- Background
	local rect = display.newRect(group, -pad*0.5, 120, _W+pad, 224)
    rect.anchorX, rect.anchorY = 0, 0

    -- Current month
    local curEndDay = get_end_day( month, year ) 
    local curStartDay = get_init_day( month, year ) + 1
    
    -- Previous month
    local prevMonth = month-1 < 1 and 12 or month-1
    local prevYear = month-1 < 1 and year-1 or year
    local prevMonthOnScreen = false
    local prevEndDay = get_days_in_month( prevMonth, year ) 
    local prevStartDay =  2 - curStartDay + prevEndDay
    
    -- Next month
    local nextMonth = month+1 > 12 and 1 or month+1
    local nextYear = month+1 > 12 and year+1 or year
    local nextMonthOnScreen = false
    
    -- Is there a previous month on screen?
    if 1 - curStartDay < 0 then
    	prevMonthOnScreen = true
    end

    -- Month text
    local monthStr = months[month] .. ' ' .. year
    local monthName = display.newText(group, monthStr, 20, 80, native.systemFont, 32)
    monthName.anchorX, monthName.anchorY = 0, 0
    monthName:setFillColor( 0, 0.8 )
    
    -- Calendar rows
    local rows = 36 - curEndDay - curStartDay < 0 and 6 or 5

    -- Calendar variables
    local nDay    = prevMonthOnScreen and prevStartDay or curStartDay
    local nMonth  = prevMonthOnScreen and prevMonth    or month
    local nYear   = prevMonthOnScreen and prevYear     or year
    local endDay  = prevMonthOnScreen and prevEndDay   or curEndDay

    -- Selected month
    local selMonth = prevMonthOnScreen and 'previous' or 'current'

    -- Default position
    local x, y = 0, 0
    
    -- Draw calendar
    for i = 1, rows do
        
        for j = 1, 7 do

        	-- Day text
            local day = display.newText(group, nDay, x+25, y+157, native.systemFont, 12)
            day.anchorX, day.anchorY = 0.5, 0
            if selMonth ~= 'current' then
            	day:setFillColor(0, 0.3)
            else
            	day:setFillColor(0, 0.8)
            end
            group.days[(i-1)*7+j] = day
            
            -- Weekday text
            if i == 1 then
            	local str = string.upper(days[j])
                local weekday = display.newText(group, str, x+25, y+137, native.systemFont, 12)
                weekday.anchorX, weekday.anchorY = 0.5, 0
                weekday:setFillColor(0, 0.8)
                group.weekdays[(i-1)*7+j] = weekday
            end

            -- Circle
            if nDay == date.day and nMonth == date.month and nYear == date.year then 
                local circle = display.newCircle(group, x+25, y+151, 14)
                circle.anchorX, circle.anchorY = 0.5, 0
                circle:setFillColor(0, 0.1)
                group.circle = circle
            end
            
            -- If it's the end of the month, stop showing day numbers. 
            if nDay == endDay then
            	if selMonth == 'previous' then
                    nDay = 1
                    nMonth = month
                    nYear = year
                    endDay = curEndDay
                    selMonth = 'current'
                elseif selMonth == 'current' then
                	nDay = 1
                    nMonth = nextMonth
                    nYear = nextYear
                    selMonth = 'next'
                end
            else
                nDay = nDay + 1
            end
            
            -- Move x position
            x = x + 45
        end
        
        -- Move y position
        y = rows == 5 and y+37 or y+32
        x = 0
    end

    return group
end

-- Creates a new instance of a calendar widget
function new( month, year )
	
	-- Group
	local group = display.newGroup()
	group.objects = {}
	group.objNum = nil
	
	function group:touch(event)
		
		local phase = event.phase

		if phase == 'began' then
			
			-- Set focus to object
			display.getCurrentStage():setFocus(self.objects[self.objNum])
			self.objects[self.objNum].isFocus = true
			
			-- Record the coords of start event
			self.startPos = event.x
			self.prevPos = event.x

		elseif self.objects[self.objNum].isFocus then
			
			if phase == 'moved' then
				
				-- Cancel current transition
				if self.tween then transition.cancel(self.tween) end
				
				-- Calculate delta movement
				local delta = event.x - self.prevPos
				self.prevPos = event.x
				
				-- Move object by delta
				self.objects[self.objNum].x = self.objects[self.objNum].x + delta

				-- Move previous object by delta
				if self.objects[self.objNum-1] then
					self.objects[self.objNum-1].x = self.objects[self.objNum-1].x + delta
				end

				-- Move next object by delta
				if self.objects[self.objNum+1] then
					self.objects[self.objNum+1].x = self.objects[self.objNum+1].x + delta
				end

			elseif phase == 'ended' or phase == 'cancelled' then
				
				-- Calculate total drag distance
				local dragDistance = event.x - self.startPos
				
				-- Determine if drag distance is greater than minimum tolerance
				if dragDistance < -minimumDragTolerance and self.objNum < #self.objects then
					self:nextObject()
				elseif dragDistance > minimumDragTolerance and self.objNum > 1 then
					self:prevObject()
				else
					self:cancelMove()
				end

				-- Cancel movement
				if phase == 'cancelled' then
					self:cancelMove()
				end
				
				-- Restore nil focus
				display.getCurrentStage():setFocus(nil)
				self.objects[self.objNum].isFocus = false
			end
		end
		
		return true
	end

	function group:nextObject()
		
		-- Prevents listener event while moving
		self:removeEventListener('touch', group)

		local function onComplete()
			
			-- Update month
			month = month + 1
			if month > 12 then
				month = 1
				year = year + 1
			end

			self:initObject()
		end

		-- Move current object
		self.tween  = transition.to( self.objects[self.objNum], {
			time=200, x=-(_W+pad), transition=easing.outSine, onComplete=onComplete } )

		-- Move next object
		self.tween = transition.to( self.objects[self.objNum+1], {
			time=200, x=0, transition=easing.outSine } )

		-- Update calendar object
		self.objNum = self.objNum + 1
	end

	function group:prevObject()
		
		-- Prevents listener event while moving
		self:removeEventListener('touch', group)

		local function onComplete()
			
			-- Update month
			month = month - 1
			if month < 1 then
				month = 12
				year = year - 1
			end

			self:initObject()
		end

		-- Move current object
		self.tween = transition.to( self.objects[self.objNum], {
			time=200, x=_W+pad, transition=easing.outSine, onComplete=onComplete } )

		-- Move previous object
		self.tween = transition.to( self.objects[self.objNum-1], {
			time=200, x=0, transition=easing.outSine } )

		-- Update calendar
		self.objNum = self.objNum - 1
	end

	function group:cancelMove()
		
		-- Prevents listener event while moving
		self:removeEventListener('touch', group)

		local function onComplete()
			self:addEventListener('touch', group)
		end

		-- Move current object
		tween = transition.to( self.objects[self.objNum], {
			time=200, x=0, transition=easing.outSine, onComplete=onComplete } )

		-- Move previous object
		tween = transition.to( self.objects[self.objNum-1], {
			time=200, x=-(_W+pad), transition=easing.outSine } )

		-- Move next object
		tween = transition.to( self.objects[self.objNum+1], {
			time=200, x=_W+pad, transition=easing.outSine } )
	end

	function group:initObject()
		
		-- Previous month
		local prevMonth, prevYear = month - 1, year
		if prevMonth < 1 then
			prevMonth = 12
			prevYear = prevYear - 1
		end

		-- Next month
		local nextMonth, nextYear = month + 1, year
		if nextMonth > 12 then
			nextMonth = 1
			nextYear = nextYear + 1
		end

		-- Create calendar objects
		local objects = {
			create_calendar( prevMonth, prevYear ),
			create_calendar( month, year ),
			create_calendar( nextMonth, nextYear )
		}

		-- Clean group
		group:clean()
		group.objects = {}

		-- Add properties to objects
		for i=1, #objects do		
			
			-- Add to group
			local o = objects[i]
			group:insert(o)
			
			-- Position objects
			o.x = i == 1 and -(_W+pad) or i == 2 and 0 or _W+pad

			-- Add to objects table
			group.objects[i] = o
		end

		-- Default starting object
		group.objNum = 2

		-- Add event listener
		group:addEventListener('touch', group)
	end

	function group:clean()
    	for i = 1, self.numChildren do self:remove(1) end
    end

	-- Initiate calendar object
	group:initObject()

	return group
end
