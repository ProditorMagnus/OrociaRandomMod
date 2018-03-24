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

function Ravana()
	return type(AE_condition_use_beta_features) == "function" and AE_condition_use_beta_features()
end

local proxy_var_mt = {
	__index    = function(t, k)
		local v = wml.variables_proxy[k]
		if v == nil and Ravana() then
			wesnoth.message("INFO","V."..k.." is nil at "..debug.traceback("",2))
		end
		return v
	end,
	__newindex = function(t, k, v) wml.variables_proxy[k] = v end,
}

V = setmetatable({}, proxy_var_mt)

-- TODO apply rounding for specials
-- TODO cap total adaptive multiplier with base to 0.01, dont let be zero or lower
-- TODO remove adaptive difficulty setting, have it always work on hardcore+
-->>
