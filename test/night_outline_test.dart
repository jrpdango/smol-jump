import 'package:erls_dino/components/dino.dart';
import 'package:erls_dino/components/night_outline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('opacityForNight', () {
    test('is off at day and capped below full at night', () {
      expect(NightOutline.opacityForNight(0), 0);
      expect(NightOutline.opacityForNight(1), NightOutline.maxOpacity);
      expect(NightOutline.maxOpacity, lessThan(0.5));
    });

    test('stays subtle through dusk and ramps up at deep night', () {
      expect(NightOutline.opacityForNight(0.5), lessThan(0.15));
      expect(
        NightOutline.opacityForNight(1),
        greaterThan(NightOutline.opacityForNight(0.5)),
      );
    });

    test('is monotonic and clamped across the whole cycle', () {
      var previous = -1.0;
      for (var n = 0.0; n <= 1.0; n += 0.05) {
        final o = NightOutline.opacityForNight(n);
        expect(o, inInclusiveRange(0, NightOutline.maxOpacity));
        expect(o, greaterThanOrEqualTo(previous));
        previous = o;
      }
      expect(NightOutline.opacityForNight(-1), 0);
      expect(NightOutline.opacityForNight(2), NightOutline.maxOpacity);
    });
  });

  group('setOutlineIntensity', () {
    test('defaults to hidden and clamps out-of-range values', () {
      final dino = Dino();
      expect(dino.outlineIntensity, 0);

      dino.setOutlineIntensity(2);
      expect(dino.outlineIntensity, 1);

      dino.setOutlineIntensity(-1);
      expect(dino.outlineIntensity, 0);

      dino.setOutlineIntensity(0.4);
      expect(dino.outlineIntensity, closeTo(0.4, 1e-9));
    });
  });
}
