import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// The settings screen: currently a single volume slider for the sound
/// effects. Owns its own slider position so dragging is smooth, mirroring
/// every change back to the game (which applies and persists it).
class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({
    super.key,
    required this.volume,
    required this.onChanged,
    required this.onClose,
  });

  /// Initial volume (0..1) read from the game when the screen opens.
  final double volume;

  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  late double _volume = widget.volume;

  void _update(double value) {
    setState(() => _volume = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_volume * 100).round();

    return SizedBox.expand(
      child: ColoredBox(
        color: UiTheme.scrim,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SETTINGS', style: UiTheme.heading),
                const SizedBox(height: 28),
                const Text('VOLUME', style: UiTheme.label),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  child: _VolumeSlider(
                    key: const Key('volumeSlider'),
                    value: _volume,
                    onChanged: _update,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$percent%', style: UiTheme.label),
                const SizedBox(height: 32),
                PixelButton(label: 'BACK', onPressed: widget.onClose),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A blocky, Material-free volume slider: a track that fills with the accent
/// colour as it is dragged, matching the rest of the pixel-art UI.
class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  static const double _trackHeight = 12;
  static const double _thumbSize = 22;
  static const double _height = 36;

  void _emit(Offset local, double width) =>
      onChanged((local.dx / width).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbLeft =
            (value * width - _thumbSize / 2).clamp(0.0, width - _thumbSize);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _emit(details.localPosition, width),
          onHorizontalDragStart: (details) =>
              _emit(details.localPosition, width),
          onHorizontalDragUpdate: (details) =>
              _emit(details.localPosition, width),
          child: SizedBox(
            height: _height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: width,
                  height: _trackHeight,
                  color: UiTheme.panelBorder,
                ),
                Container(
                  width: value * width,
                  height: _trackHeight,
                  color: UiTheme.accent,
                ),
                Positioned(
                  left: thumbLeft,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: UiTheme.accent,
                      border: Border.all(color: UiTheme.outline, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
