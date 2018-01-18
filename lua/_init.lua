--<<
H = wesnoth.require "lua/helper.lua"
helper = H
T = helper.set_wml_tag_metatable {}

ORM = {}
ORM.unit = {}
ORM.loc = {}
ORM.fun = {}
ORM.bonus = {}
ORM.effect = {}
ORM.debug = {}
ORM.event = {}
ORM.event.once = {}

ORM.win_turn = 46

V = helper.set_wml_var_metatable {}

function Ravana()
	return type(AE_condition_use_beta_features) == "function" and AE_condition_use_beta_features()
end

local old_index = getmetatable(V).__index
getmetatable(V).__index = function(t, k)
	local v = old_index(t, k)
	if v == nil then
		if Ravana() then
			wesnoth.message("INFO","V."..k.." is nil at "..debug.traceback("",2))
		end
	end
	return v
end

-- TODO apply rounding for specials
-- TODO cap total adaptive multiplier with base to 0.01, dont let be zero or lower
-- TODO remove adaptive difficulty setting, have it always work on hardcore+
-->>
