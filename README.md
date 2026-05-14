# Cable Wakeboard

A small Godot 4 prototype for a cable wakeboarding game.

The rider follows a full-size cable park path, the camera uses a third-person chase view and the current prototype supports jumping, simple trick inputs, obstacle interactions, scoring and crash resets.

## Project

- Engine: Godot 4.6
- Main scene: `main.tscn`
- Main path logic: `cable_path.gd`
- Rider controls and tricks: `rider.gd`
- Camera follow logic: `camera_3d.gd`
- UI score and trick display: `ui.gd`

## How To Run

1. Open Godot.
2. Import this folder as a project.
3. Open `main.tscn`.
4. Press Run.

## Controls

- `Space`: jump
- `Left Arrow`: heelside 180 while jumping
- `Right Arrow`: toeside 180 while jumping
- `Up Arrow`: backroll while jumping
- `Down Arrow`: front roll while jumping

On touch screens, tap to jump and swipe to trigger a trick.

## Current State

This is an early prototype. The core loop is simple:

1. The rider loops around the cable path.
2. The player jumps.
3. The player performs a trick before landing.
4. The score increases if a trick is completed.
5. Kickers launch the rider, while boxes and rails reward low airborne timing.
6. The score resets if the rider misses timing or lands without a trick.

## Next Ideas

- Add proper wakeboarder and obstacle visuals.
- Tune jump timing and trick scoring.
- Add sound, water feedback and stronger camera polish.
- Add mobile UI prompts for touch controls.
