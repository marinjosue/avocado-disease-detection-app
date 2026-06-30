import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:aplication_tesis/l10n/app_localizations.dart';

/// A WhatsApp-style voice-note widget rendered inside the user message bubble.
///
/// Shows:
///  - A play/pause [IconButton] controlling the [AudioPlayer].
///  - An [Expanded] [LinearProgressIndicator] with position/duration progress.
///  - A small duration [Text].
///  - The transcription text below, in a smaller, slightly muted style.
///
/// The [AudioPlayer] is created in [initState] and disposed in [dispose].
/// Subscriptions are cancelled in [dispose] as well.
///
/// If the file at [audioPath] cannot be played (e.g. it doesn't exist in tests)
/// the widget degrades gracefully — no exception is thrown; the transcript
/// remains visible.
class VoiceNoteBubble extends StatefulWidget {
  const VoiceNoteBubble({
    super.key,
    required this.audioPath,
    required this.transcript,
    this.transcriptStyle,
    required this.foreground,
  });

  /// Absolute path to the local audio file (e.g. `/data/.../voice_notes/xyz.m4a`).
  final String audioPath;

  /// The STT transcription shown below the player controls.
  final String transcript;

  /// Optional style override for the transcription text.
  /// Defaults to `bodySmall` with [foreground] at 85% opacity.
  final TextStyle? transcriptStyle;

  /// Color for icons and text, meant to be the on-primary color so it reads
  /// on the green user bubble background.
  final Color foreground;

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  late final AudioPlayer _player;

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
        // When playback completes, reset position to zero so the play button
        // returns and the progress bar goes back to the start.
        if (state == PlayerState.completed) {
          _position = Duration.zero;
        }
      });
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      setState(() => _duration = dur);
    });

    _positionSub = _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else if (_playerState == PlayerState.paused) {
        await _player.resume();
      } else {
        // stopped or completed — play from start
        await _player.play(DeviceFileSource(widget.audioPath));
      }
    } catch (_) {
      // Degrade gracefully: file may not exist (e.g. in tests or after deletion).
      // The transcript remains visible; the play button stays pressable.
    }
  }

  /// Returns a `mm:ss` formatted string for [d].
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fg = widget.foreground;

    // Progress value: guard against zero duration → 0.0
    final double progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    // Display the running position while playing/paused; otherwise the total
    // duration (or zero if not yet known).
    final displayDuration = (_isPlaying || _playerState == PlayerState.paused)
        ? _position
        : _duration;

    final transcriptStyle = widget.transcriptStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: fg.withValues(alpha: 0.85),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Player row ----
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play / pause icon button
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 22,
                tooltip: _isPlaying
                    ? (l10n?.voiceStop ?? 'Pausar')
                    : (l10n?.voiceNote ?? 'Nota de voz'),
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: fg,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const SizedBox(width: 4),
            // Progress bar
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: progress,
                color: fg,
                backgroundColor: fg.withValues(alpha: 0.3),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            // Duration label
            Text(
              _formatDuration(displayDuration),
              style: theme.textTheme.labelSmall?.copyWith(
                color: fg,
                fontSize: 11,
              ),
            ),
          ],
        ),
        // ---- Transcription text ----
        if (widget.transcript.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.transcript,
            style: transcriptStyle,
          ),
        ],
      ],
    );
  }
}
