import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow_app/core/theme/cyber_colors.dart';

class AddTaskResult {
  final String title;
  final XFile? image;
  const AddTaskResult({required this.title, this.image});
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _scanCtrl;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(
      context,
    ).pop(AddTaskResult(title: text, image: _selectedImage));
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (image != null) setState(() => _selectedImage = image);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? CyberColors.darkSurface : CyberColors.lightSurface;

    return Dialog(
          backgroundColor: bgColor,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 48,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Scan line animada
              AnimatedBuilder(
                animation: _scanCtrl,
                builder: (_, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Align(
                      alignment: Alignment(0, -1 + _scanCtrl.value * 2),
                      child: Container(
                        height: 1.5,
                        color: cs.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                          children: [
                            Container(
                              width: 3,
                              height: 22,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                boxShadow: CyberColors.neonGlow(
                                  cs.primary,
                                  spread: 3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NOVA TAREFA',
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            _CyberCornerIcon(color: cs.primary),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.2, end: 0, duration: 300.ms),

                    const SizedBox(height: 20),

                    // Input
                    TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? CyberColors.darkText
                                : CyberColors.lightText,
                            letterSpacing: 0.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Descreva a tarefa...',
                            prefixIcon: Icon(
                              Icons.terminal_rounded,
                              color: cs.primary.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 80.ms)
                        .slideY(begin: 0.15, end: 0, duration: 350.ms),

                    // Image picker — exclusivo Android
                    if (Theme.of(context).platform ==
                        TargetPlatform.android) ...[
                      const SizedBox(height: 16),
                      if (_selectedImage == null)
                        Row(
                          children: [
                            Expanded(
                              child: _CyberImageButton(
                                icon: Icons.photo_library_outlined,
                                label: 'GALERIA',
                                color: cs.secondary,
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CyberImageButton(
                                icon: Icons.camera_alt_outlined,
                                label: 'CÂMERA',
                                color: cs.primary,
                                onPressed: () => _pickImage(ImageSource.camera),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 120.ms)
                      else
                        _SelectedImagePreview(
                              image: _selectedImage!,
                              isDark: isDark,
                              accentColor: cs.primary,
                              onRemove: () =>
                                  setState(() => _selectedImage = null),
                            )
                            .animate()
                            .fadeIn(duration: 250.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                            ),
                    ],

                    const SizedBox(height: 24),

                    // Ações
                    Row(
                          children: [
                            Expanded(
                              child: _CyberOutlineButton(
                                label: 'CANCELAR',
                                color: cs.secondary,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CyberFilledButton(
                                label: 'EXECUTAR',
                                color: cs.primary,
                                isDark: isDark,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 160.ms)
                        .slideY(begin: 0.2, end: 0, duration: 350.ms),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 250.ms);
  }
}

class _CyberCornerIcon extends StatelessWidget {
  final Color color;
  const _CyberCornerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.add_circle_outline_rounded,
      color: color.withValues(alpha: 0.8),
      size: 22,
    );
  }
}

class _CyberOutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CyberOutlineButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _CyberFilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  const _CyberFilledButton({
    required this.label,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: CyberColors.subtleGlow(color),
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: isDark ? CyberColors.darkBg : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CyberImageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CyberImageButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  final XFile image;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onRemove;

  const _SelectedImagePreview({
    required this.image,
    required this.isDark,
    required this.accentColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 160),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: CyberColors.subtleGlow(accentColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(image.path), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? CyberColors.darkSurface.withValues(alpha: 0.85)
                    : CyberColors.lightSurface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(Icons.close_rounded, size: 14, color: accentColor),
            ),
          ),
        ),
      ],
    );
  }
}
