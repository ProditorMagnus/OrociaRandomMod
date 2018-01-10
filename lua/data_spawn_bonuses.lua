--<<
-- TODO allow adding description to trait
function ORM.bonus.evaluate(bonus)
	local name = bonus.name
	local bonus = ORM.fun.map(function(e) return e() end, bonus)
	bonus.name = name
	-- inspect(bonus)
	return bonus
end

-- returns bonus without using adaptive multiplier
function ORM.bonus.get(bonus)
	local name = bonus.name
	local adr = V.ORM_difficulty_setting
	V.ORM_difficulty_setting = 1
	local bonus = ORM.fun.map(function(e) return e() end, bonus)
	V.ORM_difficulty_setting = adr
	bonus.name = name
	return bonus
end

function ORM.effect.get(effect)
	local adr = V.ORM_difficulty_setting
	V.ORM_difficulty_setting = 1
	local e = effect()
	V.ORM_difficulty_setting = adr
	return e
end

-- Usable for building trait that includes multiple bonuses
function ORM.bonus.build(name, effects)
	if name == nil then helper.wml_error("name being nil in ORM.bonus.build breaks detecting if current turn has one or many bonuses") end
	effects.name = name
	return effects
end

-- wrappers for normal traits
function ORM.bonus.strong(damage)
	local name
	if damage < 0 then name = "weak" end
	if damage > 0 then name = "strong" end
	if damage == 0 then name = "dummy" end

	return ORM.bonus.build(name, {ORM.effect.increase_damage(damage)})
end

function ORM.bonus.weak(damage)
	return ORM.bonus.strong(-damage)
end

function ORM.bonus.swift(movement_modifier, strike_modifier)
	return ORM.bonus.build("swift", {ORM.effect.multiply_movement(movement_modifier), ORM.effect.multiply_strikes(strike_modifier)})
end

function ORM.bonus.mighty(movement_modifier, damage_modifier)
	return ORM.bonus.build("mighty", {ORM.effect.multiply_movement(movement_modifier), ORM.effect.multiply_damage(damage_modifier)})
end

function ORM.bonus.bulky(hitpoints_modifier, damage_modifier)
	return ORM.bonus.build("bulky", {ORM.effect.multiply_total_hitpoints(hitpoints_modifier), ORM.effect.multiply_current_hitpoints(hitpoints_modifier), ORM.effect.multiply_damage(damage_modifier)})
end

-- same as bulky, but different display name
function ORM.bonus.powerful(hitpoints_modifier, damage_modifier)
	return ORM.bonus.build("powerful", {ORM.effect.multiply_total_hitpoints(hitpoints_modifier), ORM.effect.multiply_current_hitpoints(hitpoints_modifier), ORM.effect.multiply_damage(damage_modifier)})
end

function ORM.bonus.deadly(accuracy_value)
	return ORM.bonus.build("deadly", {ORM.effect.increase_accuracy(accuracy_value)})
end

function ORM.bonus.charge(charge_modifier)
	return ORM.bonus.build("charge", {ORM.effect.add_charge(charge_modifier)})
end

function ORM.bonus.magical(cth_modifier)
	return ORM.bonus.build("magical", {ORM.effect.add_magical(cth_modifier)})
end

function ORM.bonus.skirmish()
	return ORM.bonus.build("skirmish", {ORM.effect.add_skirmish()})
end

function ORM.bonus.backstab(backstab_modifier)
	return ORM.bonus.build("backstab", {ORM.effect.add_backstab(backstab_modifier)})
end

function ORM.bonus.undead()
	return ORM.bonus.build("undead", {ORM.effect.add_status("unpoisonable"),ORM.effect.add_status("undrainable"),ORM.effect.add_status("unplagueable")})
end

-- effects to use
-- multiplying effects do not use adaptive modifier on negative values, otherwise they use
-- nonmultiplying effects do not use adaptive modifier, other than increase_accuracy
function ORM.effect.multiply_damage(damage_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if damage_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "attack",
			increase_damage=tostring(damage_modifier*adaptive_multiplier).."%"
		}
	end
end

function ORM.effect.increase_damage(damage)
	return function()
		return T.effect{
			apply_to = "attack",
			damage="1-999", -- TODO decide if it would be better to allow adding damage to unit with 0 damage
			increase_damage=damage
		}
	end
end

