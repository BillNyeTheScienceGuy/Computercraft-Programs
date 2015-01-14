--[[

File: timeControl

Author: R. Spiller (BillNyeTheScienceGuy)
Date: Fall 2014

File Summary:

	This program controls time, making sure the game
	time stays between 7 am and a specified end-time.
	When the program is called, the first argument
	becomes the end-time, or if no argument is
	called, the end-time becomes noon.  The computer
	must have a command block below it (by default)
	in order to influence the game's time.  The
	program takes care of the commands.

	Run this program in the startup file of a
	computer to maintain time control at all times.

Sample Program Call:

	> timeControl 13

]]

local args = { ... }
local endtime

if #args >= 1 then
  endtime = tonumber(args[1])
else
  endtime = 12
end

local commandBlock = peripheral.wrap("bottom")

while true do
  time = os.time()
  print(textutils.formatTime(time, false))
  
  if time >= endtime or time < 7 then
	commandBlock.setCommand("time set 1000")
	commandBlock.runCommand()
  end
  
  sleep(1)
end
