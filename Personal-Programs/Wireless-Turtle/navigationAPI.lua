-- TO DO: add time stamps and change to lua

local XSIZE = 5
local YSIZE = 5
local ZSIZE = 5

local hFactor = 1 -- higher the factor, faster the solution but not guaranteed to be the shortest solution

dirCostMap = { {1, 2, 3, 2}, {2, 1, 2, 3}, {3, 2, 1, 2}, {2, 3, 2, 1} } -- maps move costs with directions

--[[
Account = {}
Account.__index = Account

function Account.create(balance)
	local acnt = {}             -- our new object
	setmetatable(acnt,Account)  -- make Account handle lookup
	acnt.balance = balance      -- initialize our object
	return acnt
end

function Account:withdraw(amount)
	self.balance = self.balance - amount
end

-- create and use an Account
acc = Account.create(1000)
acc:withdraw(100)
--]]

local Node = {}
Node.__index = Node

function Node:create()
	local node = {}
	setmetatable(node, Node)
	node.id = nil
	node.x  = 0
	node.y  = 0
	node.z  = 0
	node.g  = 0
	node.h  = 0
	node.xp = 0
	node.yp = 0
	node.zp = 0
	node.d  = 0
	node.status = "unlisted"
	node.changed = false
	node.timeStamp = 0
	return node
end

function Node:getxyz()
	return {x = self.x, y = self.y, z = self.z}
end

function Node:getxyzp()
	return {x = self.xp, y = self.yp, z = self.zp}
end

function Node:getf()
	return self.g + self.h
end

function Node:setid(i)
	self.changed = (self.id ~= i)
	self.id = i
	timeStamp = os.time()
end

function Node:setxyz(c)
	self.x = c.x
	self.y = c.y
	self.z = c.z
end

function Node:setxyzp(parent)
	self.xp, self.yp, self.zp = parent.x, parent.y, parent.z
	
	if self.z == self.zp then
		self.d = 1*b2n((self.xp - self.x) > 0) + 2*b2n((self.yp - self.y) < 0) + 3*b2n((self.xp - self.x) < 0)
	else
		self.d = parent.d
	end
end

function Node:calcg(parent, finalDir)
	self.g = parent.g
	local dir = 1*b2n((parent.x - self.x) > 0) + 2*b2n((parent.y - self.y) < 0) + 3*b2n((parent.x - self.x) < 0)
	
	if self.z == parent.z then
		self.g = self.g + dirCostMap[parent.d + 1][dir + 1]
	else
		self.g = self.g + 1
	end
	
	if finalDir ~= nil then
		if self.z == parent.z then
			self.g = self.g + dirCostMap[dir + 1][(finalDir + 2)%4 + 1] - 1
		else
			self.g = self.g + dirCostMap[parent.d + 1][(finalDir + 2)%4 + 1] - 1
		end
	end
end

function Node:calch(final)
	local dirCost = 0
	
	if self.d%2 == 0 and (final.x - self.x) ~= 0 or self.d%2 == 1 and (final.y - self.y) ~= 0 then
		dirCost = 1
	end
	if self.d == 2 and final.y < self.y or self.d == 3 and final.x < self.x or self.d == 0 and final.y > self.y or self.d == 1 and final.x > self.x then
		dirCost = 2
	end
	
	self.h = math.abs(final.x - self.x) + math.abs(final.y - self.y) + math.abs(final.z - self.z) + dirCost
	self.h = hFactor*self.h
end

function b2n(boolean) -- boolean to number
	return boolean and 1 or 0
end

function ternary(cond, T, F) -- ternary operation
	if cond then return T else return F end
end

function shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Set XYZ coordinates for each node in the map
function initializeNodeCoordinates(node, start, stop)
	for i in pairs(node) do
		for j in pairs(node[i]) do
			for k in pairs(node[i][j]) do
				node[i][j][k]:setxyz({x = i, y = j, z = k})
			end
		end
	end
end

function initializeNodeMap(xstart, xstop, ystart, ystop, zstart, zstop)
	local map = {}
	
	for i = xstart,xstop do
		map[i] = {}
		for j = ystart,ystop do
			map[i][j] = {}
			for k = zstart,zstop do
				map[i][j][k] = Node.create()
			end
		end
	end
	
	return map
end

-- Print elements of path in horzontal list
function printPath(path)
	for _	,v in ipairs(path) do
		io.write(v)
	end
	print()
end

-- Find the lowest F score in the valid nodes of the map
function lowestF(node)
	local lowf = 1e20 -- initialize lowf as very high value
	local coord = {}

	for i in pairs(node) do
		for j in pairs(node[i]) do
			for k in pairs(node[i][j]) do
				if node[i][j][k].id == nil and node[i][j][k].status == "open" and node[i][j][k]:getf() < lowf then -- if walkable and on open list and lower than lowest F encountered
					lowf = node[i][j][k]:getf()
					coord = {x = i, y = j, z = k}
				end
			end
		end
	end

	return coord