function ORM.effect.multiply_movement(movement_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if movement_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "movement",
			increase=tostring(movement_modifier*adaptive_multiplier).."%"
		}
	end
end

function ORM.effect.increase_movement(movement_number)
	return function()
		return T.effect{
			apply_to = "movement",
			increase=movement_number
		}
	end
end

function ORM.effect.multiply_strikes(strike_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if strike_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "attack",
			increase_attacks=tostring(strike_modifier*adaptive_multiplier).."%"
		}
	end
end

function ORM.effect.increase_strikes(strikes_number)
	return function()
		return T.effect{
			apply_to = "attack",
			increase_attacks=strikes_number
		}
	end
end

function ORM.effect.multiply_total_hitpoints(hitpoints_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if hitpoints_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "hitpoints",
			increase_total=tostring(hitpoints_modifier*adaptive_multiplier).."%"
		}
	end
end

function ORM.effect.increase_total_hitpoints(hitpoints_number)
	return function()
		return T.effect{
			apply_to = "hitpoints",
			increase_total=hitpoints_number
		}
	end
end

function ORM.effect.multiply_current_hitpoints(hitpoints_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if hitpoints_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "hitpoints",
			increase=tostring(hitpoints_modifier*adaptive_multiplier).."%"
		}
	end
end

function ORM.effect.increase_current_hitpoints(hitpoints_number)
	return function()
		return T.effect{
			apply_to = "hitpoints",
			increase=hitpoints_number
		}
	end
end

function ORM.effect.increase_accuracy(accuracy_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if accuracy_modifier < 0 then adaptive_multiplier = 1 end
		return T.effect{
			apply_to = "attack",
			increase_accuracy=accuracy_modifier*adaptive_multiplier
		}
	end
end

function ORM.effect.add_charge(charge_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if charge_modifier < 0 then adaptive_multiplier = 1 end
		local charge_modifier = charge_modifier*adaptive_multiplier
		return T.effect{
			apply_to = "attack",
			T.set_specials({
				mode="append",
				T.damage({
					id="charge",
					name="charge "..tostring(charge_modifier),
					description="When used offensively, this attack deals multiplied damage to the target. It also causes this unit to take multiplied damage from the target’s counterattack. Multiplier: "..tostring(charge_modifier),
					multiply=charge_modifier,
					apply_to="both",
					active_on="offense"
				})
			})
		}
	end
end

function ORM.effect.add_magical(cth_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if adaptive_multiplier < 1 then
			adaptive_multiplier = 1
		end
		if adaptive_multiplier > 2 then
			adaptive_multiplier = 2
		end
		if cth_modifier < 0 then adaptive_multiplier = 1 end
		local cth_modifier = cth_modifier+(100-cth_modifier)*(adaptive_multiplier-1)
		return T.effect{
			apply_to = "attack",
			T.set_specials({
				mode="append",
				T.chance_to_hit({
					id="magical",
					name="magical "..tostring(cth_modifier),
					description="This attack always has a fixed chance to hit regardless of the defensive ability of the unit being attacked. Chance: "..tostring(cth_modifier),
					value=cth_modifier,
					cumulative="no"
				})
			})
		}
	end
end

function ORM.effect.add_skirmish()
	return function()
		return T.effect{
			apply_to = "new_ability",
			T.abilities({
				T.skirmisher({
					id="skirmisher",
					name="skirmisher",
					description="This unit is skilled in moving past enemies quickly, and ignores all enemy Zones of Control.",
					affect_self="yes"
				})
			})
		}
	end
end

function ORM.effect.add_backstab(backstab_modifier)
	return function()
		local adaptive_multiplier = V.ORM_difficulty_setting
		if backstab_modifier < 0 then adaptive_multiplier = 1 end
		local backstab_modifier = backstab_modifier*adaptive_multiplier
		return T.effect{
			apply_to = "attack",
			T.set_specials({
				mode="append",
				T.damage({
					id="backstab",
					name="backstab "..tostring(backstab_modifier),
					description="When used offensively, this attack deals multiplied damage if there is an enemy of the target on the opposite side of the target, and that unit is not incapacitated (turned to stone or otherwise paralyzed).. Multiplier: "..tostring(backstab_modifier),
					multiply=backstab_modifier,
					backstab="yes",
					active_on="offense"
				})
			})
		}
	end
end

function ORM.effect.add_status(status)
	return function()
		return T.effect{
			apply_to="status",
			add=status
		}
	end
end
-->>
