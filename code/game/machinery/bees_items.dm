
/*

> queen bee packet
> bee net
> moveable apiary
> packet of BeezEez
> empty packet of BeezEez
> honeycomb
> The Ins and Outs of Apiculture - A Precise Art

*/

/obj/item/queen_bee
	name = "queen bee packet"
	desc = "Place her into an apiary so she can get busy."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "queen_larvae"
	w_class = W_CLASS_TINY

/obj/item/weapon/bee_net
	name = "bee net"
	desc = "For catching rogue bees."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_net"
	item_state = "bee_net"
	w_class = W_CLASS_MEDIUM
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/beekeeping.dmi', "right_hand" = 'icons/mob/in-hand/right/beekeeping.dmi')
	var/list/caught_bees = list()

/obj/item/weapon/bee_net/examine(mob/user)
	..()
	if(caught_bees)
		to_chat(user, "<span class='info'>There's [caught_bees] caught bee\s in it!</span>")
	else
		to_chat(user, "<span class='info'>It has no bees in it.</span>")

/obj/item/weapon/bee_net/afterattack(atom/A as mob|obj|turf|area, mob/living/user)
	if(get_dist(A,user) > 1)
		return
	if(istype(A,/obj/machinery/apiary))
		return
	var/turf/T = get_turf(A)
	var/caught = 0
	for(var/mob/living/simple_animal/bee/B in T)
		caught = 1
		if(B.calmed > 0 || (B.state != BEE_OUT_FOR_ENEMIES))
			if (prob(max(0,100-B.bees.len*5)))
				for (var/datum/bee/BEES in B.bees)
					caught_bees.Add(BEES)
					BEES.home = null
					if (B.home)
						B.home.bees_outside_hive.Remove(BEES)
				qdel(B)
				B = null
				user.visible_message("<span class='notice'>[user] nets some bees.</span>","<span class='notice'>You net up some of the bees.</span>")
			else
				user.visible_message("<span class='warning'>[user] swings at some bees, they don't seem to like it.</span>","<span class='warning'>You swing at some bees, they don't seem to like it.</span>")
				B.state = BEE_OUT_FOR_ENEMIES
				B.target = user
		else
			user.visible_message("<span class='warning'>[user] swings at some bees, they don't seem to like it.</span>","<span class='warning'>The bees are too angry to let themselves get caught.</span>")
			B.state = BEE_OUT_FOR_ENEMIES
			B.target = user
	if(!caught)
		to_chat(user, "<span class='warning'>There are no bees in front of you!</span>")

/obj/item/weapon/bee_net/attack_self(mob/user as mob)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/caught = 0
	for(var/mob/living/simple_animal/bee/B in T)
		caught = 1
		if(B.calmed > 0)
			caught_bees += B.bees.len
			qdel(B)
			B = null
			user.visible_message("<span class='notice'>[user] nets some bees.</span>","<span class='notice'>You net up some of the becalmed bees.</span>")
		else
			user.visible_message("<span class='warning'>[user] swings at some bees, they don't seem to like it.</span>","<span class='warning'>You swing at some bees, they don't seem to like it.</span>")
			B.state = BEE_OUT_FOR_ENEMIES
			B.target = user
	if(!caught)
		to_chat(user, "<span class='warning'>There are no bees in front of you!</span>")

/obj/item/weapon/bee_net/verb/empty_bees()
	set src in usr
	set name = "Empty bee net"
	set category = "Object"
	var/mob/living/carbon/M
	if(iscarbon(usr))
		M = usr

	while(caught_bees.len > 0)
		//release a few super massive swarms
		while(caught_bees.len > 5)
			var/mob/living/simple_animal/bee/B = new(src.loc)
			for (var/i = 1 to 5)
				var/datum/bee/BEE = pick(caught_bees)
				caught_bees -= BEE
				BEE.state = BEE_OUT_FOR_ENEMIES
				B.addBee(BEE)
			B.target = M


		//what's left over
		var/mob/living/simple_animal/bee/B = new(src.loc)
		for (var/i = 1 to caught_bees.len)
			var/datum/bee/BEE = pick(caught_bees)
			caught_bees -= BEE
			BEE.state = BEE_OUT_FOR_ENEMIES
			B.addBee(BEE)
		B.target = M

		caught_bees = 0

/obj/item/apiary
	name = "moveable apiary"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary_item"
	item_state = "giftbag"
	w_class = W_CLASS_HUGE


/obj/item/weapon/reagent_containers/food/snacks/beezeez
	name = "packet of BeezEez"
	desc = "Delicious nutrients for domesticated bees. Helps jumpstarting a new colony, and purging an existing one from toxins."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "beezeez"
	trash = /obj/item/trash/beezeez
	volume = 3

/obj/item/weapon/reagent_containers/food/snacks/beezeez/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	bitesize = 1


/obj/item/trash/beezeez
	name = "empty packet of BeezEez"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "beezeez-empty"


/obj/item/weapon/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	icon_state = "honeycomb"
	desc = "Dripping with sugary sweetness. Grind it to separate the honey."

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/New()
	. = ..()
	reagents.add_reagent(HONEY,10)
	reagents.add_reagent(NUTRIMENT, 0.5)
	reagents.add_reagent(SUGAR, 2)
	bitesize = 2

/obj/item/weapon/book/manual/hydroponics_beekeeping
	name = "The Ins and Outs of Apiculture - A Precise Art"
	icon_state ="bookHydroponicsBees"
	author = "Beekeeper Dave"
	title = "The Ins and Outs of Apiculture - A Precise Art"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Raising Bees</h3>

				Bees are loving but fickle creatures. Don't mess with their hive and stay away from any clusters of them, and you'll avoid their ire.
				Sometimes, you'll need to dig around in there for those delicious sweeties though - in that case make sure you wear sealed protection gear
				and carry an extinguisher or smoker with you - any bees chasing you, once calmed down, can thusly be netted and returned safely to the hive.
				Beezeez is a cure-all panacea for them, use it on an apiary to kickstart it, but use it too much and the hive may grow to apocalyptic proportions.
				Other than that, bees are excellent pets for all the family and are excellent caretakers of one's garden:
				having a hive or two around will aid in the longevity and growth rate of plants, and aid them in fighting off poisons and disease.

				<h3>Dealing with Feral Bees</h3>

				If someone attacks the hive or some of the bees, you can bet that they won't like it and retaliate with murderous intent.
				To fix such a situation, you will have to capture the bees and place them back into their apiary. Doing so is a two step process.
				But before that, you'll want to acquire yourself a Bio suit to protect yourself from stings.
				First you need to spray the bees with water. Chemistry sprays, fire extinguishers, smoke grenades, anything works as long as it has some water in it.
				Once the bees are calmed, swing your bee net at them. If the bees aren't calmed first, you will only angry them further!
				It is strongly disadvised to empty your bee net anywhere beside in the apiary, you might have to deal with an even more ferocious outbreak if you empty your net
				outside after having caught them all.

				<h3>Collecting Honeycombs</h3>

				Collecting honeycombs is a relatively simple process, but you'll need to make some preparations, such as getting a Bio suit or prepairing another apiary where to move the bees.
				First you start by deconstructing the apiary with a hatchet. The bees will become aggressive as soon as you begin. Once the apiary is deconstructed, follow the steps in the above
				section to capture the homeless feral bees and move them to another apiary. Or simply rebuild the apiary that you just deconstructed. The honeycombs harvested this way
				are full of honey, you can grind them to process the liquid, then place it in a Condimaster to conserve it in a honey pot. Or you can just eat the honeycombs if you feel like it,
				they are delicious.


				</body>
				</html>
				"}
