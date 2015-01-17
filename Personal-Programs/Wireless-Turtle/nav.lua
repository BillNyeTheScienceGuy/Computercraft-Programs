-- Navigation Custom API

-- Creates a 3D array
function create3DArray(dim, ref)
	-- If there is no starting position (ref), then default to 1
	if ref.x == nil or ref.y == nil or ref.z == nil then
		ref = {x = 1, y = 1, z = 1}
	end
	
	local a = {}	-- define array
	
	for i = ref.z,(ref.z + dim.z - 1) do
		a[i] = {}	-- create second dimension of array
		for j = ref.x,(ref.x + dim.x - 1) do
			a[i][j] = {}	-- create third dimension of array
			for k = ref.y,(ref.y + dim.y - 1) do
				a[i][j][k] = 0	-- constructs array
			end
		end
	end
	
	return a
end

-- Clears a 2D array
function clear3DArray(a)
	for i,I in ipairs(a) do
		for j,J in ipairs(a[i]) do
			for k,K in ipairs(a[i][j]) do
				a[i][j][k] = 0 -- set all values to 0
			end
		end
	end
end

-- Prints a 2D array
function print2DArray(a, lyr)
	local temp	-- intermediate variable used to store the lines
	
	-- Print the lines
	for i,line1 in ipairs(a[lyr]) do
		temp = ""
		for j,line2 in ipairs(a[lyr][i]) do
			if tonumber(line2) < 0 or tonumber(line2) > 9 then	-- if number takes up 2 spaces, print with one less preceding space
				temp = temp .. " " .. line2
			else
				temp = temp .. "  " .. line2
			end
		end
		print(temp)
	end
end

--[[ WORK IN PROGRESS
-- Reads from specified file assuming it's in the format for a 2D array
-- format: dimension sizes first and array contents last, all on separate lines
function read3DArray(filename)
	local a = {}
	local file = fs.open(filename, "r")	-- open file to read-only
	
	-- Smallest coordinate should be stored in first three lines
	local x = tonumber(file.readLine())
	local y = tonumber(file.readLine())
	local z = tonumber(file.readLine())
	
	-- Size of array should be stored in next two lines
	local I = tonumber(file.readLine())
	local J = tonumber(file.readLine())
	local K = tonumber(file.readLine())
	
	for k = 1,K do	-- layer
		a[k] = {}	-- create second dimension of array
		for i = 1,I do	-- row
			a[k][i] = {}	-- create third dimension of array
			for j = 1,J do	-- column
				a[k][i][j] = tonumber(file.readLine())	-- constructs array from file
			end
		end
	end
	
	file.close()
	
	return a, x, y, z
end

-- Writes a 2D array to specified file in the 2D array format
-- format: dimension sizes first and array contents last, all on separate lines
function write3DArray(filename, a, x, y, z)
	local file = fs.open(filename, "w")	-- open file to write (erases previous contents)
	
	local K = table.getn(a)				-- size of 1st dimension
	local I = table.getn(a[1])		-- size of 2nd dimension
	local J = table.getn(a[1][1])	-- size of 3rd dimension
	
	-- North-East corner coordinates printed first
	file.writeLine(tostring(x))
	file.writeLine(tostring(y))
	file.writeLine(tostring(z))
	
	-- Size of array printed next
	file.writeLine(tostring(I))
	file.writeLine(tostring(J))
	file.writeLine(tostring(K))
	for k,K in ipairs(a) do
		for i,I in ipairs(a[k]) do
			for j,J in ipairs(a[k][i]) do
				file.write(tostring(a[k][i][j]))	-- elements of array printed last
			end
			file.writeLine()
		end
		file.writeLine()
	end
	
	file.flush()
	file.close()
end
--]]

