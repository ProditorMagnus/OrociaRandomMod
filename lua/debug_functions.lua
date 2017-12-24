--<<
function dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
		 if k == nil then
			s = s .. '[nil] = ' .. dump_table(v) .. ','
		 else
			r = dump_table(v)
			if r == nil then
				s = s .. '['..k..'] = nil,'
			else
				s = s .. '['..k..'] = ' .. dump_table(v) .. ','
			end
		end
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function dump(o)
	wesnoth.message(dump_table(o))
end

function add_wave(turn, wave)
	-- local wave = {}
	-- function add_spawn(number, location, level)
		-- local spawn_location = location.."_"..number
		-- if _G[spawn_location] == nil then
			-- helper.wml_error("add_wave called with location and number that do not define spawn location, allowed water, land_near, land_far with amounts 3,6,9; without 9 at water")
		-- end
		-- return {
			-- random_level=0,
			-- original_type="No original type defined",
			-- location=_G[spawn_location]
		-- }
	-- end
	-- for i,v in ipairs(data) do

	-- end
	ORM_waves["t"..turn] = wave
end

-- add_wave(2, {{
	-- random_level=4,
	-- location=ORM_land_near_3
-- },
-- {
	-- random_level=3,
	-- location=ORM_water_3
-- }})

-->>
