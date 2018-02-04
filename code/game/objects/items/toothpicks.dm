/datum/action/item_action/chew_toothpick
	name = "Chew toothpick"

/datum/action/item_action/chew_toothpick/Trigger()

	var/obj/item/clothing/mask/toothpick/toothpick = target
	var/mob/living/carbon/human/H = toothpick.loc
	if(istype(H) && H.wear_mask == toothpick)
		toothpick.handle_reagents()
		H.visible_message("<span class='notice'>[H] chews on a [toothpick.name].</span>")
		toothpick.chew_limit--
		if(!toothpick.chew_limit)
			to_chat(H, "<span class='warn'>You chewed your [toothpick.name] to nothing.</span>")
			qdel(toothpick)

/obj/item/clothing/mask/toothpick
	name = "toothpick"
	desc = "A wooden toothpick."
	icon_state = "toothpick"
	item_state = "toothpick"
	container_type = REFILLABLE
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	actions_types = list(/datum/action/item_action/chew_toothpick)
	force = 2
	var/chem_volume = 15
	var/chew_chem_volume = 3
	var/chew_limit = 30

/obj/item/clothing/mask/toothpick/Initialize()
	. = ..()
	create_reagents(chem_volume)

/obj/item/clothing/mask/toothpick/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)
	if(istype(glass))	//you can dip toothpicks into beakers
		if(glass.reagents.trans_to(src, chem_volume - reagents.total_volume))	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the toothpick was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")
	else
		. = ..()

/obj/item/clothing/mask/toothpick/proc/handle_reagents()
	if(reagents.total_volume)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.reaction(C, INGEST)
				if(!reagents.trans_to(C, chew_chem_volume))
					reagents.remove_any(chew_chem_volume)
				return
		reagents.remove_any(chew_chem_volume)
