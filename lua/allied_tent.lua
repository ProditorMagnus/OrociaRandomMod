--<<

function ORM.fun.add_allied_tent(x, y)
	if not V.ORM_alliedtent_setting then return end

	-- TODO 1.13 wesnoth.add_event_handler if it stays after reload

	wesnoth.fire("event", {
		name = "moveto",
		first_time_only = true,
		T.filter({
			side="2,3,4,5",
			x=x,
			y=y
		}),
		T.lua({
			code="ORM.fun.on_allied_tent_move("..x..","..y..")"
		})
	})

	local items = wesnoth.require "lua/wml/items.lua"
	items.place_image(x, y, "scenery/tent-fancy-red.png")
end

function ORM.fun.on_allied_tent_move(x, y)
	local items = wesnoth.require "lua/wml/items.lua"
	items.remove(x, y, "scenery/tent-fancy-red.png")

	if V.ORM_agelessunits_available then
		if V.ORM_tenthealer_setting then
			ORM.fun.random_unit(ORM.unit.level_two_healer,x,y,wesnoth.current.side,wesnoth.current.side)
			ORM.fun.random_unit(ORM.unit.level_two,x,y,wesnoth.current.side,wesnoth.current.side)
		else
			ORM.fun.random_unit(ORM.unit.level_two,x,y,wesnoth.current.side,wesnoth.current.side)
			ORM.fun.random_unit(ORM.unit.level_two,x,y,wesnoth.current.side,wesnoth.current.side)
		end
	else
		if V.ORM_tenthealer_setting then
			ORM.fun.random_unit(ORM.unit.core_tent,x,y,wesnoth.current.side,wesnoth.current.side)
			ORM.fun.random_unit(ORM.unit.core_healer,x,y,wesnoth.current.side,wesnoth.current.side)
		else
			ORM.fun.random_unit(ORM.unit.core_tent,x,y,wesnoth.current.side,wesnoth.current.side)
			ORM.fun.random_unit(ORM.unit.core_tent,x,y,wesnoth.current.side,wesnoth.current.side)
		end
	end
end

-->>
