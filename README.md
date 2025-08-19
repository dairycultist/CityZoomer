# CityZoomer

Rougelike first-person extraction shooter with tight movement, and bhopping, gunplay, and boobs. the end goal to be a "save the princess" type deal, but the princess is stacked, so the goal is really to touch the maiden's boobs

gameplay loop: enter a level, quickly get money, extract (before enemies get too powerful), visit the shop, upgrade, repeat

[music](https://www.beepbox.co/#9n41sbk0l04e0jt2wa7g0nj0fr1i0o2424T7v1u07f50p61770q72d42g3q0F21590h961d06HT-SRJJJJIAAAAAh0I7E1c11T1v2u01f22v12x0qwF10r5151d08A9F4B0Q19e4Pb631E3b7626637T8v2u08f117bq00d03x600W7E3121218T1v1u01f10o5q83333d30AbFhB2Q2ae1Pa514E172T2v2u15f10w4qw02d03w0E0b4cgN34gEyCa8FyyasgN30000y2o00060E1AaoW4G4cgN34gEyCa8FyyasgN3000000000000000008wy4cgN34ggN34cgN34ggN3p27aFE-1HMkzknOxvgnWiq_zaFHGOIDbM2BfvxpS6Vjjr0VKtAVdeZT8k6nhgptuTy6jNhllnjjnnnnjj0g5Y1w6hw5dc30lgsxp1g6G0Yxgpt51BTXe8p80FJv4iqDnqe00CRZanFE-V1dB_pllllddJI1bY2AaX4R-bbQ77UOrzO2-nFILlGKKjnUYLjhX58W1Bll9JTEFDB-4tCzj8OlYDv9FKDQpVuCzNU3hKFKHB81dvw9Jv0Q2W00FE-1HMkzknOxvgnWiq_zaFHGOIDbM2BfvxpS6Vjjr0VKtAVdeZT8k6nhgptuTy6jNhllnjjnnnnjj0g5Y1w6hw5dc30lgsxp1g6G0Yxgpt51BTXe8p80BWqfEOW3bEcK4w9vgpt1BQ6naM001jppMzF8WieAzGhhjMjnAFEOkBVeNIVejjAq56jIX6PAVdapiqcDgEcKywOWtD9EE00)

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
- greybox level rooms
- implement looting system
- implement hand UI (hand model, IK, gun animation)
- implement gunplay
- implement pathfinding generation for rooms
- implement enemies
- main menu
- finalize gameloop (loot, shop, repeat)
- make more final assets like the level rooms, enemies, items, weapons
