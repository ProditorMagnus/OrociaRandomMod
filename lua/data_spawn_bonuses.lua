--<<
function ORM.bonus.strong(damage)
	return {
		name="strong",
		T.effect{
			apply_to = "attack",
			damage="1-999",
			increase_damage=damage
		}
	}
end
-->>
