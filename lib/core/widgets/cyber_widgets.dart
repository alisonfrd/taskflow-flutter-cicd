import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';

/// Spinner neon animado para estados de carregamento.
class CyberLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const CyberLoadingIndicator({super.key, this.size = 52, this.color});

  @override
  State<CyberLoadingIndicator> createState() => _CyberLoadingIndicatorState();
}

class _CyberLoadingIndicatorState extends State<CyberLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _NeonSpinnerPainter(_ctrl.value, color),
      ),
    );
  }
}

class _NeonSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _NeonSpinnerPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, trackPaint);

    // Glow arc
    for (final (blur, alpha) in [(12.0, 0.3), (6.0, 0.5), (2.0, 1.0)]) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = blur == 2.0 ? 2.5 : 4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = blur > 2
            ? MaskFilter.blur(BlurStyle.normal, blur)
            : null;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + progress * 2 * math.pi,
        math.pi * 1.4,
        false,
        arcPaint,
      );
    }

    // Inner dot
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final dotAngle = -math.pi / 2 + progress * 2 * math.pi;
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(dotOffset, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_NeonSpinnerPainter old) => old.progress != progress;
}

/// Card com borda neon animada e efeito de brilho.
class NeonBorderCard extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final bool animated;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const NeonBorderCard({
    super.key,
    required this.child,
    this.glowColor,
    this.animated = true,
    this.borderRadius,
    this.padding,
  });

  @override
  State<NeonBorderCard> createState() => _NeonBorderCardState();
}

class _NeonBorderCardState extends State<NeonBorderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _pulse = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.animated) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.glowColor ?? Theme.of(context).colorScheme.primary;
    final cardColor = isDark ? CyberColors.darkCard : CyberColors.lightCard;
    final borderColor = isDark
        ? CyberColors.darkCardBorder
        : CyberColors.lightCardBorder;
    final br = widget.borderRadius ?? BorderRadius.circular(14);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: br,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.12 * _pulse.value),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Texto com efeito de glitch periódico — ideal para títulos.
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool enabled;

  const GlitchText(this.text, {super.key, this.style, this.enabled = true});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _glitching = false;
  String _displayed = '';

  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%&!';

  @override
  void initState() {
    super.initState();
    _displayed = widget.text;
    _ctrl = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _startGlitch();
        }
      });

    if (widget.enabled) _scheduleNextGlitch();
  }

  void _scheduleNextGlitch() {
    if (!mounted) return;
    Future.delayed(
      const Duration(seconds: 4) +
          Duration(milliseconds: (math.Random().nextDouble() * 3000).toInt()),
      () {
        if (!mounted) return;
        _startGlitch();
      },
    );
  }

  Future<void> _startGlitch() async {
    if (!mounted || _glitching) return;
    _glitching = true;

    final rng = math.Random();
    const steps = 6;
    for (var i = 0; i < steps; i++) {
      if (!mounted) break;
      setState(() {
        _displayed = widget.text
            .split('')
            .map(
              (c) => rng.nextDouble() < 0.35
                  ? _chars[rng.nextInt(_chars.length)]
                  : c,
            )
            .join();
      });
      await Future.delayed(const Duration(milliseconds: 60));
    }

    if (mounted) setState(() => _displayed = widget.text);
    _glitching = false;
    _scheduleNextGlitch();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style);
  }
}

/// Linha divisória neon estilizada.
class NeonDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const NeonDivider({super.key, this.color, this.height = 1});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            c.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 4)],
      ),
    );
  }
}

/// Chip de status cyberpunk (ex: tarefas concluídas).
class CyberChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const CyberChip({super.key, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: c, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}
