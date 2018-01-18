--<<
function ORM.fun.map(func, array)
	local new_array = {}
	for i,v in ipairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end

function ORM.fun.table_contains(t, v)
    for key, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

function ORM.fun.set_suitable_enemy_color()
	local seenRed = false
	local seenGold = false
	local seenWhite = false
	local seenGreen = false

	for i,v in ipairs(wesnoth.sides) do
		if i ~= 1 then
			if v.color == "1" then
				seenRed = true
			end
			if v.color == "gold" or v.color == "Rav_yellow" or v.color == "6" then
				seenGold = true
			end
			if v.color == "8" then
				seenWhite = true
			end
			if v.color == "3" then
				seenGreen = true
			end
		end
	end

	if seenRed then
		if seenGold then
			if seenWhite then
				if not seenGreen then
					wesnoth.sides[1].color = "3"
					wesnoth.wml_actions.modify_side { side=1, flag="flags/flag-[1~4].png:250~RC(magenta>3)", }
				end
			else
				wesnoth.sides[1].color = "8"
				wesnoth.wml_actions.modify_side { side=1, flag="flags/flag-[1~4].png:250~RC(magenta>8)", }
			end
		else
			if V.Rav_Color_Yellow then
				wesnoth.sides[1].color = "Rav_yellow"
				-- TODO 1.13.7 can write to flag
				wesnoth.wml_actions.modify_side { side=1, flag="flags/flag-[1~4].png:250~RC(magenta>Rav_yellow)", }
			else
				wesnoth.sides[1].color = "gold"
				wesnoth.wml_actions.modify_side { side=1, flag="flags/flag-[1~4].png:250~RC(magenta>gold)", }
			end
		end
	end
end

function ORM.fun.increment_hpmultiplier()
	V.ORM_hpmultiplier_setting = V.ORM_hpmultiplier_setting + 0.01
	V.ORM_hpmultiplier_announce = "HP multiplier: "..tostring(100*V.ORM_hpmultiplier_setting).." %"
	ORM.fun.backport_label({
		x=2,
		y=22,
		visible_in_fog=true,
		visible_in_shroud=true,
		color="0,255,255",
		text=V.ORM_hpmultiplier_announce
	})
end

function ORM.fun.apply_hpmultiplier()
	local hitpoints_modifier = 100 * (V.ORM_hpmultiplier_setting - 1)
	local units = wesnoth.get_units{
		side = 1,
		T["not"]{
			T.filter_wml{
				T.status{
					ORM_hpmultiplied="yes"
				}
			}
		}
	}

	for i,u in ipairs(units) do
		wesnoth.add_modification(u, "object", {
			ORM.effect.get(ORM.effect.multiply_total_hitpoints(hitpoints_modifier)),
			ORM.effect.get(ORM.effect.multiply_current_hitpoints(hitpoints_modifier)),
			ORM.effect.get(ORM.effect.add_status("ORM_hpmultiplied"))
		})
	end
end

function ORM.fun.apply_rush_mod()
	if wesnoth.game_config.mp_settings.active_mods:find("EXI_Rush_Mod") then
		local movement_modifier
		if V.ORM_castledestruction_setting then
			movement_modifier = 1.3
		else
			movement_modifier = 1.8
		end
		if wesnoth.current.turn <= 1 then
			movement_modifier = 1
		end
		local units = wesnoth.get_units{
			side = 1,
			T["not"]{
				T.filter_wml{
					T.status{
						ORM_rush_mod="yes"
					}
				}
			}
		}

		local message = ""
		for i,u in ipairs(units) do
			local old_moves = u.moves
			wesnoth.add_modification(u, "object", {
				ORM.effect.get(ORM.effect.add_status("ORM_rush_mod"))
			})
			message = message .. "unit "..tostring(u.x)..", "..tostring(u.y).." with moves "..tostring(u.moves).." multiplied with "..tostring(movement_modifier).." giving "..tostring(u.moves * movement_modifier) .. " -> "
			u.moves = u.moves * movement_modifier
			message = message .. tostring(u.moves) .. "\n"
			if old_moves > 3.5 and movement_modifier > 1.29 and u.moves == old_moves then
				wesnoth.message("ORM debug", message)
				wesnoth.message("ORM error","Movement change not applied correctly! Report to Ravana")
			end
			u.moves = old_moves -- TODO re-add if no more oos
		end
		-- wesnoth.message("ORM debug", message) -- TODO replicate it in small scenario
	end
end

