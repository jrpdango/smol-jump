import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_soloud/flutter_soloud.dart';

/// Central sound-effect player backed by the SoLoud engine.
///
/// SoLoud mixes on its own native thread and plays the same [AudioSource] as
/// many overlapping voices as needed, so there is no pooling and no per-frame
/// work on the Flutter side.
///
/// Every engine call is guarded so an audio failure (headless tests, an
/// unsupported platform, a missing device) degrades to silence instead of
/// interrupting gameplay.
class AudioManager {
  AudioManager({
    this.jumpAsset = 'assets/audio/jump.wav',
    this.landAsset = 'assets/audio/land.wav',
    this.loseAsset = 'assets/audio/lose.wav',
    this.volume = 0.8,
    bool? enabled,
  }) : _enabled = enabled ?? _platformSupportsAudio();

  /// Native audio is unavailable under `flutter test`, where `SoLoud.init`
  /// cannot resolve the native library. Detect that case (and allow explicit
  /// override) so headless runs stay silent.
  static bool _platformSupportsAudio() {
    if (kIsWeb) {
      return true;
    }
    return !Platform.environment.containsKey('FLUTTER_TEST');
  }

  final String jumpAsset;
  final String landAsset;
  final String loseAsset;
  final double volume;

  /// Accessed lazily so merely constructing an [AudioManager] never touches the
  /// native engine.
  SoLoud get _soloud => SoLoud.instance;

  AudioSource? _jump;
  AudioSource? _land;
  AudioSource? _lose;
  SoundHandle? _loseHandle;

  bool _enabled;
  bool _disposed = false;

  /// Whether the audio backend initialized successfully.
  bool get isEnabled => _enabled;

  /// Initializes the engine and pre-loads the effects. Safe to call once;
  /// failures disable audio.
  Future<void> load() async {
    if (!_enabled || _disposed) {
      return;
    }
    try {
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      _jump = await _soloud.loadAsset(jumpAsset);
      _land = await _soloud.loadAsset(landAsset);
      _lose = await _soloud.loadAsset(loseAsset);
    } catch (_) {
      _enabled = false;
      _jump = null;
      _land = null;
      _lose = null;
    }
  }

  void playJump() => _guard(() {
        final source = _jump;
        if (source != null) {
          _soloud.play(source, volume: volume);
        }
      });

  void playLand() => _guard(() {
        final source = _land;
        if (source != null) {
          _soloud.play(source, volume: volume);
        }
      });

  /// Plays the game-over sting, replacing any sting still playing.
  void playLose() => _guard(() {
        final previous = _loseHandle;
        if (previous != null && _soloud.getIsValidVoiceHandle(previous)) {
          unawaited(_soloud.stop(previous));
        }
        final source = _lose;
        if (source != null) {
          _loseHandle = _soloud.play(source, volume: volume);
        }
      });

  /// Stops one-shots that outlive a run.
  Future<void> stopAll() async {
    final handle = _loseHandle;
    _loseHandle = null;
    if (handle == null || !_enabled || !_soloud.isInitialized) {
      return;
    }
    try {
      if (_soloud.getIsValidVoiceHandle(handle)) {
        await _soloud.stop(handle);
      }
    } catch (_) {
      // Best effort.
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    if (!_enabled || !_soloud.isInitialized) {
      return;
    }
    try {
      await _soloud.disposeAllSources();
      await _soloud.deinitAsync();
    } catch (_) {
      // Best effort.
    }
  }

  void _guard(void Function() action) {
    if (!_enabled || _disposed || !_soloud.isInitialized) {
      return;
    }
    try {
      action();
    } catch (_) {
      // Drop the sound rather than interrupt gameplay.
    }
  }
}