-- Returns the flood-fill array determined by the block array 'b'
function floodFill(b, str, fin, ref, dim)
	local f = {}	-- flood array
	
	f = create3DArray(dim, ref)
	
	local X = dim.x + ref.x - 1
	local Y = dim.y + ref.y - 1
	local Z = dim.z + ref.z - 1
	
	if b[str.z][str.x][str.y] == 1 then
		f[str.z][str.x][str.y] = 0	-- if there's a block, make flood 0
	else
		f[str.z][str.x][str.y] = 1	-- set the goal cell
	end
	
	for l = 1,dim.x*dim.y*dim.z do	-- iterates through all possible flood-fill numbers
		for k = ref.z,Z do
			for i = ref.x,X do
				for j = ref.y,Y do
					
					if f[k][i][j] == l then -- if cell has flood value currently being looked at
						
						--print("Checking: ", k, " ", i, " ", j)	-- for debugging
						
						if i < X then
							--print("i < I: b = ", b[k][i + 1][j], ", f = ", f[k][i + 1][j])
							if b[k][i + 1][j] == 0 and f[k][i + 1][j] == 0 then
								f[k][i + 1][j] = f[k][i][j] + 1
							end
						end
						if i > ref.x then
							--print("i > 1: b = ", b[k][i - 1][j], ", f = ", f[k][i - 1][j])
							if b[k][i - 1][j] == 0 and f[k][i - 1][j] == 0 then
								f[k][i - 1][j] = f[k][i][j] + 1
							end
						end
						if j < Y then
							--print("j < J: b = ", b[k][i][j + 1], ", f = ", f[k][i][j + 1])
							if b[k][i][j + 1] == 0 and f[k][i][j + 1] == 0 then
								f[k][i][j + 1] = f[k][i][j] + 1
							end
						end
						if j > ref.y then
							--print("j > 1: b = ", b[k][i][j - 1], ", f = ", f[k][i][j - 1])
							if b[k][i][j - 1] == 0 and f[k][i][j - 1] == 0 then
								f[k][i][j - 1] = f[k][i][j] + 1
							end
						end
						if k < Z then
							--print("k < K: b = ", b[k + 1][i][j], ", f = ", f[k + 1][i][j])
							if b[k + 1][i][j] == 0 and f[k + 1][i][j] == 0 then
								f[k + 1][i][j] = f[k][i][j] + 1
							end
						end
						if k > ref.z then
							--print("k > 1: b = ", b[k - 1][i][j], ", f = ", f[k - 1][i][j])
							if b[k - 1][i][j] == 0 and f[k - 1][i][j] == 0 then
								f[k - 1][i][j] = f[k][i][j] + 1
							end
						end
						
						--print("Done")
						
						if fin.x ~= nil and fin.y ~= nil and fin.z ~= nil then
							if i == fin.x and j == fin.y and k == fin.z then	-- return if the flood reaches the finish
								--print("Found")
								return f
							end
						end
					end
					
				end
			end
			
			--sleep(0)	-- causes the loop to yield after each iteration
		end
	end
	
	return f	-- returns the flood array in case 
end

-- Turns a turtle right and changes the direction variable to match
function right(pos)
	if turtle.turnRight() then
		pos.dir = (pos.dir + 1)%4
	end
end

-- Turns a turtle left and changes the direction variable to match
function left(pos)
	if turtle.turnLeft() then
		pos.dir = (pos.dir + 3)%4
	end
end

-- Moves a turtle forward and makes changes to x and y variables to match
function forward(pos)
	if turtle.forward() then
		if 		pos.dir == 0 then pos.y = pos.y - 1
		elseif 	pos.dir == 1 then pos.x = pos.x + 1
		elseif 	pos.dir == 2 then pos.y = pos.y + 1
		elseif 	pos.dir == 3 then pos.x = pos.x - 1
		end
	end
end

-- Moves a turtle backward and makes changes to x and y variables to match
function back(pos)
	if turtle.back() then
		if 		pos.dir == 0 then pos.y = pos.y + 1
		elseif 	pos.dir == 1 then pos.x = pos.x - 1
		elseif 	pos.dir == 2 then pos.y = pos.y - 1
		elseif 	pos.dir == 3 then pos.x = pos.x + 1
		end
	end
end

-- Moves a turtle up and makes changes to z variable to match
function up(pos)
	if turtle.up() then
		pos.z = pos.z + 1
	end
end

-- Moves a turtle down and makes changes to z variable to match
function down(pos)
	if turtle.down() then
		pos.z = pos.z - 1
	end
end

-- Faces a turtle northwards
function faceN(pos)
	if pos.dir == 0 then
		
	elseif pos.dir == 1 then
		left(pos)
	elseif pos.dir == 2 then
		right(pos)
		right(pos)
	elseif pos.dir == 3 then
		right(pos)
	end
end

-- Faces a turtle eastwards
function faceE(pos)
	if pos.dir == 0 then
		right(pos)
	elseif pos.dir == 1 then
		
	elseif pos.dir == 2 then
		left(pos)
	elseif pos.dir == 3 then
		right(pos)
		right(pos)
	end
end

-- Faces a turtle southwards
function faceS(pos)
	if pos.dir == 0 then
		right(pos)
		right(pos)
	elseif pos.dir == 1 then
		right(pos)
	elseif pos.dir == 2 then
		
	elseif pos.dir == 3 then
		left(pos)
	end
