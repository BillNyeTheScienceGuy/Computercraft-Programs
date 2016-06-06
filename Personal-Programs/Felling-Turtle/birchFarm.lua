shell.run("pastebin run rNZx09j4")
os.loadAPI("starNav")

-- TODO: place chest if in inventory at beginning of program
--       ensure saplings are always in first slot of inventory

local args = { ... }
local x, y, z

if #args == 3 then
	x,y,z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
else
	print("Invalid arguments (must be coordinates)")
end

local function locateTreeBase()
	local p = {starNav.getPosition()}
	local heading = p[4]
	local original = p[4]

	local isBlock,block = turtle.inspect()
	while not isBlock or string.match(string.match(block.name, ':.*'), '[^:].*') ~= "log" do
		if not isBlock then
			turtle.select(1)
			turtle.place()
		end
		turtle.turnRight()
		heading = (heading + 1)%4
		isBlock,block = turtle.inspect()
		sleep(0)
	end
	
	local a = aStar.adjacent(vector.new(unpack(p)))
	local base = a[heading + 1]
	local baseHeading = heading

	while heading ~= original do
		turtle.turnRight()
		heading = (heading + 1)%4
		sleep(0)
	end
	
	return base, baseHeading
end

local function blockGrowth()
	starNav.goto(x, y + 1, z)
	turtle.select(2)
	for i = 1,4 do
		turtle.turnRight()
		turtle.place()
	end
	starNav.goto(x, y, z)
	turtle.select(1)
end

local function resumeGrowth()
	starNav.goto(x, y + 1, z)
	turtle.select(2)
	for i = 1,4 do
		turtle.turnRight()
		turtle.dig()
	end
	starNav.goto(x, y, z)
	turtle.select(1)
end

local function treeCuttingMovements(treeCount, base)
	-- Go through tree to right above it
	for i = 1, 7 do
		turtle.digUp()
		starNav.goto(x, y + i, z)
	end
	
	-- Go down to top of tree
	local topLayer
	for i = 8, 0, -1 do
		if not starNav.goto(base.x, base.y + i, base.z) then
			topLayer = base.y + i + 1
			break
		end
	end
	
	-- Chop down large layers
	local topTrunkY = base.y + 3
	local woodCount = 0
	for y = topLayer, base.y + 3, -1 do
		for z = base.z - 2, base.z + 2 do
			starNav.goto(base.x - 2, y, z)
			turtle.digDown()
		end
		for x = base.x - 1, base.x + 2 do
			starNav.goto(x, y, base.z + 2)
			turtle.digDown()
		end
		for z = base.z + 1, base.z - 2, -1 do
			starNav.goto(base.x + 2, y, z)
			turtle.digDown()
		end
		for x = base.x + 1, base.x - 1, -1 do
			starNav.goto(x, y, base.z - 2)
			turtle.digDown()
		end
		
		for z = base.z - 1, base.z + 1 do
			starNav.goto(base.x - 1, y, z)
			turtle.digDown()
		end
		for x = base.x, base.x + 1 do
			starNav.goto(x, y, base.z + 1)
			turtle.digDown()
		end
		for z = base.z, base.z - 1, -1 do
			starNav.goto(base.x + 1, y, z)
			turtle.digDown()
		end
		starNav.goto(base.x, y, base.z - 1)
		turtle.digDown()
		
		starNav.goto(base.x, y, base.z)
		topTrunkY = y
		local isBlock, block = turtle.inspectDown()
		if isBlock and string.match(string.match(block.name, ':.*'), '[^:].*') == "log" then
			woodCount = woodCount + 1
		end
		turtle.digDown()
		if woodCount >= 3 then
			break
		end
	end
	
	-- Chop down rest of trunk
	for y = topTrunkY - 1, base.y + 1, -1 do
		starNav.goto(base.x, y, base.z)
		turtle.digDown()
	end
	
	starNav.goto(x, y, z)
	local isBlock,block = turtle.inspectDown()
	if isBlock and string.match(string.match(block.name, ':.*'), '[^:].*') == "chest" then
		-- Dump everything except saplings in first slot and first stack of wood (only on first tree down) into chest
		local startSlot = 2
		if treeCount == 0 then startSlot = 3 end
		for i = startSlot,16 do
			turtle.select(i)
			turtle.dropDown()
		end
		turtle.select(1)
	end
end

local treeCount = 0
starNav.setMap(tostring("treeFarmerMap"))

while true do
	starNav.goto(x, y, z)
	
	local base, baseHeading = locateTreeBase()
	
	blockGrowth()
	
	treeCuttingMovements(treeCount, base)
	
	resumeGrowth()
	
	treeCount = treeCount + 1
	shell.run("clear")
	print("Felled: ", treeCount, " trees")
end
