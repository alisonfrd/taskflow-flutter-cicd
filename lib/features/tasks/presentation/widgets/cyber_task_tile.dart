import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_app/core/theme/cyber_colors.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';

/// Card de tarefa com design cyberpunk, animações e barra neon lateral.
class CyberTaskTile extends StatefulWidget {
  final String userId;
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final int index;

  const CyberTaskTile({
    super.key,
    required this.userId,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.index,
  });

  @override
  State<CyberTaskTile> createState() => _CyberTaskTileState();
}

class _CyberTaskTileState extends State<CyberTaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _handleToggle() {
    _checkCtrl.forward(from: 0).then((_) => _checkCtrl.reverse());
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _accentForIndex(widget.index, isDark);
    final cardBg = isDark ? CyberColors.darkCard : CyberColors.lightCard;
    final borderColor = isDark
        ? CyberColors.darkCardBorder
        : CyberColors.lightCardBorder;

    return Animate(
      effects: [
        FadeEffect(duration: 350.ms, delay: (widget.index * 60).ms),
        SlideEffect(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
          duration: 400.ms,
          delay: (widget.index * 60).ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Dismissible(
        key: ValueKey(widget.task.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async => true,
        onDismissed: (_) => widget.onDelete(),
        background: _DeleteBackground(isDark: isDark),
        child: _TaskCard(
          task: widget.task,
          accentColor: accentColor,
          cardBg: cardBg,
          borderColor: borderColor,
          isDark: isDark,
          checkScale: _checkScale,
          primaryColor: cs.primary,
          onToggle: _handleToggle,
        ),
      ),
    );
  }

  Color _accentForIndex(int index, bool isDark) {
    final colors = isDark
        ? [
            CyberColors.neonCyan,
            CyberColors.neonPink,
            CyberColors.neonPurple,
            CyberColors.neonGreen,
            CyberColors.neonOrange,
          ]
        : [
            CyberColors.lightPrimary,
            CyberColors.lightSecondary,
            CyberColors.lightAccent,
            const Color(0xFF009966),
            const Color(0xFFCC4400),
          ];
    return colors[index % colors.length];
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final bool isDark;
  final Animation<double> checkScale;
  final Color primaryColor;
  final VoidCallback onToggle;

  const _TaskCard({
    required this.task,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.isDark,
    required this.checkScale,
    required this.primaryColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? CyberColors.darkText : CyberColors.lightText;
    final subColor = isDark
        ? CyberColors.darkTextSecondary
        : CyberColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isDone
              ? borderColor
              : accentColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: task.isDone
            ? []
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.12 : 0.07),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra neon lateral
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 4,
              decoration: BoxDecoration(
                color: task.isDone ? borderColor : accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                boxShadow: task.isDone
                    ? []
                    : CyberColors.neonGlow(accentColor, spread: 3),
              ),
            ),

            // Conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Checkbox customizada
                        ScaleTransition(
                          scale: checkScale,
                          child: _CyberCheckbox(
                            value: task.isDone,
                            accentColor: accentColor,
                            isDark: isDark,
                            onChanged: (_) => onToggle(),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Texto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 15,
                                  fontWeight: task.isDone
                                      ? FontWeight.w400
                                      : FontWeight.w600,
                                  color: task.isDone ? subColor : textColor,
                                  letterSpacing: 0.3,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: subColor,
                                ),
                                child: Text(
                                  task.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(task.createdAt),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  color: subColor.withValues(alpha: 0.7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        if (task.isDone)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _DoneBadge(isDark: isDark),
                          ),
                      ],
                    ),

                    // Imagem — exclusivo Android
                    if (task.imageUrl != null &&
                        Theme.of(context).platform ==
                            TargetPlatform.android) ...[
                      const SizedBox(height: 10),
                      _TaskImage(url: task.imageUrl!, accentColor: accentColor),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y  $h:$min';
  }
}

class _CyberCheckbox extends StatelessWidget {
  final bool value;
  final Color accentColor;
  final bool isDark;
  final ValueChanged<bool?> onChanged;

  const _CyberCheckbox({
    required this.value,
    required this.accentColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? accentColor : accentColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: value ? CyberColors.neonGlow(accentColor, spread: 2) : [],
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 14,
                color: isDark ? CyberColors.darkBg : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  final bool isDark;
  const _DoneBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? CyberColors.neonGreen : const Color(0xFF009944);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(
        'DONE',
        style: GoogleFonts.orbitron(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

class _DeleteBackground extends StatelessWidget {
  final bool isDark;
  const _DeleteBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? CyberColors.neonPink : CyberColors.lightSecondary;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            'DELETE',
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskImage extends StatelessWidget {
  final String url;
  final Color accentColor;

  const _TaskImage({required this.url, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isRemoteUrl = _isRemoteUrl(url);

    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 180),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: isRemoteUrl
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 80,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                            color: accentColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => _brokenImage(),
                  )
                : Image.file(
                    File(url),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _brokenImage(),
                  ),
          ),
        ),
      ),
    );
  }

  bool _isRemoteUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  Widget _brokenImage() {
    return SizedBox(
      height: 60,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: accentColor.withValues(alpha: 0.5),
          size: 28,
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    final isRemoteUrl = _isRemoteUrl(url);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: InteractiveViewer(
              child: isRemoteUrl
                  ? Image.network(url, fit: BoxFit.contain)
                  : Image.file(File(url), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
