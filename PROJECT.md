# erls_dino — Build Spec

Reference doc for the build session. Recreates the Chrome offline dinosaur
("T-Rex runner") game with custom sprites, using Flame on Flutter, targeting
Android phones.

## Locked decisions
- Engine: Flame (Flutter) — Android only for now.
- Orientation: portrait.
- Art style: pixel art.
- Base virtual grid: 180 x 320 (9:16 portrait).
- Source art authored at 6x the base grid (180 x 6 = 1080 -> matches the
  physical width of common 1080p phones; integer downscale elsewhere).
- Package/directory name: `erls_dino`.

## Bootstrap
```
flutter create --project-name erls_dino --platforms android --org com.erls erls_dino
cd erls_dino
flutter pub add flame
# optional: flutter pub add flame_audio flame_texturepacker shared_preferences
```
Lock the app to portrait in `AndroidManifest.xml` / `SystemChrome`.

## Sprite spec
Base grid = game/virtual pixels. Source = 6x base for crisp output.

| Sprite        | Base px  | Source px @6x |
|---------------|----------|---------------|
| Dino run      | 48 x 52  | 288 x 312     |
| Dino duck     | 64 x 34  | 384 x 204     |
| Small cactus  | 18 x 38  | 108 x 228     |
| Large cactus  | 26 x 54  | 156 x 324     |
| Pterodactyl   | 48 x 40  | 288 x 240     |
| Cloud         | 46 x 14  | 276 x 84      |
| Ground tile   | 180 x 12 | 1080 x 72     |

Tune dino size after a test render; 48 base px is ~27% of the 180px width.

## Pixel-art rendering rules (non-negotiable for crispness)
- `FilterQuality.none` on every sprite paint.
- Integer zoom only: prefer `zoom = (physicalWidth / 180).floor()` on the
  viewfinder over `CameraComponent.withFixedResolution` (avoids fractional
  scales that shimmer).
- Snap render positions to the base pixel grid (round x/y in `update`).
- 1-2 source px padding between atlas frames, or use `bleed`, to stop bleed.
- Ground is a repeatable tile driven by `ParallaxComponent`, not one big image.
- Use `flame_texturepacker` atlas for the sheet.

## Project structure
```
lib/
  main.dart
  game/
    erls_dino_game.dart      # FlameGame: camera, pixel-perfect zoom, state
    world.dart               # World: ground, spawner, score zone
  components/
    dino.dart                # state machine: idle/run/jump/duck/dead
    cactus.dart
    pterodactyl.dart
    cloud.dart
    ground.dart
  managers/
    obstacle_spawner.dart    # speed ramp + weighted spawn
    score.dart
  ui/
    game_over_overlay.dart
assets/
  images/erls_dino_sprites.png (or .aseprite -> exported sheet)
  images/*.png
  audio/*.ogg                # optional sfx
```

## Gameplay scope
- Dino runs right; obstacles scroll left.
- Input: tap/space = jump; swipe down / hold = duck. Tune for touch.
- Obstacle spawner: weighted cacti (small/large), pterodactyl after N score;
  scroll speed increases over time.
- Collision: `RectangleHitbox` on dino (smaller than sprite for fairness) and
  obstacles; duck uses a shorter hitbox.
- Score: distance-based, integer, shown in HUD (viewport child).
- Game over overlay -> tap to restart; persist high score
  (`shared_preferences`).

## Milestones
1. Scaffold + camera + pixel-perfect setup; render one static dino.
2. Parallax ground + dino idle/run animation.
3. Jump + duck + input handling.
4. Obstacle spawning + collision.
5. Score HUD + game over / restart.
6. Polish: sfx, high score, optional day/night tint.
