local function forward(num)
	if num == nil then	-- if no input, default is to move forward once
		num = 1
	end
	
	for i = 1,num do
		while not turtle.forward() do	-- if turtle not moving forward...
			if turtle.detect() then	-- dig if there's a block...
				turtle.dig()
			else	-- or attack if there's no block
				turtle.attack()
			end
		end
	end
end

local function back(num)
	if num == nil then	-- if no input, default is to move back once
		num = 1
	end
	
	for i = 1,num do
		while not turtle.back() do	-- if turtle not moving back...
			turtle.turnRight()	-- turn around
			turtle.turnRight()
			if turtle.detect() then	-- dig if there's a block...
				turtle.dig()
			else	-- or attack if there's no block
				turtle.attack()
			end
			turtle.turnRight()	-- turn around
			turtle.turnRight()
		end
	end
end

local function up(num)
	if num == nil then	-- if no input, default is to move up once
		num = 1
	end
	
	for i = 1,num do
		while not turtle.up() do	-- if turtle not moving up...
			if turtle.detectUp() then	-- dig if there's a block...
				turtle.digUp()
			else	-- or attack if there's no block
				turtle.attackUp()
			end
		end
	end
end

local function down(num)
	if num == nil then	-- if no input, default is to move down once
		num = 1
	end
	
	for i = 1,num do
		while not turtle.down() do	-- if turtle not moving down...
			if turtle.detectDown() then	-- dig if there's a block...
				turtle.digDown()
			else	-- or attack if there's no block
				turtle.attackDown()
			end
		end
	end
end

local function redstoneInputs()
	if redstone.getInput("front") then
		return "front"
	elseif redstone.getInput("right") then
		return "right"
	elseif redstone.getInput("left") then
		return "left"
	elseif redstone.getInput("back") then
		return "back"
	end
	return false
end

local function turnUntilTree()
	local isBlock,block = turtle.inspect()
	while not isBlock or string.match(string.match(block.name, ':.*'), '[^:].*') ~= "log" do
		if not isBlock then
			turtle.select(1)
			turtle.place()
		end
		turtle.turnRight()
		isBlock,block = turtle.inspect()
		sleep(0)
	end
end

local function blockGrowth()
	up()
	turtle.select(2)
	for i = 1,3 do
		turtle.turnRight()
		turtle.place()
	end
	turtle.turnRight()
	down()
	turtle.select(1)
end

local function resumeGrowth()
	up()
	turtle.select(2)
	for i = 1,3 do
		turtle.turnRight()
		turtle.dig()
	end
	turtle.turnRight()
	down()
	turtle.select(1)
end

local function treeCuttingMovements()
	local count = 0
	while not turtle.detectUp() do
		up()
		count = count + 1
	end
	while turtle.detectUp() do
		up()
		count = count + 1
	end
	
	forward()
	
	-- Top Layer
	turtle.dig()
	turtle.turnRight()
	turtle.dig()
	turtle.turnRight()
	turtle.dig()
	turtle.turnRight()
	forward()
	turtle.turnRight()
	
	-- Next Layer Down
	count = count - 1
	down()
	forward()
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	
	-- Next Layer Down
	count = count - 1
	down()
	forward(2)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward(3)
	turtle.turnRight()
	forward(3)
	turtle.turnRight()
	forward(4)
	turtle.turnRight()
	forward(4)
	turtle.turnRight()
	forward(4)
	turtle.turnRight()
	
	-- Next Layer Down
	count = count - 1
	down()
	forward(4)
	turtle.turnRight()
	forward(4)
	turtle.turnRight()
	forward(4)
	turtle.turnRight()
	forward(3)
	turtle.turnRight()
	forward(3)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward(2)
	turtle.turnRight()
	forward()
	turtle.turnRight()
	
	-- Go back down to ground
	forward()
	while turtle.detectUp() do
		up()
		count = count + 1
	end
	for i = 1,count do
		down()
	end
	back()
	
	-- Dump everything except saplings in first slot and first stack of wood into chest
	for i = 2,16 do
		turtle.select(i)
		turtle.dropDown()
	end
	turtle.select(1)
end

local treeCount = 0
local side = "front"

while true do
	turtle.place()
	
	turnUntilTree()
	
	blockGrowth()
	
	treeCuttingMovements()
	
	resumeGrowth()
	
	treeCount = treeCount + 1
	shell.run("clear")
	print("Felled: ", treeCount, " trees")
end
