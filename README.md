# CityZoomer

Rougelike first-person extraction shooter with tight movement, and bhopping, gunplay, and boobs. the end goal to be a "save the princess" type deal, but the princess is stacked, so the goal is really to touch the maiden's boobs

gameplay loop: enter a level, quickly get money, extract (before enemies get too powerful), visit the shop, upgrade, repeat

[music](https://www.beepbox.co/#9n41sbk0l08e0jt2wa7g0rj0fr1i0o2424T7v1u07f50p61770q72d42g3q0F21590h961d03HT-SRJJJJIAAAAAh0I7E2c1112T1v1u01f22v12x0qwF10r5151d08A9F4B0Q19e4Pb631E3b7626637T8v2u08f117bq00d03x600W7E3121218T1v1u01f10o5q83333d30AbFhB2Q2ae1Pa514E172T2v2u15f10w4qw02d03w0E0b002h34cgN4g8FyyaoEyD4cgRHmJqRH289BHmIo2w6gFzEiE000000134h0yCa8FyyasgN300000000000000000000288w04cgN34ch2z4cgN34ch134cp28jFE-1HMkzknOxvgnWiq_zaFHGOIDbM2BfvxpS6Vjjr0VKtAVdeZT8k6nhgptuTy6jNhllnjjnnnnjj0g5Y1w6hw5dc30lgsxp1g6G0Yxgpt51BTXe8pcLNe0FFBoiKKCC0w820DxqwRR7w0arnN4CFRSzw09JviBWqfKgjpvSlllljjrr0i_0F2KNdvyOZ1N-cCUYwLBWrbRqHHAR-fbQQuNiewpllirtWapVvx7pEQOcBv9TOqrFZ6unFEYu0QrGrGVi0jnU2rnMd0Kwa2_19HPcD9OsD9OgkQv0RUahGbVgLEbZ9dvNBkRRpmjBU1iDLMIX3sFFJwsTeOsCDuXAa3bEEcKLrN39UEGGHFFHHHHFFw82-0M38M2CC1waEegIwE3l0ugEcKywOXZD4cCnUD0kQOI9nnjj0g41004LjhZ6ngpt1BMA1bW3bEcKwOVm000arbe4t97ihQAtiaau2qYBd6iAL9SdD9OqszgEOtDoSsD9FjajhAW51BQk6njIVd54LOsDytzpOsCD800)

should probably rename since this is no longer a port of cz lol

[similar game idea but I won't steal dwdw](https://ln404.itch.io/force-reboot), I should also reference Dusk since I liked that game, the movement and gunplay and enemies were very solid

think about cool graphics later I want GAMEPLAY

## TODO
- model floating arm and boob models (the latter you only see when looking down)
	- ensure arm has hand bones (they should be used as the "tip" for IK; their basis matches the target so that they properly hold the rifle)
 	- player model has boobs and animations built into the file (textures and IK aren't :\<)
- I want a super smash bros brawl style menu with a paper doll of the player
- Inventory system with arbitrary items (including using those items, e.g. shooting)
	- Rocket jumping? Handheld spring? Contact-grenade launcher?
- Toggle for bhop autojump in pause settings

tentative order
- money system (upon collecting loot)
- main menu + returning to main menu upon extraction
- implement hand UI (hand model, IK, gun animation)
- implement pathfinding generation for rooms
- implement enemies
- implement bounty system
- finalize gameloop (loot, shop, repeat)
- make more final assets like the level rooms, enemies, items, weapons
