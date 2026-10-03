import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    this.highScore = 0,
    this.onRestart,
  });

  final int score;
  final int highScore;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRestart,
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              Text(
                'Score: $score   Best: $highScore',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
