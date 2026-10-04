import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// Purely instructional overlay shown at the start of a run. It ignores
/// pointer events so a tap anywhere falls through to the game's full-screen
/// tap surface, which starts the run and launches the dino into a jump.
class StartPromptOverlay extends StatefulWidget {
  const StartPromptOverlay({super.key});

  @override
  State<StartPromptOverlay> createState() => _StartPromptOverlayState();
}

class _StartPromptOverlayState extends State<StartPromptOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Align(
          alignment: const Alignment(0, -0.35),
          child: FadeTransition(
            opacity: _opacity,
            child: const Text('TAP TO START', style: UiTheme.heading),
            ),
          ),
        ),
      );
  }
}
