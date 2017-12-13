--<<
function randomUnit(level,x,y,side)
	wesnoth.fire("set_variable", { name = "LUA_random", rand = string.format("%d..%d", 1, #level) })
	local unitid = level[wesnoth.get_variable "LUA_random"]
	wesnoth.set_variable "LUA_random"
	wesnoth.fire("unit", { type = unitid, placement = "map_passable", x = x, y = y, side = side })
	wesnoth.fire("set_variable", { name = "ORM_last_unit", value = unitid })
end

function previousUnit(level,x,y,side)
	local unitid = wesnoth.get_variable "ORM_last_unit"
	wesnoth.fire("unit", { type = unitid, placement = "map_passable", x = x, y = y, side = side })
end


function spawnUnitSet(level, location, original_type)
	local ai_side = 1
	local waveSetting = wesnoth.get_variable "ORM_wave_choice_setting"
	
	if levelMap[level] == nil then
		wesnoth.message("_spawnUnitSet_","level "..level.."not implemented")
		return
	end
	level = levelMap[level]
	
	if waveSetting == "ageless_random_full" then
		for i,loc in ipairs(location) do
			randomUnit(level, loc.x, loc.y, ai_side)
		end
	end
	if waveSetting == "ageless_random_mirrored" then
		for i,loc in ipairs(location) do
			if i == 1 then
				randomUnit(level, loc.x, loc.y, ai_side)
			else
				previousUnit(level, loc.x, loc.y, ai_side)
			end
		end
	end
	if waveSetting == "core_predefined" then
		for i,loc in ipairs(location) do
			wesnoth.fire("unit", { type = original_type, placement = "map_passable", x = loc.x, y = loc.y, side = ai_side })
		end
	end
end

function spawnWave()
	if waves["t"..wesnoth.current.turn] == nil then
	--	wesnoth.message("_del_","waves at t current turn is nil")
	else
		for i,v in ipairs(waves["t"..wesnoth.current.turn]) do
			spawnUnitSet(v.random_level, v.location, v.original_type)
	--		wesnoth.message("_del_","should create unit "..v.random_level)
	--		for j,loc in ipairs(v.location) do
	--			wesnoth.message("_del_","should create "..v.original_type.."at "..loc.x..", "..loc.y)
	--		end
		end
	end
end
-->>
