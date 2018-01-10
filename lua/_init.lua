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

V = helper.set_wml_var_metatable {} -- TODO add warning message when retrieving nonexisting

-- TODO apply rounding for specials
-- TODO cap total adaptive multiplier with base to 0.01, dont let be zero or lower
-- TODO remove adaptive difficulty setting, have it always work on hardcore+
-->>
