import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// The screen shown before a run begins: title, Play button and best score.
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({
    super.key,
    required this.highScore,
    required this.onPlay,
  });

  final int highScore;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: UiTheme.scrim,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ERLS', style: UiTheme.title),
                const Text('DINO', style: UiTheme.title),
                const SizedBox(height: 10),
                const Text('TIPPY TAPPY', style: UiTheme.body),
                const SizedBox(height: 36),
                PixelButton(
                  label: 'PLAY',
                  accent: true,
                  onPressed: onPlay,
                ),
                const SizedBox(height: 24),
                if (highScore > 0)
                  Text(
                    'BEST  ${UiTheme.formatScore(highScore)}',
                    style: UiTheme.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
