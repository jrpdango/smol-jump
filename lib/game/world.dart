import 'dart:math';

import 'package:flame/components.dart';

import '../components/bird.dart';
import '../components/celestial_body.dart';
import '../components/cloud.dart';
import '../components/dino.dart';
import '../components/ground.dart';
import '../components/obstacle.dart';
import '../components/scrolling_layer.dart';
import '../components/sky.dart';
import '../components/star.dart';
import '../managers/bird_spawner.dart';
import '../managers/day_night_cycle.dart';
import '../managers/obstacle_spawner.dart';
import 'erls_dino_game.dart';

/// The fixed virtual play field (180 x 320, 9:16 portrait).
///
/// All gameplay coordinates are expressed in these virtual pixels; the camera
/// applies an integer zoom so every virtual pixel maps to whole screen pixels.
class ErlsDinoWorld extends World
    with HasCollisionDetection, HasGameReference<ErlsDinoGame> {
  static const double virtualWidth = 180;
  static const double virtualHeight = 320;
  static const double groundHeight = 12;

  /// Y coordinate of the top of the ground / bottom of everything standing.
  static const double groundY = virtualHeight - groundHeight;

  /// The ground/scene strip is drawn wider than the 180 virtual field so it
  /// still covers the screen when integer zoom leaves visible area outside the
  /// 9:16 field. `virtualWidth * 2` is the upper bound of the visible world
  /// width for any integer zoom >= 1.
  static const double groundWidth = virtualWidth * 2;
  static const double groundLeft = virtualWidth / 2 - groundWidth / 2;
  static const double groundRight = groundLeft + groundWidth;

  /// Fixed horizontal position (bottom-center) of the dino.
  static const double dinoX = 40;

  static const double baseSpeed = 120;
  static const double maxSpeed = 230;

  /// Time to ease from [baseSpeed] to [maxSpeed]. The curve starts and ends
  /// with zero slope so the acceleration never feels abrupt.
  static const double speedRampSeconds = 60;

  /// Two cloud layers scroll at a fraction of the ground speed. The far layer
  /// is smaller, paler and slower; the near layer is larger and faster.
  static const List<String> farCloudAssets = [
    'cloud-far-01.png',
    'cloud-far-02.png',
  ];
  static const List<String> nearCloudAssets = [
    'cloud-near-01.png',
    'cloud-near-02.png',
  ];
  static const double farCloudSpeed = 0.15;
  static const double nearCloudSpeed = 0.30;
  static const double farCloudMinY = 14;
  static const double farCloudMaxY = 66;
  static const double nearCloudMinY = 26;
  static const double nearCloudMaxY = 100;
  static final Vector2 farCloudSize = Vector2(30, 10);
  static final Vector2 nearCloudSize = Vector2(46, 14);

  static const int farCloudCount = 5;
  static const int nearCloudCount = 4;

  /// Background landscape layers. Speeds are fractions of the ground speed.
  static const String hillsFarAsset = 'hills-far-01.png';
  static const String hillsNearAsset = 'hills-near-01.png';
  static const double hillsFarSpeed = 0.06;
  static const double hillsNearSpeed = 0.10;
  static const double hillsFarHeight = 56;
  static const double hillsNearHeight = 40;

  /// Celestial bodies and the star field. Sun/moon positions are world-space
  /// (the camera is static) and their opacity is driven by the day/night cycle.
  static const String sunAsset = 'sun.png';
  static const String moonAsset = 'moon.png';
  static const String starSmallAsset = 'star-01.png';
  static const String starLargeAsset = 'star-02.png';
  static const double sunSize = 28;
  static const double moonSize = 24;
  static const int starCount = 18;
  static const double starMinY = 8;
  static const double starMaxY = 130;

  /// Time for one full day/night cycle. Longer = slower, subtler shifts.
  static const double dayNightCycleSeconds = 120;

  /// Eased scroll speed at [elapsed] seconds into a run.
  static double speedAt(double elapsed) {
    final p = (elapsed / speedRampSeconds).clamp(0.0, 1.0);
    final eased = p * p * (3 - 2 * p);
    return baseSpeed + (maxSpeed - baseSpeed) * eased;
  }

  late final Sky sky = Sky();
  late final Dino dino = Dino();
  late final Ground ground = Ground();
  late final ObstacleSpawner spawner = ObstacleSpawner();
  late final BirdSpawner birdSpawner = BirdSpawner();

  late final ScrollingLayer hillsFar = ScrollingLayer(
    asset: hillsFarAsset,
    position: Vector2(groundLeft, groundY - hillsFarHeight),
    size: Vector2(groundWidth, hillsFarHeight),
    speedMultiplier: hillsFarSpeed,
    priority: -8,
  );
  late final ScrollingLayer hillsNear = ScrollingLayer(
    asset: hillsNearAsset,
    position: Vector2(groundLeft, groundY - hillsNearHeight),
    size: Vector2(groundWidth, hillsNearHeight),
    speedMultiplier: hillsNearSpeed,
    priority: -6,
  );
  late final CelestialBody sun = CelestialBody(
    asset: sunAsset,
    position: Vector2(120, 56),
    size: Vector2.all(sunSize),
    priority: -9,
  );
  late final CelestialBody moon = CelestialBody(
    asset: moonAsset,
    position: Vector2(48, 52),
    size: Vector2.all(moonSize),
    priority: -9,
  );

  final List<Cloud> _clouds = [];
  final List<Star> _stars = [];
  final Random _random = Random();

  final DayNightCycle _cycle =
      const DayNightCycle(cycleSeconds: dayNightCycleSeconds);

  // Last applied values, so unchanged frames skip redundant work.
  int _lastTint = -1;
  double _lastSun = -1;
  double _lastMoon = -1;
  double _lastNight = -1;

  double speed = baseSpeed;
  double elapsed = 0;

  @override
  Future<void> onLoad() async {
    await add(sky);
    await add(sun);
    await add(moon);
    await _addStars();
    await add(hillsFar);
    await add(hillsNear);
    await _addCloudLayer(
      assets: farCloudAssets,
      size: farCloudSize,
      speedMultiplier: farCloudSpeed,
      minY: farCloudMinY,
      maxY: farCloudMaxY,
      count: farCloudCount,
    );
    await _addCloudLayer(
      assets: nearCloudAssets,
      size: nearCloudSize,
      speedMultiplier: nearCloudSpeed,
      minY: nearCloudMinY,
      maxY: nearCloudMaxY,
      count: nearCloudCount,
    );
    await add(ground);
    await add(dino);
    await add(spawner);
    await add(birdSpawner);
    _applyDayNight(_cycle.stateAt(0));
  }

  /// Scatters the star field across the upper sky.
  Future<void> _addStars() async {
    for (var i = 0; i < starCount; i++) {
      final large = _random.nextBool();
      final star = Star(
        asset: large ? starLargeAsset : starSmallAsset,
        size: Vector2.all(large ? 5 : 3),
        phase: _random.nextDouble() * pi * 2,
        priority: -9,
        position: Vector2(
          (groundLeft + _random.nextDouble() * groundWidth).roundToDouble(),
          (starMinY + _random.nextDouble() * (starMaxY - starMinY))
              .roundToDouble(),
        ),
      );
      _stars.add(star);
      await add(star);
    }
  }

  /// Pushes a [DayNightState] to the sky, every tintable sprite and the
  /// celestial bodies. Redundant work is skipped by comparing against the last
  /// applied values, since the cycle interpolates every frame.
  void _applyDayNight(DayNightState state) {
    sky.applyPalette(
      top: state.skyTop,
      mid: state.skyMid,
      horizon: state.skyHorizon,
    );

    final tint = state.sceneTint;
    if (tint.toARGB32() != _lastTint) {
      _lastTint = tint.toARGB32();
      ground.applyTint(tint);
      hillsFar.applyTint(tint);
      hillsNear.applyTint(tint);
      for (final cloud in _clouds) {
        cloud.applyTint(tint);
      }
      dino.applyTint(tint);
    }
    // Obstacles and birds spawn mid-cycle, so tint them every frame.
    for (final obstacle in children.whereType<Obstacle>()) {
      obstacle.applyTint(tint);
    }
    for (final bird in children.whereType<Bird>()) {
      bird.applyTint(tint);
    }

    if (state.sunIntensity != _lastSun) {
      _lastSun = state.sunIntensity;
      sun.setIntensity(state.sunIntensity);
    }
    if (state.moonIntensity != _lastMoon) {
      _lastMoon = state.moonIntensity;
      moon.setIntensity(state.moonIntensity);
    }
    if (state.nightIntensity != _lastNight) {
      _lastNight = state.nightIntensity;
      for (final star in _stars) {
        star.setNight(state.nightIntensity);
      }
    }
  }

  /// Adds [count] clouds of one layer, pre-scattered across the scene so the
  /// sky is populated from the first frame.
  Future<void> _addCloudLayer({
    required List<String> assets,
    required Vector2 size,
    required double speedMultiplier,
    required double minY,
    required double maxY,
    required int count,
  }) async {
    final spacing = groundWidth / count;
    for (var i = 0; i < count; i++) {
      final jitter = _random.nextDouble() * spacing * 0.6;
      final cloud = Cloud(
        assets: assets,
        size: size,
        speedMultiplier: speedMultiplier,
        minY: minY,
        maxY: maxY,
        random: _random,
        position: Vector2(
          (groundLeft + spacing * i + jitter).roundToDouble(),
          (minY + _random.nextDouble() * (maxY - minY)).roundToDouble(),
        ),
      );
      _clouds.add(cloud);
      await add(cloud);
    }
  }

  @override
  void update(double dt) {
    final running = game.isRunning && !game.isGameOver;
    if (running) {
      elapsed += dt;
      speed = speedAt(elapsed);
    } else {
      speed = baseSpeed;
    }
    // Drive every parallax layer from the same speed in a given frame.
    final scrollSpeed = running ? speed : 0.0;
    ground.scroll(scrollSpeed, dt);
    hillsFar.scroll(scrollSpeed, dt);
    hillsNear.scroll(scrollSpeed, dt);
    if (running) {
      _applyDayNight(_cycle.stateAt(_cycle.phaseAt(elapsed)));
    }
    super.update(dt);
  }

  void reset() {
    for (final obstacle in children.whereType<Obstacle>().toList()) {
      obstacle.removeFromParent();
    }
    for (final bird in children.whereType<Bird>().toList()) {
      bird.removeFromParent();
    }
    speed = baseSpeed;
    elapsed = 0;
    for (final cloud in _clouds) {
      cloud.randomizePosition();
    }
    ground.resetScroll();
    hillsFar.resetScroll();
    hillsNear.resetScroll();
    spawner.reset();
    birdSpawner.reset();
    dino.reset();
    _lastTint = -1;
    _lastSun = -1;
    _lastMoon = -1;
    _lastNight = -1;
    _applyDayNight(_cycle.stateAt(0));
  }
}
