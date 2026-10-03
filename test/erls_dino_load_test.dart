import 'package:erls_dino/components/dino.dart';
import 'package:erls_dino/components/ground.dart';
import 'package:erls_dino/game/erls_dino_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('game loads its world components without errors', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final game = ErlsDinoGame();
    await tester.runAsync(() async {
      await tester.pumpWidget(GameWidget<ErlsDinoGame>(game: game));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(game.world.dino, isA<Dino>());
    expect(game.world.ground, isA<Ground>());
    expect(game.world.dino.state, DinoState.idle);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));
}
