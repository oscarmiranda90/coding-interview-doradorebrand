import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Animated traveling border-beam effect.
///
/// Wraps [child] and overlays a glowing beam that continuously traces
/// the shape's perimeter. Works with any border-radius, including full
/// circles (radius = width / 2).
///
/// Usage:
/// ```dart
/// BorderBeam(
///   borderRadius: 26,         // match your shape
///   child: MyWidget(),
/// )
/// ```
class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    required this.borderRadius,
    this.color = const Color(0xFFE9FF47),
    this.strokeWidth = 2.5,
    this.beamFraction = 0.32,
    this.duration = const Duration(milliseconds: 2200),
  });

  final Widget child;

  /// Corner radius — must match the actual shape radius.
  /// Pass `width / 2` for a full circle.
  final double borderRadius;

  /// Head color of the beam (defaults to neobrutalist yellow).
  final Color color;

  /// Width of the beam stroke in logical pixels.
  final double strokeWidth;

  /// Fraction of the perimeter the trailing glow covers (0–1).
  final double beamFraction;

  /// Duration of one full revolution.
  final Duration duration;

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
          beamFraction: widget.beamFraction,
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
    required this.beamFraction,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double beamFraction;

  // Number of gradient steps along the trail
  static const int _steps = 22;

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

    final beamLen = total * beamFraction;
    final headDist = animation.value * total;

    for (int i = 0; i < _steps; i++) {
      final t = i / _steps; // 0 = tail → 1 = head
      final alpha = math.pow(t, 1.8).toDouble();

      final segStart = (headDist - beamLen + t * beamLen);
      final segEnd = (headDist - beamLen + (t + 1.0 / _steps) * beamLen);

      // Outer bloom — wide, blurred, dim
      _drawSeg(
        canvas,
        metric,
        total,
        segStart,
        segEnd,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 3.0
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Core beam stroke
      _drawSeg(
        canvas,
        metric,
        total,
        segStart,
        segEnd,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha * 0.95),
      );
    }

    // Bright head flash: white bloom + yellow dot
    final headT = metric.getTangentForOffset(headDist % total);
    if (headT != null) {
      canvas.drawCircle(
        headT.position,
        strokeWidth * 1.8,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        headT.position,
        strokeWidth * 0.75,
        Paint()..color = color,
      );
    }
  }

  /// Draws a path segment between [start] and [end] distances,
  /// correctly handling wrap-around at the path seam.
  void _drawSeg(
    Canvas canvas,
    ui.PathMetric metric,
    double total,
    double start,
    double end,
    Paint paint,
  ) {
    // Normalise both values into [0, total)
    start = start % total;
    end = end % total;

    const minLen = 0.5; // skip trivially small segments

    if (start <= end) {
      if (end - start > minLen) {
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    } else {
      // Wraps around the path seam
      if (total - start > minLen) {
        canvas.drawPath(metric.extractPath(start, total), paint);
      }
      if (end > minLen) {
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BeamPainter old) =>
      old.borderRadius != borderRadius ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.beamFraction != beamFraction;
}
