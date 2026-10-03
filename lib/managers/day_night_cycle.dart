import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// Interpolated appearance of the whole scene at a point in the day/night
/// cycle.
class DayNightState {
  const DayNightState({
    required this.skyTop,
    required this.skyMid,
    required this.skyHorizon,
    required this.sceneTint,
    required this.nightIntensity,
    required this.sunIntensity,
    required this.moonIntensity,
  });

  final Color skyTop;
  final Color skyMid;
  final Color skyHorizon;

  /// Multiplied over every sprite/layer. White leaves colors unchanged.
  final Color sceneTint;

  /// `0` = day, `1` = night. Drives the star field.
  final double nightIntensity;

  final double sunIntensity;
  final double moonIntensity;

  static DayNightState lerp(DayNightState a, DayNightState b, double t) {
    return DayNightState(
      skyTop: Color.lerp(a.skyTop, b.skyTop, t)!,
      skyMid: Color.lerp(a.skyMid, b.skyMid, t)!,
      skyHorizon: Color.lerp(a.skyHorizon, b.skyHorizon, t)!,
      sceneTint: Color.lerp(a.sceneTint, b.sceneTint, t)!,
      nightIntensity: lerpDouble(a.nightIntensity, b.nightIntensity, t)!,
      sunIntensity: lerpDouble(a.sunIntensity, b.sunIntensity, t)!,
      moonIntensity: lerpDouble(a.moonIntensity, b.moonIntensity, t)!,
    );
  }
}

/// A looping day -> dusk -> night -> dawn cycle, driven by run time. Phase `0`
/// is full day, so a fresh run always starts bright.
class DayNightCycle {
  const DayNightCycle({this.cycleSeconds = 120});

  /// Time for one full day. Longer = slower, subtler shifts.
  final double cycleSeconds;

  /// Keyframes at phases 0, 0.25, 0.5 and 0.75.
  static const List<DayNightState> _keyframes = [
    // Day
    DayNightState(
      skyTop: Color(0xFF56A9D4),
      skyMid: Color(0xFF9BD3EC),
      skyHorizon: Color(0xFFF7E4B8),
      sceneTint: Color(0xFFFFFFFF),
      nightIntensity: 0,
      sunIntensity: 1,
      moonIntensity: 0,
    ),
    // Dusk
    DayNightState(
      skyTop: Color(0xFF3A4F94),
      skyMid: Color(0xFFC97BA0),
      skyHorizon: Color(0xFFF2A65A),
      sceneTint: Color(0xFFFFD8B0),
      nightIntensity: 0.5,
      sunIntensity: 0.55,
      moonIntensity: 0.35,
    ),
    // Night
    DayNightState(
      skyTop: Color(0xFF0B1230),
      skyMid: Color(0xFF17204A),
      skyHorizon: Color(0xFF2A3566),
      sceneTint: Color(0xFFA8B4DE),
      nightIntensity: 1,
      sunIntensity: 0,
      moonIntensity: 1,
    ),
    // Dawn
    DayNightState(
      skyTop: Color(0xFF3F5AA0),
      skyMid: Color(0xFFB98FB0),
      skyHorizon: Color(0xFFF2C078),
      sceneTint: Color(0xFFFFE2C4),
      nightIntensity: 0.4,
      sunIntensity: 0.5,
      moonIntensity: 0.25,
    ),
  ];

  /// Normalized phase for [elapsed] seconds into a run.
  double phaseAt(double elapsed) {
    if (cycleSeconds <= 0) {
      return 0;
    }
    return (elapsed / cycleSeconds) % 1.0;
  }

  /// Appearance at [phase] (wraps), interpolated between the keyframes.
  DayNightState stateAt(double phase) {
    final p = phase % 1.0;
    final scaled = p * _keyframes.length;
    final i = scaled.floor();
    final t = scaled - i;
    final a = _keyframes[i % _keyframes.length];
    final b = _keyframes[(i + 1) % _keyframes.length];
    return DayNightState.lerp(a, b, t);
  }
}