end

function findLowestAndHighest(myTable)
	local lowest, highest

	for k in pairs(myTable) do
		if type(k) == "number" and k % 1 == 0 and k > 0 then -- Assuming mixed (possibly non-integer) keys
			if lowest then
				lowest = math.min(lowest, k)
				highest = math.max(highest, k)
			else
				lowest, highest = k, k
			end
		end
	end

	return lowest or 0, highest or 0 -- "or 0" in case there were no indices
end

-- Looks one block ahead, one block above, and one block below to see what's in those other nodes
function sense(t, cur)
	local changed = false
	local _, data = turtle.inspect()
	
	-- get id of block in front of turtle
	if cur.d == 0 and t[cur.x][cur.y + 1] ~= nil then
		t[cur.x][cur.y + 1][cur.z]:setid(data.name)
		if t[cur.x][cur.y + 1][cur.z].changed then changed = true end
	end
	if cur.d == 1 and t[cur.x + 1] ~= nil then
		t[cur.x + 1][cur.y][cur.z]:setid(data.name)
		if t[cur.x + 1][cur.y][cur.z].changed then changed = true end
	end
	if cur.d == 2 and t[cur.x][cur.y - 1] ~= nil then
		t[cur.x][cur.y - 1][cur.z]:setid(data.name)
		if t[cur.x][cur.y - 1][cur.z].changed then changed = true end
	end
	if cur.d == 3 and t[cur.x - 1] ~= nil then
		t[cur.x - 1][cur.y][cur.z]:setid(data.name)
		if t[cur.x - 1][cur.y][cur.z].changed then changed = true end
	end

	_, data = turtle.inspectUp()
	-- get id of blocks above and below turtle
	if t[cur.x][cur.y][cur.z + 1] ~= nil then
		t[cur.x][cur.y][cur.z + 1]:setid(data.name)
		if t[cur.x][cur.y][cur.z + 1].changed then changed = true end
	end
	_, data = turtle.inspectDown()
	if t[cur.x][cur.y][cur.z - 1] ~= nil then
		t[cur.x][cur.y][cur.z - 1]:setid(data.name)
		if t[cur.x][cur.y][cur.z - 1].changed then changed = true end
	end

	return changed
end

-- Rotate to face desired direction
function faceD(cur, nexd)
	local dDiff = (nexd - cur.d + 4)%4
	if     dDiff == 0 then -- nothing
	elseif dDiff == 1 then turtle.turnRight()
	elseif dDiff == 2 then turtle.turnRight() turtle.turnRight()
	elseif dDiff == 3 then turtle.turnLeft()
	end
	cur.d = nexd
end

-- Rotate and move forward in desired direction
function moveSenseD(t, cur, nexd)
	faceD(cur, nexd)
	changed = sense(t, cur)
	if changed then return true end

	-- if no change, move in next movement direction
	if nexd == 0 and t[cur.x][cur.y + 1] ~= nil then
		if t[cur.x][cur.y + 1][cur.z].id == nil then
			if turtle.forward() then
				cur.y = cur.y + 1
			end
		end
	end
	if nexd == 1 and t[cur.x + 1] ~= nil then
		if t[cur.x + 1][cur.y][cur.z].id == nil then
			if turtle.forward() then
				cur.x = cur.x + 1
			end
		end
	end
	if nexd == 2 and t[cur.x][cur.y - 1] ~= nil then
		if t[cur.x][cur.y - 1][cur.z].id == nil then
			if turtle.forward() then
				cur.y = cur.y - 1
			end
		end
	end
	if nexd == 3 and t[cur.x - 1] ~= nil then
		if t[cur.x - 1][cur.y][cur.z].id == nil then
			if turtle.forward() then
				cur.x = cur.x - 1
			end
		end
	end
	if nexd == 4 and t[cur.x][cur.y][cur.z + 1] ~= nil then
		if t[cur.x][cur.y][cur.z + 1].id == nil then
			if turtle.up() then
				cur.z = cur.z + 1
			end
		end
	end
	if nexd == 5 and t[cur.x][cur.y][cur.z - 1] ~= nil then
		if t[cur.x][cur.y][cur.z - 1].id == nil then
			if turtle.down() then
				cur.z = cur.z - 1
			end
		end
	end
	
	return false
end

-- Set G score and H score to 0 and status to "unlisted" for all nodes in map
function resetScoresAndStatus(node)
	for i in pairs(node) do
		for j in pairs(node[i]) do
			for k in pairs(node[i][j]) do
				node[i][j][k].g = 0
				node[i][j][k].h = 0
				node[i][j][k].status = "unlisted"
			end
		end
	end
end

