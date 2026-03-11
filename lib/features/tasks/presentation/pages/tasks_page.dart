import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_app/core/theme/cyber_colors.dart';
import 'package:taskflow_app/core/theme/theme_cubit.dart';
import 'package:taskflow_app/core/theme/theme_state.dart';
import 'package:taskflow_app/core/widgets/cyber_widgets.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_state.dart';
import 'package:taskflow_app/features/tasks/presentation/widgets/add_task_dialog.dart';
import 'package:taskflow_app/features/tasks/presentation/widgets/cyber_task_tile.dart';

class TasksPage extends StatelessWidget {
  final String userId;

  const TasksPage({super.key, required this.userId});

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const AddTaskDialog(),
    );

    if (title == null || title.trim().isEmpty || !context.mounted) return;

    await context.read<TasksCubit>().addTask(userId: userId, title: title);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CyberColors.darkBg : CyberColors.lightBg,
      appBar: _CyberAppBar(userId: userId),
      floatingActionButton: _CyberFAB(
        onPressed: () => _showAddTaskDialog(context),
        isDark: isDark,
      ),
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(child: _GridBackground(isDark: isDark)),

          // Conteúdo
          BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              if (state is TasksLoading || state is TasksInitial) {
                return const Center(child: CyberLoadingIndicator(size: 60));
              }

              if (state is TasksError) {
                return _ErrorView(message: state.message);
              }

              if (state is TasksLoaded) {
                if (state.tasks.isEmpty) {
                  return _EmptyView(isDark: isDark);
                }

                return _TaskList(
                  tasks: state.tasks,
                  userId: userId,
                  isDark: isDark,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── APP BAR ───────────────────────────

class _CyberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  const _CyberAppBar({required this.userId});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: isDark ? CyberColors.darkBg : CyberColors.lightBg,
      title: GlitchText(
        'TASKFLOW',
        style: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: cs.primary,
          letterSpacing: 3,
          shadows: isDark
              ? [
                  Shadow(
                    color: cs.primary.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
      ),
      actions: [
        // Contador de tarefas
        BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is! TasksLoaded || state.tasks.isEmpty) {
              return const SizedBox.shrink();
            }
            final done = state.tasks.where((t) => t.isDone).length;
            final total = state.tasks.length;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CyberChip(
                label: '$done/$total',
                color: cs.tertiary,
                icon: Icons.check_circle_outline,
              ),
            ).animate().fadeIn(duration: 400.ms);
          },
        ),
        const SizedBox(width: 4),
        // Botão de tema
        _ThemeToggleButton(isDark: isDark),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: NeonDivider(
          color: isDark ? cs.primary : cs.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ───────────────────────── THEME TOGGLE ────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final (icon, tooltip) = switch (state.preference) {
          ThemePreference.system => (Icons.brightness_auto_rounded, 'Sistema'),
          ThemePreference.dark => (Icons.dark_mode_rounded, 'Escuro'),
          ThemePreference.light => (Icons.light_mode_rounded, 'Claro'),
        };

        return Tooltip(
          message: tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.read<ThemeCubit>().toggle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: cs.primary, size: 18),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────── TASK LIST ─────────────────────────

class _TaskList extends StatelessWidget {
  final List<TaskItem> tasks;
  final String userId;
  final bool isDark;

  const _TaskList({
    required this.tasks,
    required this.userId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => !t.isDone).toList();
    final done = tasks.where((t) => t.isDone).toList();
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Header de pendentes
        if (pending.isNotEmpty) ...[
          _SectionHeader(
            label: 'PENDENTES',
            count: pending.length,
            color: cs.primary,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ...pending.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CyberTaskTile(
                userId: userId,
                task: e.value,
                index: e.key,
                onToggle: () => context.read<TasksCubit>().toggleTask(
                  userId: userId,
                  task: e.value,
                ),
                onDelete: () {
                  context.read<TasksCubit>().deleteTask(
                    userId: userId,
                    taskId: e.value.id,
                  );
                  _showDeleteSnackBar(context, e.value.title, isDark, cs);
                },
              ),
            );
          }),
        ],

        // Separador
        if (pending.isNotEmpty && done.isNotEmpty) ...[
          const SizedBox(height: 6),
          NeonDivider(color: cs.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
        ],

        // Header de concluídas
        if (done.isNotEmpty) ...[
          _SectionHeader(
            label: 'CONCLUÍDAS',
            count: done.length,
            color: isDark ? CyberColors.neonGreen : const Color(0xFF009944),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ...done.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: 0.72,
                child: CyberTaskTile(
                  userId: userId,
                  task: e.value,
                  index: pending.length + e.key,
                  onToggle: () => context.read<TasksCubit>().toggleTask(
                    userId: userId,
                    task: e.value,
                  ),
                  onDelete: () {
                    context.read<TasksCubit>().deleteTask(
                      userId: userId,
                      taskId: e.value.id,
                    );
                    _showDeleteSnackBar(context, e.value.title, isDark, cs);
                  },
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showDeleteSnackBar(
    BuildContext context,
    String title,
    bool isDark,
    ColorScheme cs,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: cs.secondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"$title" removida',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? CyberColors.darkText : CyberColors.lightText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ──────────────────────── SECTION HEADER ───────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                boxShadow: isDark ? CyberColors.neonGlow(color, spread: 2) : [],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.05, end: 0, duration: 400.ms);
  }
}

// ─────────────────────────── EMPTY VIEW ────────────────────────

class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child:
          Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NeonCircleIcon(color: cs.primary, isDark: isDark),
                  const SizedBox(height: 24),
                  Text(
                    'NENHUMA TAREFA',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pressione + para iniciar',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: isDark
                          ? CyberColors.darkTextSecondary
                          : CyberColors.lightTextSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

class _NeonCircleIcon extends StatefulWidget {
  final Color color;
  final bool isDark;
  const _NeonCircleIcon({required this.color, required this.isDark});

  @override
  State<_NeonCircleIcon> createState() => _NeonCircleIconState();
}

class _NeonCircleIconState extends State<_NeonCircleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.08),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3 * _pulse.value),
            width: 1.5,
          ),
          boxShadow: widget.isDark
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.15 * _pulse.value),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Icon(
          Icons.playlist_add_check_rounded,
          color: widget.color.withValues(alpha: 0.7),
          size: 44,
        ),
      ),
    );
  }
}

