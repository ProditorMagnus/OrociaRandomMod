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



-->>
