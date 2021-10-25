--<<

function ORM.fun.init_adaptive_difficulty()
	local result = 0
	-- another way - f=wesnoth.require "functional", f.find(wesnoth.scenario.modifications, function (e) return e.id=="plan_unit_advance" end)
	local modifications = ORM.fun.map(function(mod) return mod.id end, wesnoth.scenario.modifications)
	if ORM.fun.table_contains(modifications, "StealingWeaponsMode") then
		result = result + 0.2
	end
	if ORM.fun.table_contains(modifications, "BonusSpam") then
		result = result + 0.5
	end
	if ORM.fun.table_contains(modifications, "CanBeOnlyOne") then
		result = result + 6.66
	end
	if ORM.fun.table_contains(modifications, "EXI_Heroic_Mod") then
		result = result + 0.1
	end
	if ORM.fun.table_contains(modifications, "EXI_Rush_Mod") then
		result = result + 0.1 -- maybe for the future find other solutions like better movecosts
	end
	if ORM.fun.table_contains(modifications, "Xara_Magic_Mod") then
		result = result + 0.3
	end

	local c = V.Rav_XP_hp_cost
	if (c) then
		result = result + 9/(c*c)
	end
	local c = V.Rav_XP_damage_cost
	if (c) then
		result = result + 0.9/(c)
	end
	local c = V.mod_switch_leader_no_limit
	if (c) then
		result = result + 0.15
	end
	local c = V.ORM_random_ageless_waves
	if (c) then
		result = result - 0.5
	end
	local c = V.ORM_wave_choice_setting
	if (c == "ageless_predefined_1") then
		result = result - 0.5
	end
	local c = V.umm_magic_list_option
	if (c) then
		result = result + 0.2 + c/10
	end
	if (V.ORM_tenthealer_setting and V.ORM_alliedtent_setting) then
		result = result + 0.05
	end
	local c = V.ORM_map_setting
	if (c == "frozen") then
		result = result + 0.3
	end
	if (c == "suns") then
		result = result - 0.1
	end
	if V.ORM_upgrade_setting == 0 then
		result = result - 0.4
	end

	if (wesnoth.scenario.era.id == "era_default" or wesnoth.scenario.era.id == "era_heroes" or 
            wesnoth.scenario.era.id == "era_dunefolk" or wesnoth.scenario.era.id == "era_dunefolk_heroes") then
		result = result - 0.4
		if (V.ORM_random_ageless_waves) then
			result = result - 0.2
		end
	end

	result = result*100
	result = math.floor(result)
	result = result/100.0

	if ((V.ORM_adaptive_difficulty and V.ORM_difficulty_mode == "hardcore") or (V.ORM_adaptive_difficulty and V.ORM_difficulty_mode == "ultrahardcore")) then
		wesnoth.message("Adaptive difficulty rating calculated: "..result..", adding together with base-> "..V.ORM_difficulty_setting+result)
		V.ORM_difficulty_setting = V.ORM_difficulty_setting+result
	end
end

-->>