// ───────────────────────── ERROR VIEW ──────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'ERRO CRÍTICO',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.error,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).shake(duration: 500.ms, hz: 3);
  }
}

// ────────────────────── FLOATING ACTION BUTTON ─────────────────

class _CyberFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _CyberFAB({required this.onPressed, required this.isDark});

  @override
  State<_CyberFAB> createState() => _CyberFABState();
}

class _CyberFABState extends State<_CyberFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(
                      alpha: 0.5 + 0.3 * _pulse.value,
                    ),
                    blurRadius: 16 + 8 * _pulse.value,
                    spreadRadius: 1 + 2 * _pulse.value,
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: widget.isDark ? CyberColors.darkBg : Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    ).animate().scale(
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
      duration: 500.ms,
      delay: 300.ms,
      curve: Curves.elasticOut,
    );
  }
}

// ──────────────────────── GRID BACKGROUND ──────────────────────

class _GridBackground extends StatelessWidget {
  final bool isDark;
  const _GridBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _GridPainter(
        color: cs.primary.withValues(alpha: isDark ? 0.04 : 0.025),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const step = 32.0;

    // Perspectiva isométrica suave
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Pontos de interseção
    final dotPaint = Paint()..color = color.withValues(alpha: 1.5);
    for (var x = 0.0; x <= size.width; x += step) {
      for (var y = 0.0; y <= size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }

    // Linhas diagonais suaves para efeito perspectiva
    final diagPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.3;

    final diagStep = step * math.sqrt2;
    for (var x = -size.height; x <= size.width + size.height; x += diagStep) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        diagPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
