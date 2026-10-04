import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// Small pause affordance pinned to the top-left while a run is active. Only
/// the button itself is hit-testable, so taps elsewhere still jump.
class PauseButtonOverlay extends StatelessWidget {
  const PauseButtonOverlay({super.key, required this.onPause});

  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Semantics(
            button: true,
            label: 'Pause',
            child: Material(
              color: Colors.transparent,
              child: InkResponse(
                onTap: onPause,
                radius: 26,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    shape: BoxShape.circle,
                    border: Border.all(color: UiTheme.panelBorder, width: 2),
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: UiTheme.ink,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
