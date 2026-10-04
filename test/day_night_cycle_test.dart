import 'package:smol_jump/managers/day_night_cycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cycle = DayNightCycle(cycleSeconds: 120);

  group('phaseAt', () {
    test('starts at day and wraps every cycle', () {
      expect(cycle.phaseAt(0), 0);
      expect(cycle.phaseAt(120), 0);
      expect(cycle.phaseAt(30), closeTo(0.25, 1e-9));
      expect(cycle.phaseAt(60), closeTo(0.5, 1e-9));
      expect(cycle.phaseAt(180), closeTo(0.5, 1e-9));
    });
  });

  group('stateAt keyframes', () {
    test('phase 0 is full day', () {
      final s = cycle.stateAt(0);
      expect(s.nightIntensity, 0);
      expect(s.sunIntensity, 1);
      expect(s.moonIntensity, 0);
      expect(s.sceneTint.toARGB32(), 0xFFFFFFFF);
    });

    test('phase 0.5 is full night', () {
      final s = cycle.stateAt(0.5);
      expect(s.nightIntensity, 1);
      expect(s.sunIntensity, 0);
      expect(s.moonIntensity, 1);
    });

    test('dusk and dawn sit between day and night', () {
      final dusk = cycle.stateAt(0.25);
      final dawn = cycle.stateAt(0.75);
      expect(dusk.nightIntensity, greaterThan(0));
      expect(dusk.nightIntensity, lessThan(1));
      expect(dawn.nightIntensity, greaterThan(0));
      expect(dawn.nightIntensity, lessThan(1));
    });
  });

  group('interpolation', () {
    test('midpoint between day and dusk halves the night intensity', () {
      final s = cycle.stateAt(0.125);
      expect(s.nightIntensity, closeTo(0.25, 1e-6));
      expect(s.sunIntensity, closeTo(0.775, 1e-6));
      expect(s.moonIntensity, closeTo(0.175, 1e-6));
    });

    test('wraps smoothly back to day at phase 1', () {
      final s = cycle.stateAt(0.999);
      expect(s.nightIntensity, lessThan(0.01));
      expect(s.sunIntensity, greaterThan(0.99));
    });

    test('intensities stay in range across a whole cycle', () {
      for (var p = 0.0; p < 1.0; p += 0.01) {
        final s = cycle.stateAt(p);
        expect(s.nightIntensity, inInclusiveRange(0, 1));
        expect(s.sunIntensity, inInclusiveRange(0, 1));
        expect(s.moonIntensity, inInclusiveRange(0, 1));
      }
    });
  });
}
