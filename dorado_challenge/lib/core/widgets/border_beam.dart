import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated traveling border-beam effect with aurora borealis-style ripple.
///
/// A soft glow travels along a configurable arc of the widget's border.
/// The luminance is non-uniform — overlapping sine waves at different spatial
/// frequencies and temporal speeds create bright/dim patches that shift over
/// time, giving the curtain-of-light aurora feel.
///
/// **Path control**
/// - [arcStart]  – where the beam begins (0.0–1.0, clockwise from top-center).
///   0.0 = top · 0.25 = right · 0.5 = bottom · 0.75 = left
/// - [arcLength] – fraction of the perimeter to travel (0.25 = quarter arc).
///
/// **Speed control**
/// - [duration]      – one full beam cycle. Shorter = faster.
/// - [pauseDuration] – idle time between cycles. Defaults to zero (instant
///   restart). e.g. `Duration(seconds: 2)` adds a 2 s pause after each pass.
///
/// **Aurora tuning**
/// - [rippleIntensity] – 0.0 = smooth gradient · 1.0 = full aurora churn.
/// - [trailFraction]   – length of the tail relative to the active arc.
/// - [strokeWidth]     – core beam thickness.
/// - [color]           – primary beam tint (yellow by default).
class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    required this.borderRadius,
    this.color = const Color(0xFFE9FF47),
    this.strokeWidth = 2.5,
    this.trailFraction = 0.55,
    this.arcStart = 0.25,
    this.arcLength = 0.25,
    this.duration = const Duration(milliseconds: 1800),
    this.pauseDuration = Duration.zero,
    this.rippleIntensity = 0.72,
  });

  final Widget child;

  /// Corner radius of the shape. Use `width / 2` for a full circle.
  final double borderRadius;

  /// Primary beam tint.
  final Color color;

  /// Core stroke width in logical pixels.
  final double strokeWidth;

  /// Tail length as a fraction of the active arc (0–1).
  final double trailFraction;

  /// Arc start — fraction of the full perimeter (0–1).
  final double arcStart;

  /// Arc span — fraction of the full perimeter (0–1).
  final double arcLength;

  /// Duration of one beam pass. Shorter = faster.
  final Duration duration;

  /// Pause between cycles. `Duration.zero` = immediate restart.
  final Duration pauseDuration;

  /// Aurora ripple intensity — 0 = smooth, 1 = heavy churn.
  final double rippleIntensity;

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _runCycle();
  }

  Future<void> _runCycle() async {
    while (mounted) {
      _ctrl.value = 0;
      await _ctrl.forward();
      if (!mounted) break;
      if (widget.pauseDuration > Duration.zero) {
        await Future<void>.delayed(widget.pauseDuration);
      }
    }
  }

  @override
  void didUpdateWidget(BorderBeam old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _ctrl.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _BeamPainter(
          animation: _ctrl,
          borderRadius: widget.borderRadius,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
          trailFraction: widget.trailFraction,
          arcStart: widget.arcStart,
          arcLength: widget.arcLength,
          rippleIntensity: widget.rippleIntensity,
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _BeamPainter extends CustomPainter {
  _BeamPainter({
    required this.animation,
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.trailFraction,
    required this.arcStart,
    required this.arcLength,
    required this.rippleIntensity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double trailFraction;
  final double arcStart;
  final double arcLength;
  final double rippleIntensity;

  // More steps = smoother aurora gradient between bright/dim patches
  static const int _steps = 32;

  // ---------------------------------------------------------------------------
  // Aurora noise — three sine waves with incommensurable frequencies so they
  // never perfectly repeat, producing organic-looking interference patterns.
  // `t`    = normalised position along trail   [0 = tail, 1 = head]
  // `time` = animation.value                  [0, 1) wrapping each cycle
  // Returns a value in approximately [-1, 1].
  // ---------------------------------------------------------------------------
  double _aurora(double t, double time) {
    final w1 = math.sin(
      t * 9.1 + time * math.pi * 4.3,
    ); // fast spatial, medium temporal
    final w2 = math.sin(
      t * 3.7 - time * math.pi * 7.1,
    ); // slow spatial, fast temporal
    final w3 = math.sin(
      t * 17.3 + time * math.pi * 2.2,
    ); // very fast spatial, slow temporal
    return w1 * 0.42 + w2 * 0.34 + w3 * 0.24; // weighted sum ≈ [-1, 1]
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(borderRadius),
        ),
      );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final total = metric.length;

    final arcStartDist = arcStart * total;
    final arcLen = arcLength * total;
    final arcEndDist = arcStartDist + arcLen;
    final time = animation.value;

    final headDist = arcStartDist + time * arcLen;
    final trailLen = arcLen * trailFraction;
    final trailStartDist = math.max(arcStartDist, headDist - trailLen);

    // ── Envelope: smooth fade-in at start, fade-out at end ───────────────
    const kFadeIn = 0.15;
    final fadeIn = ((headDist - arcStartDist) / (arcLen * kFadeIn)).clamp(
      0.0,
      1.0,
    );

    const kFadeOut = 0.20;
    final fadeOutStart = arcEndDist - arcLen * kFadeOut;
    final fadeOut = headDist >= fadeOutStart
        ? 1.0 -
              ((headDist - fadeOutStart) / (arcLen * kFadeOut)).clamp(0.0, 1.0)
        : 1.0;

    final envelope = fadeIn * fadeOut;
    if (envelope < 0.01) return;

    // ── Per-segment aurora rendering ─────────────────────────────────────
    final trailSpan = headDist - trailStartDist;
    if (trailSpan < 0.5) return;

    for (int i = 0; i < _steps; i++) {
      final t = (i + 1) / _steps; // 0 = tail → 1 = head

      // Base luminance from power-curve falloff
      final base = math.pow(t, 1.6).toDouble();

      // Aurora ripple modulation — shifts the luminance up and down along path
      final ripple = _aurora(t, time) * rippleIntensity;
      // Keep it positive; ripple can boost (+) or dim (−) each patch
      final luminance = (base + ripple * base * 0.85).clamp(0.0, 1.6);

      // Width pulsation — aurora curtains expand and contract
      final widthMod = 1.0 + _aurora(t, time + 0.5) * 0.45 * rippleIntensity;

      // Color temperature shift: yellow ↔ warm white (aurora shimmer)
      final tempShift =
          ((_aurora(t, time + 0.25) + 1) / 2) * 0.28 * rippleIntensity;
      final segColor = Color.lerp(color, Colors.white, tempShift)!;

      final segStart = (trailStartDist + (i / _steps) * trailSpan).clamp(
        arcStartDist,
        arcEndDist,
      );
      final segEnd = (trailStartDist + ((i + 1) / _steps) * trailSpan).clamp(
        arcStartDist,
        arcEndDist,
      );
      if (segEnd - segStart < 0.4) continue;

      final extractedSeg = metric.extractPath(segStart, segEnd);

      // Layer 1 — wide outer bloom
      canvas.drawPath(
        extractedSeg,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 6.5 * widthMod
          ..strokeCap = StrokeCap.round
          ..color = segColor.withValues(
            alpha: (luminance * 0.09 * envelope).clamp(0.0, 1.0),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
      );

      // Layer 2 — mid glow
      canvas.drawPath(
        extractedSeg,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 3.2 * widthMod
          ..strokeCap = StrokeCap.round
          ..color = segColor.withValues(
            alpha: (luminance * 0.28 * envelope).clamp(0.0, 1.0),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Layer 3 — core beam
      canvas.drawPath(
        extractedSeg,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * (0.8 + widthMod * 0.2)
          ..strokeCap = StrokeCap.round
          ..color = segColor.withValues(
            alpha: (luminance * 0.82 * envelope).clamp(0.0, 1.0),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }

    // ── Head: layered blurry bloom (no hard dot) ─────────────────────────
    final hDist = headDist.clamp(0.0, total - 0.01);
    final headTangent = metric.getTangentForOffset(hDist);
    if (headTangent != null) {
      final hp = headTangent.position;
      // Outer diffuse haze
      canvas.drawCircle(
        hp,
        strokeWidth * 5.0,
        Paint()
          ..color = color.withValues(alpha: 0.13 * envelope)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
      );
      // Mid glow
      canvas.drawCircle(
        hp,
        strokeWidth * 2.8,
        Paint()
          ..color = color.withValues(alpha: 0.36 * envelope)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5),
      );
      // Soft bright centre
      canvas.drawCircle(
        hp,
        strokeWidth * 1.3,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.48 * envelope)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );
    }
  }

  @override
  bool shouldRepaint(_BeamPainter old) =>
      old.borderRadius != borderRadius ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.trailFraction != trailFraction ||
      old.arcStart != arcStart ||
      old.arcLength != arcLength ||
      old.rippleIntensity != rippleIntensity;
}