end

-- Faces a turtle westwards
function faceW(pos)
	if pos.dir == 0 then
		left(pos)
	elseif pos.dir == 1 then
		right(pos)
		right(pos)
	elseif posdir == 2 then
		right(pos)
	elseif pos.dir == 3 then
		
	end
end

-- Moves a turtle northwards
function moveN(pos)
	faceN(pos)
	forward(pos)
end

-- Moves a turtle eastwards
function moveE(pos)
	faceE(pos)
	forward(pos)
end

-- Moves a turtle southwards
function moveS(pos)
	faceS(pos)
	forward(pos)
end

-- Moves a turtle westwards
function moveW(pos)
	faceW(pos)
	forward(pos)
end

-- Detects walls in front, above, and below and applies the result to the block array
function sense(b, d, pos, ref, dim)
	local X = dim.x + ref.x - 1
	local Y = dim.y + ref.y - 1
	local Z = dim.z + ref.z - 1
	
	local change = false
	
	local detect = turtle.detect() and 1 or 0	-- converts boolean to a number
	if pos.dir == 3 then
		if pos.x > ref.x then
			d[pos.z][pos.x - 1][pos.y] = 1	-- discovers the block in front of it
			if b[pos.z][pos.x - 1][pos.y] ~= detect then
				b[pos.z][pos.x - 1][pos.y] = detect
				change = true
			end
		end
	elseif pos.dir == 0 then
		if pos.y > ref.y then
			d[pos.z][pos.x][pos.y - 1] = 1
			if b[pos.z][pos.x][pos.y - 1] ~= detect then
				b[pos.z][pos.x][pos.y - 1] = detect
				change = true
			end
		end
	elseif pos.dir == 1 then
		if pos.x < X then
			d[pos.z][pos.x + 1][pos.y] = 1
			if b[pos.z][pos.x + 1][pos.y] ~= detect then
				b[pos.z][pos.x + 1][pos.y] = detect
				change = true
			end
		end
	elseif pos.dir == 2 then
		if pos.y < Y then
			d[pos.z][pos.x][pos.y + 1] = 1
			if b[pos.z][pos.x][pos.y + 1] ~= detect then
				b[pos.z][pos.x][pos.y + 1] = detect
				change = true
			end
		end
	end
	
	detect = turtle.detectDown() and 1 or 0
	if pos.z > ref.z then
		d[pos.z - 1][pos.x][pos.y] = 1
		if b[pos.z - 1][pos.x][pos.y] ~= detect then
			b[pos.z - 1][pos.x][pos.y] = detect
			change = true
		end
	end
	detect = turtle.detectUp() and 1 or 0
	if pos.z < Z then
		d[pos.z + 1][pos.x][pos.y] = 1
		if b[pos.z + 1][pos.x][pos.y] ~= detect then
			b[pos.z + 1][pos.x][pos.y] = detect
			change = true
		end
	end
	
	return change
end

