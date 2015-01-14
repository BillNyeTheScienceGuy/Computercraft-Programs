--[[
The MIT License (MIT)
 
Copyright (c) 2014 Lyqyd
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]

local places = {}
local destination, current, heading, distance
local placesOffset = 1
local screenHandler, screenDraw
local newPlace, newPlaceFocus = {x = "", y = "", z = "", name = ""}, "name"
local goto, gotoFocus = {x = "", y = "", z = ""}, "x"
local tracing, traces = false, {}
local openDoors = false

if fs.exists(".places") then
	local handle = io.open(".places", "r")
	if handle then
		for line in handle:lines() do
			local entry = {}
			entry.x, entry.y, entry.z, entry.name = string.match(line, "(%-?%d+),(%-?%d+),(%-?%d+),(.*)")
			if entry.x and entry.y and entry.z and entry.name then
				table.insert(places, entry)
			end
		end
		handle:close()
	end
end

local function savePlaces()
	local handle = io.open(".places", "w")
	if handle then
		for i = 1, #places do
			handle:write(places[i].x..","..places[i].y..","..places[i].z..","..places[i].name.."\n")
		end
		handle:close()
	else
		error("Couldn't open file for writing!")
	end
end

local function saveTrace()
	local name
	if fs.exists("trace") then
		local count = 1
		repeat
			count = count + 1
		until not fs.exists("trace"..count)
		name = "trace"..count
	else
		name = "trace"
	end
	local handle = io.open(name, "w")
	if handle then
		for i = 1, #traces do
			handle:write(traces[i].x..","..traces[i].y..","..traces[i].z.."\n")
		end
		handle:close()
	end
end


local function printCenter(text)
	text = tostring(text)
	local x, y = term.getSize()
	local xCur, yCur = term.getCursorPos()
	term.setCursorPos((x - #text) / 2 + 1, yCur)
	term.write(text)
end

local function menuBar()
	term.setCursorPos(1,1)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.write("  Places    Goto    Exit  ")
end

local function clearState()
	term.setCursorBlink(false)
	placesOffset = 1
	newPlace = {x = "", y = "", z = "", name = ""}
	newPlaceFocus = "name"
end

local function drawDestinationLine(index)
	local x, y = term.getSize()
	term.setBackgroundColor(colors.red)
	term.setTextColor(colors.white)
	term.write("x")
	term.setBackgroundColor(index % 2 == 0 and colors.lightGray or colors.white)
	term.setTextColor(colors.black)
	local destCoords = tostring(places[index].x)..","..tostring(places[index].y)..","..tostring(places[index].z)
	local nameLen = x - (#destCoords + 4) --4 for spacing and initial X and scrollbar
	local nameStr = string.sub(places[index].name..string.rep(" ", x), 1, nameLen)
	term.write(" "..nameStr.." "..destCoords)
end


local function mainScreen()
	local x, y = term.getSize()
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	if heading then
		term.setCursorPos(3, 4)
		term.write("Heading: "..heading)
	end
	if current then
		term.setCursorPos(3, 6)
		term.write("Current Location:")
		term.setCursorPos(1, 7)
		printCenter(current)
	end
	if destination then
		term.setCursorPos(3, 9)
		term.write("Destination: ")
		if destinationName then
			term.write(destinationName)
		end
		term.setCursorPos(1, 10)
		printCenter(destination)
	end
	if distance then
		term.setCursorPos(3, 12)
		term.write("Distance: "..distance.."m")
	end
	term.setCursorPos(3, y - 1)
	term.setTextColor(tracing and colors.lime or colors.red)
	term.write("Tracing    ")
	if fs.exists("/.fingerprint") then
		term.setTextColor(openDoors and colors.lime or colors.red)
		term.write("Open Doors")
	end
	term.setTextColor(colors.black)
	term.setCursorPos(1, y)
end

local function handleMain(event)
	local x, y = term.getSize()
	if event[1] == "char" then
		if event[2] == "t" then
			tracing = not tracing
			if not tracing then
				--toggled off, save traces.
				saveTrace()
			end
		elseif event[2] == "f" then
			if not fs.exists("/.fingerprint") then
				local handle = io.open("/.fingerprint", "w")
				if handle then
					for i = 1, 256 do
						handle:write(string.char(math.random(32, 126)))
					end
					handle:close()
				end
			end
		end
	elseif event[1] == "mouse_click" then
		if event[4] == y - 1 and event[3] >= 3 and event[3] <= 9 then
			tracing = not tracing
			if not tracing then
				saveTrace()
			end
		elseif event[4] == y - 1 and event[3] >= 14 and event[3] <= 23 and fs.exists("/.fingerprint") then
			openDoors = not openDoors
		end
	end
end

local placesScreen, handlePlaces

local function newPlaceScreen()
	local x, y = term.getSize()
	local curX, curY
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	term.setCursorPos(3, 4)
	term.write("Name: ")
	if newPlace.name then
		term.write(newPlace.name)
	end
	if newPlaceFocus == "name" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(3, 6)
	term.write("X: ")
	if newPlace.x then
		term.write(string.sub(tostring(newPlace.x), 0-(x - 7)))
	end
	if newPlaceFocus == "x" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(3, 7)
	term.write("Y: ")
	if newPlace.y then
		term.write(string.sub(tostring(newPlace.y), 0-(x - 7)))
	end
	if newPlaceFocus == "y" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(3, 8)
	term.write("Z: ")
	if newPlace.z then
		term.write(string.sub(tostring(newPlace.z), 0-(x - 7)))
	end
	if newPlaceFocus == "z" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(x - 5, 10)
	term.write("Done")
	if curX and curY then
		term.setCursorPos(curX, curY)
		term.setCursorBlink(true)
	end
end

local function handleNewPlace(event)
	local x, y = term.getSize()
	if event[1] == "mouse_click" then
		if event[4] == 4 then
			newPlaceFocus = "name"
		elseif event[4] == 6 then
			newPlaceFocus = "x"
		elseif event[4] == 7 then
			newPlaceFocus = "y"
		elseif event[4] == 8 then
			newPlaceFocus = "z"
		elseif event[4] == 10 and event[3] >= x - 5 and event[3] <= x - 1 then
			--clicked Done
			if tonumber(newPlace.x) and tonumber(newPlace.y) and tonumber(newPlace.z) and #newPlace.name > 0 then
				local entry = {x = newPlace.x, y = newPlace.y, z = newPlace.z, name = newPlace.name}
				table.insert(places, entry)
				savePlaces()
				clearState()
				screenHandler = handlePlaces
				screenDraw = placesScreen
			end
		end
	elseif event[1] == "char" then
		if event[2] == "-" and (newPlaceFocus == "x" or newPlaceFocus == "y" or newPlaceFocus == "z") then
			if string.sub(newPlace[newPlaceFocus], 1, 1) == "-" then
				newPlace[newPlaceFocus] = string.sub(newPlace[newPlaceFocus], 2)
			else
				newPlace[newPlaceFocus] = "-"..newPlace[newPlaceFocus]
			end
		else
			newPlace[newPlaceFocus] = newPlace[newPlaceFocus]..event[2]
		end
	elseif event[1] == "key" and event[2] == 14 then
		--backspace
		newPlace[newPlaceFocus] = string.sub(newPlace[newPlaceFocus], 1, #newPlace[newPlaceFocus] - 1)
	end
end

function placesScreen()
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	term.setCursorPos(1, 3)
	term.write("  New:   Manual  ")
	if current and type(current) == "table" then
		term.write("Current")
	end
	term.setCursorPos(1, 5)
	local x, y = term.getSize()
	for i = 1, math.min(#places, y - 4) do
		term.setCursorPos(1, i + 4)
		drawDestinationLine(i + placesOffset - 1)
	end
	term.setCursorPos(x, 5)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.write("^")
	term.setCursorPos(x, y)
	term.write("v")
end

function handlePlaces(event)
	if event[1] == "mouse_click" then
		local x, y = term.getSize()
		if event[4] >= 5 and event[4] <= y then
			--clicked somewhere in the places list
			if event[3] == 1 then
				--removing a place from the list, clicked the x
				local index = placesOffset + event[4] - 5 --5 due to the starting y coord of the list
				if index <= #places then
					if event[2] == 1 then
						table.remove(places, index)
						savePlaces()
						placesScreen()
					elseif event[2] == 2 then
						--right-clicked, open place for editing!
						clearState()
						newPlace.x = tostring(places[index].x)
						newPlace.y = tostring(places[index].y)
						newPlace.z = tostring(places[index].z)
						newPlace.name = places[index].name
						table.remove(places, index)
						savePlaces()
						screenHandler = handleNewPlace
						screenDraw = newPlaceScreen
					end
				end
			elseif event[3] == x then
				--clicked the scroll bar.
				if event[4] == 5 then
					--up
					if placesOffset > 1 then
						placesOffset = placesOffset - 1
					end
				elseif event[4] == y then
					if placesOffset + y - 5 < #places then
						placesOffset = placesOffset + 1
					end
				end
			else
				--clicked on a place!
				local index = placesOffset + event[4] - 5
				if index <= #places then
					destination = vector.new(places[index].x, places[index].y, places[index].z)
					destinationName = places[index].name
					screenHandler = handleMain
					screenDraw = mainScreen
				end			
			end
		elseif event[4] == 3 then
			--clicked one of our new places options
			if event[3] >= 10 and event[3] <= 15 then
				--clicked manual
				clearState()
				screenHandler = handleNewPlace
				screenDraw = newPlaceScreen
			elseif event[3] >= 18 and event[3] <= 24 then
				--clicked current
				if current and type(current) == "table" then
					clearState()
					newPlace.x = tostring(current.x)
					newPlace.y = tostring(current.y)
					newPlace.z = tostring(current.z)
					screenHandler = handleNewPlace
					screenDraw = newPlaceScreen
				end
			end
		end
	end
end

local function gotoScreen()
	local x, y = term.getSize()
	local curX, curY
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	term.setCursorPos(3, 4)
	term.write("X: ")
	if goto.x then
		term.write(string.sub(tostring(goto.x), 0-(x - 7)))
	end
	if gotoFocus == "x" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(3, 5)
	term.write("Y: ")
	if goto.y then
		term.write(string.sub(tostring(goto.y), 0-(x - 7)))
	end
	if gotoFocus == "y" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(3, 6)
	term.write("Z: ")
	if goto.z then
		term.write(string.sub(tostring(goto.z), 0-(x - 7)))
	end
	if gotoFocus == "z" then
		curX, curY = term.getCursorPos()
	end
	term.setCursorPos(x - 5, 8)
	term.write("Done")
	if curX and curY then
		term.setCursorPos(curX, curY)
		term.setCursorBlink(true)
	end
end

local function handleGoto(event)
	local x, y = term.getSize()
	if event[1] == "mouse_click" then
		if event[4] == 4 then
			gotoFocus = "x"
		elseif event[4] == 5 then
			gotoFocus = "y"
		elseif event[4] == 6 then
			gotoFocus = "z"
		elseif event[4] == 8 and event[3] >= x - 5 and event[3] <= x - 1 then
			--clicked Done
			if tonumber(goto.x) and tonumber(goto.y) and tonumber(goto.z) then
				destinationName = nil
				destination = vector.new(tonumber(goto.x), tonumber(goto.y), tonumber(goto.z))
				clearState()
				screenHandler = handleMain
				screenDraw = mainScreen
			end
		end
	elseif event[1] == "char" then
		if event[2] == "-" and (gotoFocus == "x" or gotoFocus == "y" or gotoFocus == "z") then
			if string.sub(goto[gotoFocus], 1, 1) == "-" then
				goto[gotoFocus] = string.sub(goto[gotoFocus], 2)
			else
				goto[gotoFocus] = "-"..goto[gotoFocus]
			end
		else
			goto[gotoFocus] = goto[gotoFocus]..event[2]
		end
	elseif event[1] == "key" and event[2] == 14 then
		--backspace
		goto[gotoFocus] = string.sub(goto[gotoFocus], 1, #goto[gotoFocus] - 1)
	end
end

local function handleEvents()
	while true do
		term.setBackgroundColor(colors.lightGray)
		term.clear()
		menuBar()
		screenDraw()
		local event = {os.pullEvent()}
		if event[1] == "mouse_click" then
			if event[4] == 1 then
				--clicked the menu bar at the top
				if event[3] >= 3 and event[3] <= 8 then
					--clicked places
					clearState()
					screenHandler = handlePlaces
					screenDraw = placesScreen
				elseif event[3] >= 13 and event[3] <= 16 then
					--clicked goto
					clearState()
					screenHandler = handleGoto
					screenDraw = gotoScreen
				elseif event[3] >= 21 and event[3] <= 24 then
					--clicked exit
					if screenHandler ~= handleMain then
						--not on main screen, return to main screen
						clearState()
						screenHandler = handleMain
						screenDraw = mainScreen
					else
						if tracing then
							saveTrace()
						end
						return
					end
				end
			else
				screenHandler(event)
			end
		elseif event[1] == "key" or event[1] == "char" or event[1] == "mouse_scroll" or event[1] == "mouse_drag" then
			screenHandler(event)
		end
	end
end

local function doGPS()
	local loc, oldLoc
	while true do
		oldLoc = loc
		loc = nil
		local result = {gps.locate()}
		if #result == 3 then
			loc = vector.new(unpack(result))
		end
		if loc then
			current = loc
			if destination then
				distance = math.sqrt((destination.x - current.x)^2 + (destination.y - current.y)^2 + (destination.z - current.z)^2)
			end
			if tracing then
				if not oldLoc or (oldLoc and (loc.x ~= oldLoc.x or loc.y ~= oldLoc.y or loc.z ~= oldLoc.z)) then
					table.insert(traces, loc)
				end
			end
		elseif current then
			current = "GPS Signal Lost"
		end
		if loc and oldLoc then
			local head = loc - oldLoc
			if math.abs(head.z) > math.abs(head.x) and math.abs(head.z) > 1 then
				if head.z == math.abs(head.z) then
					--positive z, south
					heading = "South"
				else
					heading = "North"
				end
			elseif math.abs(head.x) > 1 then
				if head.x == math.abs(head.x) then
					--positive x, east
					heading = "East"
				else
					heading = "West"
				end
			end
		end
		sleep(1)
	end
end

local function openDoor()
	local modem = peripheral.wrap("back")
	modem.open(4210)
	local handle = io.open("/.fingerprint")
	local fingerprint
	if handle then
		fingerprint = handle:read("*a")
		handle:close()
	end
	while true do
		local event = {os.pullEvent()}
		if openDoors then
			if event[1] == "modem_message" and event[3] == 4210 then
				modem.transmit(4211, 4212, textutils.serialize({content = textutils.serialize(fingerprint), senderID = os.getComputerID(), senderName = os.getComputerLabel(), channel = 4211, replyChannel = 4212, messageID = messageID or math.random(10000), destinationID = event[5].senderID}))
			end
		end
	end
end
				

screenHandler = handleMain
screenDraw = mainScreen
parallel.waitForAny(handleEvents, doGPS, openDoor)
