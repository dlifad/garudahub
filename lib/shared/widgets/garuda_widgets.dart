import 'package:flutter/material.dart';

// Garuda Logo
class GarudaLogo extends StatelessWidget {
  final double size;
  const GarudaLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text('🦅', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}

// Custom TextField
class GarudaTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;

  const GarudaTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
  });

  @override
  State<GarudaTextField> createState() => _GarudaTextFieldState();
}

class _GarudaTextFieldState extends State<GarudaTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      style: TextStyle(color: cs.onSurface),
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: widget.fillColor ?? cs.surfaceContainerHighest,
        labelStyle: TextStyle(color: widget.labelColor ?? cs.onSurfaceVariant,),
        hintStyle: TextStyle(color: widget.hintColor ?? cs.onSurfaceVariant,),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: cs.onSurfaceVariant, size: 20)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

// Loading Button (M3 FilledButton)
class GarudaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;

  const GarudaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color ?? cs.primary,
        foregroundColor: color != null ? Colors.white : cs.onPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: cs.onPrimary, strokeWidth: 2.5),
            )
          : Text(text),
    );
  }
}

// Section Title
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: TextStyle(fontSize: 13, color: cs.primary, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// Snackbar helper
void showGarudaSnackbar(BuildContext context, String message, {bool isError = false}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: isError ? cs.onErrorContainer : cs.onInverseSurface),
      ),
      backgroundColor: isError ? cs.errorContainer : cs.inverseSurface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}