-- Goes to the coordinates (fin.x, fin.y, fin.z) using the blocks array and flood-fill
-- (ref.x, ref.y, ref.z) is the smallest valued coordinate of the search area
function goto(b, d, pos, fin, ref, dim)
	local f = {}	-- flood array
	local flood = true
	
	local X = dim.x + ref.x - 1
	local Y = dim.y + ref.y - 1
	local Z = dim.z + ref.z - 1
	
	while true do
		if flood then
			f = floodFill(b, fin, pos, ref, dim)
			flood = false
		end
		
		if f[pos.z][pos.x][pos.y] <= 1 or f[fin.z][fin.x][fin.y] == 0 then	-- if standing on goal or goal is blocked off or goal is a block
			if fin.dir ~= nil and pos.x == fin.x and pos.y == fin.y and pos.z == fin.z then	-- turns the turtle towards the final direction
				if		fin.dir == 0 then faceN(pos)
				elseif	fin.dir == 1 then faceE(pos)
				elseif	fin.dir == 2 then faceS(pos)
				elseif	fin.dir == 3 then faceW(pos)
				end
			end
			return
		end
		
		-- Checks for direction of next move based on flood values and block array
		if pos.z > ref.z then
			if f[pos.z - 1][pos.x][pos.y] ~= nil then
				if f[pos.z - 1][pos.x][pos.y] < f[pos.z][pos.x][pos.y] and b[pos.z - 1][pos.x][pos.y] == 0 then
					nextdir = 4
				end
			end
		end
		if pos.x > ref.x then
			if f[pos.z][pos.x - 1][pos.y] ~= nil then
				if f[pos.z][pos.x - 1][pos.y] < f[pos.z][pos.x][pos.y] and b[pos.z][pos.x - 1][pos.y] == 0 then
					nextdir = 3
				end
			end
		end
		if pos.y > ref.y then
			if f[pos.z][pos.x][pos.y - 1] ~= nil then
				if f[pos.z][pos.x][pos.y - 1] < f[pos.z][pos.x][pos.y] and b[pos.z][pos.x][pos.y - 1] == 0 then
					nextdir = 0
				end
			end
		end
		if pos.x < X then
			if f[pos.z][pos.x + 1][pos.y] ~= nil then
				if f[pos.z][pos.x + 1][pos.y] < f[pos.z][pos.x][pos.y] and b[pos.z][pos.x + 1][pos.y] == 0 then
					nextdir = 1
				end
			end
		end
		if pos.y < Y then
			if f[pos.z][pos.x][pos.y + 1] ~= nil then
				if f[pos.z][pos.x][pos.y + 1] < f[pos.z][pos.x][pos.y] and b[pos.z][pos.x][pos.y + 1] == 0 then
					nextdir = 2
				end
			end
		end
		if pos.z < Z then
			if f[pos.z + 1][pos.x][pos.y] ~= nil then
				if f[pos.z + 1][pos.x][pos.y] < f[pos.z][pos.x][pos.y] and b[pos.z + 1][pos.x][pos.y] == 0 then
					nextdir = 5
				end
			end
		end
		
		d[pos.z][pos.x][pos.y] = 1	-- discovers cell currently standing in
		
		-- Attempts to move to the determined cell
		if		nextdir == 0 then moveN(pos)
		elseif	nextdir == 1 then moveE(pos)
		elseif	nextdir == 2 then moveS(pos)
		elseif	nextdir == 3 then moveW(pos)
		elseif 	nextdir == 4 then down(pos)
		elseif 	nextdir == 5 then up(pos)
		end
		-- print(nextdir)
		nextdir = nil
		
		-- print("At: ", pos.x, ",", pos.y, ",", pos.z, ";", pos.dir)
		-- print(f[pos.z][pos.x][pos.y])
		-- sleep(3)
		
		flood = sense(b, d, pos, ref, dim)
	end
end

-- Attempts to discover turtle's gps coordinates and orientation
function orient()
	local pos = {x = 0, y = 0, z = 0, dir = 0}	-- position initialization
	local pos1 = {x = 0, y = 0, z = 0}
	local pos2 = {x = 0, y = 0, z = 0}
	
	-- Gathers first gps reading
	pos.x, pos.y, pos.z = gps.locate()
	-- Sets first coordinates to initial reading by default
	pos1.x, pos1.y, pos1.z = pos.x, pos.y, pos.z
	-- Sets second coordinates to initial reading by default
	pos2.x, pos2.y, pos2.z = pos.x, pos.y, pos.z
	
	local turned = false
	local dir
	
	-- Moves the turtle around to an open space and records the two differing coordinates for direction determination
	if turtle.forward() then
		pos2.x, pos2.y, pos2.z = gps.locate()
		turtle.back()
	elseif turtle.back() then
		pos1.x, pos1.y, pos1.z = gps.locate()
		turtle.forward()
	else
		turned = true
		turtle.turnLeft()
		if turtle.forward() then
			pos2.x, pos2.y, pos2.z = gps.locate()
			turtle.back()
		elseif turtle.back() then
			pos1.x, pos1.y, pos1.z = gps.locate()
			turtle.forward()
		end
		turtle.turnRight()
	end
	
	-- Determines turtle direction based on measured positions
	-- 0 - North; 1 - East; 2 - South; 3 - West
	if pos2.x - pos1.x < 0 then
		dir = 3
	elseif pos2.y - pos1.y < 0 then
		dir = 0
	elseif pos2.x - pos1.x > 0 then
		dir = 1
	elseif pos2.y - pos1.y > 0 then
		dir = 2
	end
	
	-- If no place to move, retry one space up until some free space in the x-y plane is found
	if dir ~= nil then
		dir = (dir + (turned and 1 or 0))%4	-- corrects dir to original direction if turning occurred
	else	-- if all sides blocked, do same routine on different levels, trying to go up
		if turtle.up() then
			pos = orient()
			pos.z = pos.z - 1	-- compensates for testing on higher levels
			turtle.down()
		end
	end
	
	--for k,v in pairs(dir) do pos[k] = v end	-- appends two tables together
	pos.dir = dir	-- adds dir to table pos
	
	return pos
