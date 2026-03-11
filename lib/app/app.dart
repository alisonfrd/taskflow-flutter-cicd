import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_app/core/theme/cyber_colors.dart';
import 'package:taskflow_app/core/theme/cyber_theme.dart';
import 'package:taskflow_app/core/theme/theme_cubit.dart';
import 'package:taskflow_app/core/theme/theme_state.dart';
import 'package:taskflow_app/core/widgets/cyber_widgets.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:taskflow_app/features/tasks/presentation/pages/tasks_page.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'TaskFlow',
          debugShowCheckedModeBanner: false,
          theme: CyberTheme.light,
          darkTheme: CyberTheme.dark,
          themeMode: themeState.themeMode,
          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                context.read<TasksCubit>().watchTasks(state.user.uid);
              }
            },
            builder: (context, state) {
              if (state is AuthLoading || state is AuthInitial) {
                return const _CyberLoadingPage();
              }

              if (state is Authenticated) {
                return TasksPage(userId: state.user.uid);
              }

              if (state is AuthError) {
                return _CyberErrorPage(message: state.message);
              }

              return const _CyberLoadingPage();
            },
          ),
        );
      },
    );
  }
}

class _CyberLoadingPage extends StatelessWidget {
  const _CyberLoadingPage();

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final primary = isDark ? CyberColors.neonCyan : CyberColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? CyberColors.darkBg : CyberColors.lightBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanLinePainter(color: primary.withValues(alpha: 0.04)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CyberLoadingIndicator(size: 64, color: primary),
                const SizedBox(height: 28),
                Text(
                  'INICIALIZANDO',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'TASKFLOW v1.0',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: primary.withValues(alpha: 0.5),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberErrorPage extends StatelessWidget {
  final String message;
  const _CyberErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final errorColor = isDark
        ? const Color(0xFFFF3A3A)
        : const Color(0xFFCC0000);
    final bg = isDark ? CyberColors.darkBg : CyberColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  color: errorColor.withValues(alpha: 0.08),
                  boxShadow: isDark ? CyberColors.subtleGlow(errorColor) : [],
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: errorColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'FALHA NA AUTENTICAÇÃO',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: errorColor,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: (isDark ? CyberColors.darkText : CyberColors.lightText)
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final Color color;
  _ScanLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const step = 32.0;
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.color != color;
}
