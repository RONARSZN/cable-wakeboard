# Cable Wakeboard

A small Godot 4 prototype for a cable wakeboarding game.

The rider follows a stretched full-size cable park path, the camera uses a third-person chase view and the current prototype supports jumping, simple trick inputs, obstacle interactions, scoring and crash resets.

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
- Hold `A`: edge left toward an obstacle lane
- Hold `D`: edge right toward an obstacle lane
- Hold `Left Arrow`: heelside spin while jumping
- Hold `Right Arrow`: toeside spin while jumping
- Hold `Up Arrow`: backroll while jumping
- Hold `Down Arrow`: front roll while jumping

Left and right spin keys use hold duration. Release early around 90 degrees to turn the board sideways while airborne or on obstacles. Release after enough rotation for a 180, or keep holding for a full 360. Spin and flip keys must be held long enough. Only 180 and 360 spins score. Landing sideways on water crashes.

On touch screens, tap to jump and swipe to trigger a trick.

## Current State

This is an early prototype. The core loop is simple:

1. The rider loops around the cable path.
2. The player jumps.
3. The player chooses whether to edge toward an obstacle lane.
4. The player performs a trick before landing.
5. The score increases if a trick is completed.
6. Kickers launch the rider, while boxes and rails reward low airborne timing.
7. Boxes and rails briefly carry the rider when the approach and timing connect.
8. The score resets if the rider misses timing or lands without a trick.

## Next Ideas

- Add proper wakeboarder and obstacle visuals.
- Tune jump timing and trick scoring.
- Add sound, water feedback and stronger camera polish.
- Add mobile UI prompts for touch controls.