-- Set scores and statuses of adjacent node while running A* algorithm
function setAdjacentNodeScores(node, c0, c1, stop, boundaryCondition)
	local oldg
	local nodeIsFinalNode = (c1.x == stop.x) and (c1.y == stop.y) and (c1.z == stop.z)
	-- print(tostring(boundaryCondition))
	-- print(c1.x)
	-- print(c1.y)
	-- print(c1.z)
	if boundaryCondition then                                                                               -- if there's a node in the boundary
		if node[c1.x][c1.y][c1.z].id == nil then                                                              -- if the node is walkable
			if node[c1.x][c1.y][c1.z].status == "open" then                                                 -- if the node is in the open list
				oldg = node[c1.x][c1.y][c1.z].g                                                             -- save the old G score for comparison
				node[c1.x][c1.y][c1.z]:calcg(node[c0.x][c0.y][c0.z], ternary(nodeIsFinalNode, stop.d, nil)) -- recalculate a new G score (accounting for final direction if adjacent node is the end)
				if node[c1.x][c1.y][c1.z].g >= oldg then                                                    -- if the new G score is not less than the old
					node[c1.x][c1.y][c1.z].g = oldg                                                         -- set the score back to the old
				else
					node[c1.x][c1.y][c1.z]:setxyzp(node[c0.x][c0.y][c0.z])                                  -- else set the node's parent to current node
					node[c1.x][c1.y][c1.z]:calch({x = stop.x, y = stop.y, z = stop.z})                                    -- recalculate the H score
				end
			elseif node[c1.x][c1.y][c1.z].status == "unlisted" then                                         -- if the node is not in a list
				node[c1.x][c1.y][c1.z].status = "open"                                                      -- place in open list
				node[c1.x][c1.y][c1.z]:setxyzp(node[c0.x][c0.y][c0.z])                                      -- set the node's parent to current node
				node[c1.x][c1.y][c1.z]:calcg(node[c0.x][c0.y][c0.z], ternary(nodeIsFinalNode, stop.d, nil)) -- calculate the G score
				node[c1.x][c1.y][c1.z]:calch({x = stop.x, y = stop.y, z = stop.z})                                        -- calculate the H score
			end
		end
	end
end