function ORM.fun.initialise_difficulty_modes()
	V.ORM_hpmultiplier_setting = 0
	local switch = {
		ultrahardcore = function()
			V.ORM_hpmultiplier_setting =  V.ORM_hpmultiplier_setting + 1.1
			V.ORM_difficulty_setting = 1.2
			ORM.fun.init_adaptive_difficulty()
			ORM.fun.set_village_support(1)
		end,
		hardcore = function()
			V.ORM_hpmultiplier_setting =  V.ORM_hpmultiplier_setting + 1
			V.ORM_difficulty_setting = 1
			ORM.fun.init_adaptive_difficulty()
			ORM.fun.set_village_support(1)
		end,
		normal = function()
			V.ORM_hpmultiplier_setting =  V.ORM_hpmultiplier_setting + 0.9
			V.ORM_difficulty_setting = 0.6
		end,
		easy = function()
			V.ORM_hpmultiplier_setting =  V.ORM_hpmultiplier_setting + 0.8
			V.ORM_difficulty_setting = 0
			wesnoth.game_config.kill_experience = 12
		end
	}
	switch[V.ORM_difficulty_mode]()
end

function ORM.fun.set_village_support(support)
	for i, side in ipairs(wesnoth.get_sides{
		T.enemy_of{
			side=1
		}
	}) do
		side.village_support = support
	end
end

function ORM.fun.remove_turn_limit()
	if (wesnoth.game_config.last_turn >= 0) then
		wesnoth.message("Turn limit detected and removed")
		wesnoth.game_config.last_turn = -1
	end
end

function ORM.fun.show_setting_labels()
	local text = {
		[0] = "No Upgrades",
		[1] = "Randomless (Sequence->res->hp->dmg->mv->)",
		[2] = "Normal (Nothing(2)/res/hp/dmg/mv/str)",
		[3] = "Chaos (Zonk/res/hp/dmg/str/mv)",
		[4] = "Mega Chaos (Zonk/res/hp/dmg/mv/str/def)"
	}
	ORM.fun.backport_label({
		x=2,
		y=17,
		text=text[V.ORM_upgrade_setting],
		color="255,255,0"
	})

	local text = {
		[true] = "Individual upgrades ON",
		[false] = "Individual upgrades OFF"
	}
	ORM.fun.backport_label({
		x=3,
		y=18,
		text=text[V.ORM_individualupgrade_setting],
		color="200,200,0"
	})

	local text = {
		default="Default map",
		ronsmap="Fall map",
		suns="Two Suns map",
		frozen="Frozen map",
		swamp="Swamp map"
	}
	ORM.fun.backport_label({
		x=2,
		y=18,
		text=text[V.ORM_map_setting],
		color="255,127,0"
	})

	local text = {
		ageless_random_full="Full random Ageless",
		ageless_random_mirrored="Mirrored random Ageless",
		ageless_predefined_1="Ageless predefined (1)",
		core_predefined="Core predefined",
		debug="Debug (No waves)"
	}
	ORM.fun.backport_label({
		x=2,
		y=19,
		text=text[V.ORM_wave_choice_setting],
		color="0,255,0"
	})

	local text = {
		[true] = "Tent ON",
		[false] = "Tent OFF"
	}
	ORM.fun.backport_label({
		x=2,
		y=20,
		text=text[V.ORM_alliedtent_setting],
		color="200,200,200"
	})

	local text = {
		[true] = "Arsenals ON",
		[false] = "Arsenals OFF"
	}
	ORM.fun.backport_label({
		x=3,
		y=21,
		text=text[V.ORM_arsenal_setting],
		color="200,200,200"
	})

	local text = {
		[true] = "Castle destruction ON",
		[false] = "Castle destruction OFF"
	}
	ORM.fun.backport_label({
		x=2,
		y=21,
		text=text[V.ORM_castledestruction_setting],
		color="255,0,255"
	})

	local text = {
		[true] = "Tent healer ON",
		[false] = "Tent healer OFF"
	}
	ORM.fun.backport_label({
		x=4,
		y=20,
		text=text[V.ORM_tenthealer_setting],
		color="200,200,200"
	})

	ORM.fun.backport_label({
		x=2,
		y=22,
		text="HP multiplier: ".. tostring(100*V.ORM_hpmultiplier_setting).." %",
		color="0,255,255"
	})

	local text = {
		ultrahardcore="Ultra Hardcore, adaptive difficulty rating: "..tostring(100*V.ORM_difficulty_setting)..tostring(" %"),
		hardcore="Hardcore, adaptive difficulty rating: "..tostring(100*V.ORM_difficulty_setting)..tostring(" %"),
		normal="Normal",
		easy="Easy"
	}
	ORM.fun.backport_label({
		x=3,
		y=23,
		text=text[V.ORM_difficulty_mode],
		color="255,255,0"
	})
end
-->>
