--<<
H = wesnoth.require "lua/helper.lua"
helper = H
T = helper.set_wml_tag_metatable {}

ORM = {}
ORM.unit = {}
ORM.loc = {}
ORM.fun = {}
ORM.bonus = {}
ORM.debug = {}
V = helper.set_wml_var_metatable {}
-->>
