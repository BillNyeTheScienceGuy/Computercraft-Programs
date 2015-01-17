local args = { ... }

if #args ~= 4 then
	print("Bad program call.")
	do return end
end

os.loadAPI("nav")

for i,I in ipairs(args) do args[i] = tonumber(I) end	-- forces all arguments to become number types

-- Final position derived from arguments
local fin = {x = args[1], y = args[2], z = args[3], dir = args[4]}

print("Going to ", fin.x, ",", fin.y, ",", fin.z, ";", fin.dir)

nav.gotoFull(fin)
