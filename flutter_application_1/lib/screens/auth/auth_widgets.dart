import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/catalog.dart';
import '../../theme.dart';

const kError = Color(0xFFFF6B6B);

/// ───────────────────────── Validaciones ─────────────────────────
String? validateEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Escribe tu correo.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
    return 'Ese correo no parece válido.';
  }
  return null;
}

String? validateNewPassword(String? v) {
  final s = v ?? '';
  if (s.length < 8) return 'Usa al menos 8 caracteres.';
  if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
    return 'Combina letras y números.';
  }
  return null;
}

String? validateDisplayName(String? v) {
  final s = (v ?? '').trim();
  if (s.length < 2) return 'Escribe al menos 2 caracteres.';
  if (s.length > 24) return 'Máximo 24 caracteres.';
  return null;
}

String? validateUsername(String? v) {
  final s = (v ?? '').trim();
  if (!RegExp(r'^[a-zA-Z0-9_]{3,16}$').hasMatch(s)) {
    return 'Entre 3 y 16 caracteres: letras, números o guion bajo.';
  }
  return null;
}

/// ───────────────────────── Decoración de campos ─────────────────────────
InputDecoration authDecoration({
  required String label,
  String? hint,
  String? helper,
  IconData? icon,
  String? prefixText,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    helperMaxLines: 2,
    prefixText: prefixText,
    prefixIcon: icon == null ? null : Icon(icon, size: 20, color: C.muted),
    suffixIcon: suffix,
    filled: true,
    fillColor: C.surface,
    labelStyle: const TextStyle(color: C.muted, fontSize: 14),
    hintStyle: const TextStyle(color: Color(0x668A93AB), fontSize: 14),
    helperStyle: const TextStyle(color: C.muted, fontSize: 11.5),
    prefixStyle:
        const TextStyle(color: C.primary, fontWeight: FontWeight.w700),
    errorStyle: const TextStyle(color: kError, fontSize: 11.5),
    errorMaxLines: 2,
    border: border(C.border),
    enabledBorder: border(C.border),
    focusedBorder: border(C.primary),
    errorBorder: border(kError),
    focusedErrorBorder: border(kError),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
  );
}

/// ───────────────────────── Campo de texto ─────────────────────────
class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final IconData icon;
  final bool password;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? maxLength;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.helper,
    this.password = false,
    this.prefixText,
    this.keyboardType,
    this.action,
    this.validator,
    this.autofillHints,
    this.formatters,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.password && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.action,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.formatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      maxLines: widget.password ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      style: const TextStyle(color: C.text, fontSize: 15),
      cursorColor: C.primary,
      decoration: authDecoration(
        label: widget.label,
        hint: widget.hint,
        helper: widget.helper,
        icon: widget.icon,
        prefixText: widget.prefixText,
        suffix: widget.password
            ? IconButton(
                tooltip: _hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: C.muted,
                ),
              )
            : null,
      ),
    );
  }
}

/// ───────────────────────── Fondo, logo y botones ─────────────────────────
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -1.1),
                  radius: 1.0,
                  colors: [Color(0x447B6CFF), Color(0x00000000)],
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  final double size;
  const AuthLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient:
                const LinearGradient(colors: [C.primary, Color(0xFF3B2FB5)]),
            boxShadow: const [
              BoxShadow(color: Color(0x667B6CFF), blurRadius: 30),
            ],
          ),
          child: Icon(Icons.bolt_rounded, size: size * 0.55, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text('SyncPlay',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: C.text,
                letterSpacing: -0.5)),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: C.primary,
          disabledBackgroundColor: const Color(0x887B6CFF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const SecondaryButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: C.border),
          backgroundColor: C.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: C.text)),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x22FF6B6B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x55FF6B6B)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, size: 18, color: kError),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(fontSize: 12.5, color: kError)),
        ),
      ]),
    );
  }
}

/// ───────────────────────── Selección ─────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const FieldLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: C.text)),
        if (trailing != null) ...[
          const Spacer(),
          Text(trailing!,
              style: const TextStyle(fontSize: 11.5, color: C.muted)),
        ],
      ]),
    );
  }
}

class SelectChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? C.primarySoft : C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? C.primary : C.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? C.primary : C.muted),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? C.primary : C.muted)),
        ]),
      ),
    );
  }
}

/// Fila de círculos para elegir el color del avatar.
class AvatarColorPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const AvatarColorPicker(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(kAvatarPalette.length, (i) {
        final pal = kAvatarPalette[i];
        final sel = i == selected;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [pal.$1, pal.$2]),
              border: Border.all(
                  color: sel ? Colors.white : Colors.transparent, width: 2.5),
            ),
            child: sel
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : null,
          ),
        );
      }),
    );
  }
}
