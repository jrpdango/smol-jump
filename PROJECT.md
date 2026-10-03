# erls_dino — Build Spec

Reference doc for the build session. Recreates the Chrome offline dinosaur
("T-Rex runner") game with custom sprites, using Flame on Flutter, targeting
Android phones.

## Locked decisions
- Engine: Flame (Flutter) — Android only for now.
- Orientation: portrait.
- Art style: pixel art.
- Base virtual grid: 180 x 320 (9:16 portrait).
- Art authored at the base grid in px (1 art px = 1 virtual px); exported 1:1,
  no pre-scaling in the art tool. Flame upscales with an integer zoom, so each
  virtual pixel becomes 6 physical px on 1080p phones (zoom 6), 4 px on 720p
  (zoom 4), etc. Never fractional.
- Package/directory name: `erls_dino`.

## Bootstrap
```
flutter create --project-name erls_dino --platforms android --org com.erls erls_dino
cd erls_dino
flutter pub add flame
# optional: flutter pub add flame_audio shared_preferences
```
Lock the app to portrait in `AndroidManifest.xml` / `SystemChrome`.

## Sprite spec
Base grid = game/virtual pixels. Author and export at these sizes (1:1); the
engine handles upscaling via integer zoom.

| Sprite        | File(s)                              | Base px  |
|---------------|--------------------------------------|----------|
| Dino idle     | `erls-idle.png`                      | 48 x 52  |
| Dino run      | `erls-run-01.png`, `erls-run-02.png` | 48 x 52  |
| Dino jump     | `erls-jump.png`                      | 48 x 52  |
| Garlic        | `garlic.png`                         | 26 x 54  |
| Mint-choco    | `mint-choco.png`                     | 18 x 38  |
| Cloud         | `cloud.png`                          | 46 x 14  |
| Ground tile   | `ground.png`                         | 180 x 12 |

Death sprite is not authored yet; reuse `erls-idle.png` for now.

Do not pre-scale sprite PNGs. Export them at the sizes above and let Flame's
integer zoom do the magnification.

Aseprite workflow: New Sprite at the base size, Pixel-perfect stroke mode on,
Pencil tool, small fixed palette. Export each frame as a separate PNG at 1x (no
Scale step). See "Frame breakdown" below for the animation frames needed.

### Frame breakdown
Each frame uses the base size of its sprite row above.

| Animation       | Frames | Notes                                        |
|-----------------|--------|----------------------------------------------|
| `erls_idle`     | 1      | `erls-idle.png`; also stands in for death    |
| `erls_run`      | 2      | `erls-run-01.png` -> `erls-run-02.png`       |
| `erls_jump`     | 1      | `erls-jump.png`; tucked legs                 |
| `erls_dead`     | 0      | Pending; reuse idle for now                  |
| `garlic`        | 1      | Static obstacle                              |
| `mint-choco`    | 1      | Static obstacle                              |
| `cloud`         | 1      | Static, parallax layer                       |
| `ground`        | 1      | Must tile seamlessly L<>R at 180 base        |

Export each frame as a separate PNG, named so animation frames sort in order,
e.g. `erls-run-01.png`, `erls-run-02.png`.

Tune dino size after a test render; 48 base px is ~27% of the 180px width.

## Pixel-art rendering rules (non-negotiable for crispness)
- `FilterQuality.none` on every sprite paint.
- Integer zoom only: since art is authored 1x, prefer
  `zoom = (physicalWidth / 180).floor()` on the viewfinder over
  `CameraComponent.withFixedResolution` (avoids fractional scales that
  shimmer).
- Snap render positions to the base pixel grid (round x/y in `update`).
- Sprites are separate PNGs (one file per frame); load with `Flame.images.load`
  and reuse the cached instances.
- Ground is a repeatable tile driven by `ParallaxComponent`, not one big image.

## Project structure
```
lib/
  main.dart
  game/
    erls_dino_game.dart      # FlameGame: camera, pixel-perfect zoom, state
    world.dart               # World: ground, spawner, score zone
  components/
    dino.dart                # state machine: idle/run/jump/dead
    garlic.dart
    mint_choco.dart
    cloud.dart
    ground.dart
  managers/
    obstacle_spawner.dart    # speed ramp + weighted spawn
    score.dart
  ui/
    game_over_overlay.dart
assets/
  images/*.png               # one PNG per frame (e.g. erls-run-01.png)
  audio/*.ogg                # optional sfx
```

## Gameplay scope
- Dino runs right; obstacles scroll left.
- Input: tap/space = jump. Tune for touch.
- Obstacle spawner: weighted garlic/mint-choco;
  scroll speed increases over time.
- Collision: `RectangleHitbox` on dino (smaller than sprite for fairness) and
  obstacles.
- Score: distance-based, integer, shown in HUD (viewport child).
- Game over overlay -> tap to restart; persist high score
  (`shared_preferences`).

## Milestones
1. Scaffold + camera + pixel-perfect setup; render one static dino.
2. Parallax ground + dino idle/run animation.
3. Jump + input handling.
4. Obstacle spawning + collision.
5. Score HUD + game over / restart.
6. Polish: sfx, high score, optional day/night tint.
