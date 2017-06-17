Notes
---

# A. General description

Asteroids is a game where the player embodies a spaceship that must protect itself against and destroy incoming asteroids.

---
# B. Game modes

## 1. Classic

- Level-based.
- The player has to destroy all the asteroids to get to the next level (cool animation and/or sfx at the end of a level).
- Destroying asteroids yields points.
- Levels are progressively more difficult (e.g. more and faster asteroids).

Elements of gameplay that can appear as difficulty grows:

- comet : faster but worth more points - one per level - they come back periodically (but typically once in a typical gametime) - make it golden ? at least shiny.
- asteroid belt : a concentrated and limited time stream of high speed, small asteroids (meteoroids?) that span through the screen - deadly because of the number of asteroids - signal alert before appearing.
- enemy spacecrafts that can shoot at the player :
	- drifting enemies : rotating and translating in steady state - shoot at the player if in their sight
	- miners : they move around randomly and leave EM mines that freeze the spaceship (not moving, no weapons) for a limited time - fx when that happens
	- turrets : non-moving, shoot guided missiles at the player
	- crawlers : intelligent enemies, slowly follow the player's spaceship and shoot at them

## 2. Time runner

- Continuous flow of asteroids.
- Limited time (e.g. 1 min).
- The player has to destroy the most asteroids they can **without dying**.
- OR without getting hit at all - extra difficulty.
- Each asteroid is worth points and the player wants to get the highest score.
- There could be several modes : 30s, 1min, 5min.

---
# C. Graphical items

## 1. Powerups

Player can pick up powerups. Three kinds of powerups :

- attack : weapon enhancement
- defense : shields
- health : fill life bar, supplementary life

### 1.a. Attack powerups

Represented in a hot color (red-ish).

- 3 or 5 lasers - lasts 5s
- Full beam - narrow, continuous beam that destroys every asteroid in its direction (short 1s or long 3s)
- Mines - can be deposited and explode a few moments after - destroy nearby asteroids

### 1.b. Defense powerups

Represented in a cold tone (blue-ish).

- Front shield (5s)
- Full shield (5s)

### 1.c. Health powerups

Represented in a green-ish tone.

- filler : refills the life bar of the player
- 1 extra life

