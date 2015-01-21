local args = { ... }

if #args ~= 3 and #args ~= 4 then
	print("Bad program call.")
	do return end
end

os.loadAPI("nav")

for i,I in ipairs(args) do args[i] = tonumber(I) end	-- forces all arguments to become number types

-- Final position derived from arguments
local home = {x = args[1], y = args[2], z = args[3], dir = args[4]}

nav.goto(home)

-- local file = fs.open("trace.txt", "r")

-- local i = 0
-- local coords = {}

-- repeat
	-- i = i + 1
	-- coords[i] = file.readLine()
	-- if coords[i] ~= nil then
		-- coords[i] = nav.split(coords[i], ",")
	-- end
-- until coords[i] == nil

-- for i,I in ipairs(coords) do
	-- for j,J in ipairs(coords[i]) do
		-- coords[i][j] = tonumber(coords[i][j])
	-- end
	-- print(coords[i][1], ",", coords[i][2], ",", coords[i][3])
	-- nav.goto({x = coords[i][1], y = coords[i][2], z = coords[i][3]})
-- end
