--<<
-- once being first_time_only=yes

-- todo this event might not be needed, consider moving to start
function ORM.event.once.new_turn()
	ORM.fun.set_suitable_enemy_color()
	ORM.fun.add_allied_tent(14, 21)

	wesnoth.fire("event", {
		name = "AE_show_beta_menu",
		first_time_only = false,
		T.lua({
			code="AE_beta_ORM_debug()"
		})
	})
end

function ORM.event.new_turn()
	if V.ORM_difficulty_mode == "ultrahardcore" then
		ORM.fun.increment_hpmultiplier()
	end
	if ORM.fun.get_effective_turn_number() == 30 and V.ORM_difficulty_mode == "normal" and not V.ORM_normal_difficulty_setting_endgame_mode_adjusted then
		-- So that charge, magical and backstab wont be too low -- ORM_normal_difficulty_setting_endgame_mode_adjusted to not overbuff when repeating waves
		V.ORM_difficulty_setting = V.ORM_difficulty_setting + 0.4
		V.ORM_normal_difficulty_setting_endgame_mode_adjusted = true
	end
	if V.ORM_map_setting == "swamp" then
		wesnoth.game_config.poison_amount = 10 + ORM.fun.get_effective_turn_number() / 4
	end
	ORM.fun.spawn_wave() -- calls unit spawning, turn bonus
	ORM.fun.update_spawn_labels() -- label creation happens every turn to better support wave repeating
	ORM.fun.show_setting_labels() -- remakes labels against bonusspam

	local switch = {
		ultrahardcore = function()
		end,
		hardcore = function()
		end,
		normal = function()
		end,
		easy = function()
			wesnoth.game_config.kill_experience = 12
		end
	}
	switch[V.ORM_difficulty_mode]()
end

function ORM.event.start()
	V.Rav_DBG_1 = true -- AI side, so able to undroid it and use commands
	V.ORM_turn_offset = 0
	V.ORM_win_turn = 46
	V.ORM_turns_to_win_from_last_wave = 6

	if V.ORM_hpmultiplier_setting == nil then V.ORM_hpmultiplier_setting = 0 end
	V.ORM_hpmultiplier_setting = V.ORM_hpmultiplier_setting * 0.01

	V.ORM_random_ageless_waves = ORM.fun.table_contains({"ageless_random_full", "ageless_random_mirrored"}, V.ORM_wave_choice_setting)

	V.ORM_agelessunits_available = wesnoth.scenario.era.id:find("Ageless") or V.ORM_wave_choice_setting:find("ageless") or false

	ORM.fun.remove_turn_limit()
	ORM.fun.initialise_difficulty_modes()
	V.ORM_normal_difficulty_setting_endgame_mode_adjusted = false

	wesnoth.wml_actions.set_menu_item{
		id='ORM_delay_waves',
		description='Make all future waves come 1 turn later',
		T.filter_location{
			x=1,
			y=1
		},
		T.command{
			T.lua{
				code='V.ORM_turn_offset = V.ORM_turn_offset + 1'
			},
			T.lua{
				code='ORM.fun.update_spawn_labels()'
			},
			T.lua{
				code='wesnoth.message("Use wave delaying at your own risk, and note that if you delay enough times (such as right after wave spawned), you can have previously spawned wave spawn again - effectively endless game mode. Current delay: "..V.ORM_turn_offset.." turn(s)")'
			}
		}
	}
end

function ORM.event.side_1_turn_refresh()
	ORM.fun.apply_hpmultiplier()
end

function ORM.event.side_turn()
	if ORM.fun.get_effective_turn_number() == V.ORM_win_turn and V.side_number ~= 1 then
		wesnoth.wml_actions.endlevel{result="victory"}
	end
	if ORM.fun.get_effective_turn_number() > V.ORM_win_turn - V.ORM_turns_to_win_from_last_wave and #wesnoth.get_units{side=1} < 2 then
		wesnoth.wml_actions.end_turn{}
	end
end
-->>
