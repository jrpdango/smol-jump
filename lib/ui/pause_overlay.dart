import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// Shown while the game is paused, with resume/restart/quit actions.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onMenu,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: UiTheme.scrim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PAUSED', style: UiTheme.heading),
              const SizedBox(height: 32),
              PixelButton(
                label: 'RESUME',
                accent: true,
                onPressed: onResume,
              ),
              const SizedBox(height: 14),
              PixelButton(label: 'RESTART', onPressed: onRestart),
              const SizedBox(height: 14),
              PixelButton(label: 'SETTINGS', onPressed: onSettings),
              const SizedBox(height: 14),
              PixelButton(label: 'MAIN MENU', onPressed: onMenu),
            ],
          ),
        ),
      ),
    );
  }
}
