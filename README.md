# CityZoomer

should probably rename since this is no longer a port of cz lol

fat based competitive team based shooter

whenever you start a singleplayer game, it's actually a local server, and then
you can just have other people connect to ur singleplayer game

there are two modes, serverclient and remoteclient. the serverclient keeps track
of all the remoteclients and sends them data

Network iterates through every NetworkBehaviour node every network tick, sending
data that isn't empty and passing recieved data to the corresponding node. when
sending, the Network automatically bundles the sender's nodepath so that the
reciever can pass it to the corresponding node on their end.

```
Network.start_serverclient()
Network.start_remoteclient(ip, port)
Network.stop()

must be added to group NetworkBehaviour for these methods to be called by Network:

serverclient_send(remoteclient_id: int) -> String
serverclient_recieve(remoteclient_id: int, data: String) -> void

remoteclient_send() -> String
remoteclient_recieve(data: String) -> void
```

sky https://godotengine.org/asset-library/asset/579

[sky](https://github.com/rpgwhitelock/AllSkyFree_Godot)

[mountains in sky](https://www.blenderkit.com/asset-gallery-detail/550191ed-cfe4-450e-9a20-7a4f8b00afcb/)

## Misc TODO
- sandbox gamemode
- mercenary has hand bones that are used as the "tip"; their basis matches the target so that they properly hold the rifle
- Main menu/bento mode select (additionally: can look at character, customize stuff, level editor, whatever)
- customization menu next to paper doll
- Inventory system with arbitrary items (could spawn on infinite levels to spice up gameplay as you go on, or be cool for multiplayer gamemodes. weapons, movement tech, etc)

## Infinite Run TODO
- Car obstacles (they're hovercars; once reaching the end of a road, they simply follow it down).
- Pause menu with settings.
  - Toggle for autojump.
- Shooting.
- Enemy turret things that pew pew at you.
- Movement tech.
  - Median bouncing.
  - Jump pads (does subtle camera shake like TF2 Pyro jetpack https://www.youtube.com/watch?v=kRC124bQsGI).
  - Rocket jumping? Handheld spring? Contact-grenade launcher?
- If you're in the air for more than a second, an airtime counter will appear like a score counter in a skating game.

- Passing a checkpoint does the FOV zoom in then slowly back to normal effect, but subtle (should likely be toggleable).
  - Also makes the music immediately pitch down before slowly going back to normal (same as FOV effect)

## Done!
- Bhopping.
- Arrow pointing to next checkpoint.
- Checkpoints look like they did in CZ (big cylinders) but kinda fade out to the top, maybe oscillating like a flame. Also they have particles.
- GUI arrow pointing to the next checkpoint.
- Death barrier has cool glitchy shader.
- T-inspired wolf furry low poly model with INCORPERATED animations/textures/materials and hand IK. they're a fully rigged and animated mercenary with IK hands. also boobs cuz people love those.
- Holding a gun/items (see: inventory system plans)
- Legs.
- paper doll on the title screen
