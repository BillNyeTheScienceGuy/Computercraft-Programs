--[[

File: timeControl

Author: R. Spiller (BillNyeTheScienceGuy)
Date: Fall 2014

File Summary:

	This program controls time, making sure the game
	time stays between two different times.
	Arguments are input in minecraft time.  If there
	are two arguments, they are used as the start and
	end times, respectively.  If there is one
	argument, it is used as the end time.  No
	arguments means no specified times.  Unless
	specified, the start and end times are set to 
	their defaults of 8 am and 4 pm, respectively.
	The computer must have a command block next to it
	in order to influence the game's time.  The
	program takes care of the commands and command
	block positioning.

	Run this program in the startup file of a
	computer to maintain time control at all times.

Sample Program Call:

	> timeControl 18.25 18.5
	
	This program call keeps the time between 6:15 pm and 6:30 pm (during the sunset)

--]]

local args = { ... }
local starttime = 8	-- default start time is 8 am
local endtime = 16	-- default end time is 4 pm

if #args >= 2 then
	starttime = tonumber(args[1])
	print("Set start time: ", starttime)
	endtime = tonumber(args[2])
	print("Set end time:   ", endtime)
elseif #args == 1 then
	print("Default start time: ", starttime)
	endtime = tonumber(args[1])
	print("Set end time:       ", endtime)
else
	print("Default start time: ", starttime)
	print("Default end time:   ", endtime)
end

local time
local outsideRange
local commandBlock

while true do
	time = os.time()
	print(textutils.formatTime(time, false))
	
	if starttime <= endtime then
		outsideRange = time >= endtime or time < starttime
	else
		outsideRange = time >= endtime and time < starttime
	end
	
	if outsideRange then
		commandBlock = peripheral.find("command")
		if commandBlock ~= nil then
			commandBlock.setCommand("time set " .. tostring(1000*(starttime - 6)))
			print("Setting time...")
			commandBlock.runCommand()
		else
			print("Cannot find command block.")
		end
	end
	
	sleep(5/6)
end