end

function nearestUndiscovered(b, d, lyr, row, col)
	local nextflood = 1000000
	
	local K = table.getn(b)				-- size of 1st dimension
	local I = table.getn(b[1])		-- size of 2nd dimension
	local J = table.getn(b[1][1])	-- size of 3rd dimension
	
	local flyr = 0
	local frow = 0
	local fcol = 0
	
	local f = floodFill(b, lyr, row, col)
	for i,I in ipairs(b) do
		for j,J in ipairs(b[i]) do
			for k,K in ipairs(b[i][j]) do
				if d[i][j][k] == 0 then
					if f[i][j][k] < nextflood then
						flyr = i
						frow = j
						fcol = k
						nextflood = f[i][j][k]
					end
				end
			end
		end
	end
	
	if flyr == 0 or frow == 0 or fcol == 0 then
		return false
	end
	return true, frow, fcol, flyr
end

function map(b, d, x, y, z, dir, rx, ry, rz)
	local ox, oy, oz, odir = x, y, z, dir	-- original position
	local lyr, row, col = z - rz + 1, x - rx + 1, y - ry + 1	-- current array position
	local valid, flyr, frow, fcol = false, lyr, row, col
	
	local f = {}
	
	local K = table.getn(b)				-- size of 1st dimension
	local I = table.getn(b[1])		-- size of 2nd dimension
	local J = table.getn(b[1][1])	-- size of 3rd dimension
	
	for i = 1,I*J*K do
		valid, flyr, frow, fcol = nearestUndiscovered(b, d, lyr, row, col)
		if valid then
			x, y, z, dir = goto(b, d, x, y, z, dir, rx + frow - 1, ry + fcol - 1, rz + flyr - 1, 0, rx, ry, rz)
		end
	end
	
	x, y, z, dir = goto(b, d, x, y, z, dir, ox, oy, oz, odir, rx, ry, rz)
	return x, y, z, dir
end

function mapBrute(b, d, x, y, z, dir, rx, ry, rz)
	local ox, oy, oz, odir = x, y, z, dir	-- original position
	local lyr, row, col = z - rz + 1, x - rx + 1, y - ry + 1	-- current array position
	local valid, flyr, frow, fcol = false, lyr, row, col
	
	local f = {}
	
	for i,I in ipairs(b) do
		for j,J in ipairs(b[i]) do
			for k,K in ipairs(b[i][j]) do
				if d[i][j][k] ~= 1 then
					print("Going to: ", rx + j - 1, " ", ry + k - 1, " ", rz + i - 1)
					x, y, z, dir = goto(b, d, x, y, z, dir, rx + j - 1, ry + k - 1, rz + i - 1, nil, rx, ry, rz)
					sleep(0)
				end
			end
		end
	end
	
	x, y, z, dir = goto(b, d, x, y, z, dir, ox, oy, oz, odir, rx, ry, rz)
	return x, y, z, dir
end

function split(s, delim) -- coppied from <http://www.gammon.com.au/forum/?id=6079&reply=2#reply2>

  assert (type (delim) == "string" and string.len (delim) > 0, "bad delimiter")

  local start = 1
  local t = {}  -- results table

  -- find each instance of a string followed by the delimiter

  while true do
    local pos = string.find (s, delim, start, true) -- plain find

    if not pos then
      break
    end

    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delim)
  end -- while

  -- insert final one (after last delimiter)

  table.insert (t, string.sub (s, start))

  return t
 
end -- function split

function gotoFull(fin)
	-- Size of search area
	local dim = {x = 15, y = 15, z = 15}
	
	-- Orients the turtle, giving current coordinates and direction facing
	local pos = nav.orient()
	
	-- Calculates where the search area should start, centering around the turtle and final positions
	local ref = {}
	ref.x = pos.x - math.floor(math.floor((dim.x + 1)/2) - (fin.x - pos.x)/2) + 1
	ref.y = pos.y - math.floor(math.floor((dim.y + 1)/2) - (fin.y - pos.y)/2) + 1
	ref.z = pos.z - math.floor(math.floor((dim.z + 1)/2) - (fin.z - pos.z)/2) + 1
	
	b = nav.create3DArray(dim, ref)	-- blocks array
	d = nav.create3DArray(dim, ref)	-- discovered array (same size as blocks array)
	
	nav.goto(b, d, pos, fin, ref, dim)
end