-- Reverses an array
function reverseArray(array)
	local reversedArray = {}
	
	for i,v in ipairs(array) do
		reversedArray[#array - i + 1] = v
	end
	printPath(array)
	printPath(reversedArray)
	return reversedArray
end

-- Outlines the best path by following the parents of each node
function bestPath(node, start, stop)
	local path = {}
	local cur = shallowCopy(stop)
	local zdiff -- difference between node z and parent z

	while cur.x ~= start.x or cur.y ~= start.y or cur.z ~= start.z do -- while not at starting node
		-- print(cur.x .. "," .. cur.y .. "," .. cur.z)
		-- print(node[cur.x][cur.y][cur.z].z)
		-- print(node[cur.x][cur.y][cur.z].zp)
		zdiff = node[cur.x][cur.y][cur.z].z - node[cur.x][cur.y][cur.z].zp -- -1 if parent above, 0 if no change, 1 if parent below
		if     zdiff ==  1 then path[#path + 1] = 4                                   -- if parent below, set movement direction needed to get to current node to go up
		elseif zdiff == -1 then path[#path + 1] = 5                                   -- if parent above, set movement direction needed to get to current node to go down
		else                    path[#path + 1] = (node[cur.x][cur.y][cur.z].d + 2)%4 -- if on same z-coord as parent, set movement needed to get to current node from parent (reverse of direction to parent)
		end
		-- print(node[cur.x][cur.y][cur.z].xp .. "," .. node[cur.x][cur.y][cur.z].yp .. "," .. node[cur.x][cur.y][cur.z].zp)
		cur = node[cur.x][cur.y][cur.z]:getxyzp() -- go to parent cell next
	end

	return reverseArray(path)
end

-- Run A* maze-solving algorithm to find the least costly path from start to stop
function aStarPath(node, start, stop)
	local cur = shallowCopy(start)
	
	resetScoresAndStatus(node)

	node[start.x][start.y][start.z].d = (start.d + 2)%4

	node[cur.x][cur.y][cur.z].status = "open" -- open starting node
	cur = lowestF(node) -- set the current x, y coords to the node with the lowest F score
	--n[cur.x][cur.y][cur.z].setstatus(2) -- close starting node to prevent any parent change

	while node[stop.x][stop.y][stop.z].status ~= "closed" and cur.x ~= nil and cur.y ~= nil and cur.z ~= nil do -- while final node is not closed and open list is not empty

		-- print("Running")
		-- print(cur.x .. ", " .. cur.y .. ", " .. cur.z)

		setAdjacentNodeScores(node, cur, {x = cur.x + 1, y = cur.y, z = cur.z}, stop, node[cur.x + 1] ~= nil)
		setAdjacentNodeScores(node, cur, {x = cur.x - 1, y = cur.y, z = cur.z}, stop, node[cur.x - 1] ~= nil)
		setAdjacentNodeScores(node, cur, {x = cur.x, y = cur.y + 1, z = cur.z}, stop, node[cur.x][cur.y + 1] ~= nil)
		setAdjacentNodeScores(node, cur, {x = cur.x, y = cur.y - 1, z = cur.z}, stop, node[cur.x][cur.y - 1] ~= nil)
		setAdjacentNodeScores(node, cur, {x = cur.x, y = cur.y, z = cur.z + 1}, stop, node[cur.x][cur.y][cur.z + 1] ~= nil)
		setAdjacentNodeScores(node, cur, {x = cur.x, y = cur.y, z = cur.z - 1}, stop, node[cur.x][cur.y][cur.z - 1] ~= nil)

		node[cur.x][cur.y][cur.z].status = "closed" -- close current node
		cur = lowestF(node) -- set the current x, y coords to the node with the lowest F score
	end

	if node[stop.x][stop.y][stop.z].g == 0 then -- if no cost required to get to end, this means either start and/or finish are unwalkable or start = finish
		return {}
	end

	return bestPath(node, start, stop)
end

-- Traverses map, sensing and adding to nodes as it moves
function moveTo(t, start, stop)
	local cur = shallowCopy(start)
	local pathCount = 1
	local path = {}
	local changed = false

	path = aStarPath(t, start, stop)
	--printMap(t, curx, cury, curz, curd)
	while #path ~= (pathCount - 1) do
		--turn and/or move
		changed = moveSenseD(t, cur, path[pathCount])

		--sense
		if not changed then
			pathCount = pathCount + 1
		end

		--if map changed, reevaluate path
		if changed then
			path = aStarPath(t, cur, stop)
			pathCount = 1
			changed = false
		end
	end
	
	if cur.x == stop.x and cur.y == stop.y and cur.z == stop.z then
		faceD(cur, stop.d)
	end
end

-- Initializes maps and generates a random solvable maze
function setupNodeArray(turtleMap, start, stop)
	local path = {}
	local solvable = false

	initializeNodeCoordinates(turtleMap, start, stop)
	turtleMap[start.x][start.y][start.z].d = (start.d + 2)%4 -- set starting direction
end

-- Compare two 1-D tables to see if they have equal lengths and have the same values in them
function arraysEqual(a1, a2)
	if #a1 ~= #a2 then return false end
	
	for i in pairs(a1) do
		if a1[i] ~= a2[i] then return false end
	end
	
	return true
end

-- Traverses map as many times as it takes to discover the best path (until the path repeats itself)
function moveUntilBestPath(turtleMap, start, stop)
	local path = {}
	local lastPath = {} -- path array used to store previous path
	local pathsAreSame = false

	while not pathsAreSame do
		moveTo(turtleMap, start, stop)

		path = aStarPath(turtleMap, start, stop)

		pathsAreSame = true
		if not arraysEqual(path, lastPath) then
			pathsAreSame = false
			lastPath = path
			-- printMapLayer(turtleMap, 1)
			-- print()
		end
	end
end

function printMapLayer(node, z)
	for i in ipairs(node) do
		for j in ipairs(node[i]) do
			if node[i][j][z].id ~= nil then
				io.write("0")
			else
				io.write(".")
			end
		end
		print()
	end
end

function printXYZP(node, z)
	for i in ipairs(node) do
		for j in ipairs(node[i]) do
			io.write(" " .. node[i][j][z].xp .. "," .. node[i][j][z].yp .. "," .. node[i][j][z].zp)
		end
		print()
	end
end

function main()
	local turtleMap = initializeNodeMap(1, 10, 1, 10, 1, 10) -- nodes turtle sees
	local path = {} -- array of movement commands representing a path to the end-point

	local start = {x = 1, y = 1, z = 1, d = 0}
	local stop  = {x = 4, y = 4, z = 1, d = 0} -- if final direction is -1, final direction will be ignored

	setupNodeArray(turtleMap, start, stop)

	moveTo(turtleMap, start, stop)
end

function test()
	local tmap = initializeNodeMap(1, 4, 1, 4, 1, 1)
	local rmap = initializeNodeMap(1, 4, 1, 4, 1, 1)
	initializeNodeCoordinates(tmap)
	initializeNodeCoordinates(rmap)	
	generateRandomMaze(rmap)
	print("tmap")
	printMapLayer(tmap, 1)
	print("rmap")
	printMapLayer(rmap, 1)
	print()
	
	local path = aStarPath(rmap, {x = 1, y = 1, z = 1, d = 0}, {x = 4, y = 4, z = 1})
	-- printXYZP(rmap, 1)
	printPath(path)
end
