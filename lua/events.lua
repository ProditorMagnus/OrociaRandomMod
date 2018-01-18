--<<
-- once being first_time_only=yes

-- todo this event might not be needed, consider moving to start
function ORM.event.once.new_turn()
	ORM.fun.set_suitable_enemy_color()
	ORM.fun.add_allied_tent(14, 21)
end

function ORM.event.new_turn()
	if V.ORM_difficulty_mode == "ultrahardcore" then
		ORM.fun.increment_hpmultiplier()
	end
	if V.ORM_map_setting == "swamp" then
		wesnoth.game_config.poison_amount = 10 + wesnoth.current.turn / 4
	end
	ORM.fun.spawn_wave() -- calls unit spawning, label creation, turn bonus
	ORM.fun.show_setting_labels() -- remakes labels against bonusspam
end

function ORM.event.start()
	V.Rav_DBG_1 = true -- AI side, so able to undroid it and use commands

	if V.ORM_hpmultiplier_setting == nil then V.ORM_hpmultiplier_setting = 0 end
	V.ORM_hpmultiplier_setting = V.ORM_hpmultiplier_setting * 0.01

	V.ORM_random_ageless_waves = ORM.fun.table_contains({"ageless_random_full", "ageless_random_mirrored"}, V.ORM_wave_choice_setting)

	V.ORM_agelessunits_available = wesnoth.game_config.mp_settings.mp_era:find("Ageless") or V.ORM_wave_choice_setting:find("ageless")

	ORM.fun.remove_turn_limit()
	ORM.fun.initialise_difficulty_modes()
end

function ORM.event.side_1_turn_refresh()
	ORM.fun.apply_hpmultiplier()
	ORM.fun.apply_rush_mod() -- !!!! OOS
end
-->>
