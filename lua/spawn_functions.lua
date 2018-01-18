--<<
function ORM.fun.random_unit(level,x,y,side)
	if level == nil then error("Level is nil") end
	-- TODO 1.13 use wesnoth.random
	wesnoth.fire("set_variable", { name = "LUA_random", rand = string.format("%d..%d", 1, #level) })
	local unitid = level[V.LUA_random]
	V.LUA_random = nil
	-- wesnoth.fire("unit", { type = unitid, placement = "map_passable", x = x, y = y, side = side })
	ORM.fun.spawn_unit(unitid, x, y, side)
	-- wesnoth.fire("set_variable", { name = "ORM_last_unit", value = unitid })
	V.ORM_last_unit = unitid
end

function ORM.fun.previous_unit(x,y,side)
	local unitid = V.ORM_last_unit
	-- wesnoth.fire("unit", { type = unitid, placement = "map_passable", x = x, y = y, side = side })
	ORM.fun.spawn_unit(unitid, x, y, side)
end

function ORM.fun.spawn_unit(type, x, y, side)
	-- TODO https://github.com/wesnoth/wesnoth/issues/2358
	-- local u = wesnoth.create_unit({
		-- type=type,
		-- x=x,
		-- y=y,
		-- side=side,
		-- placement="map_passable" -- not possible in Lua it seems
	-- })
	-- wesnoth.put_unit(u)
	wesnoth.fire("unit", { type = type, placement = "map_passable", x = x, y = y, side = side })
end

function ORM.fun.spawn_unit_set(level, location, original_type)
	local ai_side = 1
	local waveSetting = V.ORM_wave_choice_setting

	if ORM.unit.level[level] == nil then
		helper.wml_error("ORM.fun.spawn_unit_set","level "..level.." not implemented")
	end
	level = ORM.unit.level[level]

	if waveSetting == "ageless_random_full" then
		for _,loc in ipairs(location) do
			ORM.fun.random_unit(level, loc.x, loc.y, ai_side)
		end
	end
	if waveSetting == "ageless_random_mirrored" then
		for i,loc in ipairs(location) do
			if i == 1 then
				ORM.fun.random_unit(level, loc.x, loc.y, ai_side)
			else
				ORM.fun.previous_unit(loc.x, loc.y, ai_side)
			end
		end
	end
	if waveSetting == "core_predefined" then
		for _,loc in ipairs(location) do
			-- wesnoth.fire("unit", { type = original_type, placement = "map_passable", x = loc.x, y = loc.y, side = ai_side })
			ORM.fun.spawn_unit(original_type, loc.x, loc.y, ai_side)
		end
	end
end

function ORM.fun.spawn_wave()
	if ORM.waves["t"..wesnoth.current.turn] ~= nil then
		for _,v in ipairs(ORM.waves["t"..wesnoth.current.turn]) do
			ORM.fun.spawn_unit_set(v.random_level, v.location, v.original_type)
		end
		ORM.fun.update_spawn_labels()
	end
	ORM.fun.apply_wave_modifications()
end

function ORM.fun.apply_wave_modifications()
	if ORM.unit_bonuses["t"..wesnoth.current.turn] == nil then return end

	local difficulty = V.ORM_difficulty_mode
	-- TODO if core waves and normal or hardcore, then use difficulty=predefined
	if V.ORM_wave_choice_setting == "core_predefined" and (difficulty == "normal" or difficulty=="hardcore") then difficulty = "predefined" end
	local bonus = ORM.unit_bonuses["t"..wesnoth.current.turn][difficulty]
	local units = wesnoth.get_units { side = 1 }
	if bonus == nil then return	end
	for _,u in ipairs(units) do
		if bonus.name == nil then
			for _,b in ipairs(bonus) do
				wesnoth.add_modification(u, "trait", ORM.bonus.evaluate(b))
			end
		else
			wesnoth.add_modification(u, "trait", ORM.bonus.evaluate(bonus))
		end
	end
	-- for i, u in ipairs(units) do
		-- wesnoth.add_modification(u, "trait", ORM.bonus.strong(0))
	-- end
end

function ORM.fun.backport_label(cfg)
	cfg.visible_in_fog = true
	cfg.visible_in_shroud = true
	-- TODO 1.13 remove in favor of wesnoth.label()
	wesnoth.fire("label", { x = cfg.x, y = cfg.y, text = cfg.text, color = cfg.color, visible_in_fog = cfg.visible_in_fog, visible_in_shroud = cfg.visible_in_shroud, immutable = cfg.immutable })
end

function ORM.fun.update_spawn_labels()
	local waveSetting = V.ORM_wave_choice_setting

	-- remove labels after spawning
	if ORM.waves["t"..wesnoth.current.turn] ~= nil then
		for _,v in ipairs(ORM.waves["t"..wesnoth.current.turn]) do
			for _,loc in ipairs(v.location) do
				ORM.fun.backport_label({
					x=loc.x,
					y=loc.y,
					text="",
					visible_in_fog=true,
					visible_in_shroud=true,
					immutable=false
				})
			end
		end
	end

	local next_wave = wesnoth.current.turn+1
	local wave_trial_limit = next_wave + 10
	while ORM.waves["t"..next_wave] == nil do
		next_wave = next_wave+1
		if next_wave > wave_trial_limit then
			if wesnoth.current.turn ~= ORM.win_turn then
				helper.wml_error("ORM.fun.update_spawn_labels() finding next wave failed")
			end
			return
		end
	end
	local spawn_label_text = ORM.wave_labels["t"..next_wave][waveSetting]

	if spawn_label_text then
		ORM.fun.backport_label({
			x=14,
			y=2,
			color="255,127,0",
			text="Turn "..next_wave..": " .. spawn_label_text
		})
		ORM.fun.backport_label({
			x=14,
			y=21,
			color="255,127,0",
			text="Turn "..next_wave..": " .. spawn_label_text
		})
	end

	for i,v in ipairs(ORM.waves["t"..next_wave]) do
		for _,loc in ipairs(v.location) do
			local label_text = "Unhandled waveSetting "..waveSetting..", report"
			if waveSetting == "ageless_random_full" then
				label_text = "Level "..v.random_level
			end
			if waveSetting == "ageless_random_mirrored" then
				label_text = "Level "..v.random_level.." group "..i
			end
			if waveSetting == "core_predefined" then
				label_text = v.original_type
			end
			ORM.fun.backport_label({
				x=loc.x,
				y=loc.y,
				text=label_text,
				color="160,160,0",
				visible_in_fog=true,
				visible_in_shroud=true,
				immutable=false
			})
		end
	end
end
-->>
