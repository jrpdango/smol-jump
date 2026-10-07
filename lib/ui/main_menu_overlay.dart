import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// The screen shown before a run begins: title, Play button and best score.
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({
    super.key,
    required this.highScore,
    required this.onPlay,
    required this.onSettings,
  });

  final int highScore;
  final VoidCallback onPlay;
  final VoidCallback onSettings;

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
                const Text('SMOL', style: UiTheme.title),
                const Text('JUMP', style: UiTheme.title),
                const SizedBox(height: 10),
                const Text('TIPPY TAPPY', style: UiTheme.body),
                const SizedBox(height: 36),
                PixelButton(
                  label: 'PLAY',
                  accent: true,
                  onPressed: onPlay,
                ),
                const SizedBox(height: 14),
                PixelButton(label: 'SETTINGS', onPressed: onSettings),
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
