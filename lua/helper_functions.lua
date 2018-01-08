--<<
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
-->>
