import 'package:flutter/material.dart';

/// Password input with a show/hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final Key? fieldKey;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: widget.fieldKey,
    controller: widget.controller,
    obscureText: _obscure,
    textInputAction: widget.textInputAction,
    autofillHints: widget.autofillHints,
    validator: widget.validator,
    onChanged: widget.onChanged,
    onFieldSubmitted: widget.onFieldSubmitted,
    decoration: InputDecoration(
      labelText: widget.label,
      helperText: widget.helperText,
      helperMaxLines: 2,
      prefixIcon: const Icon(Icons.lock_outline),
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Харуулах' : 'Нуух',
        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    ),
  );
}
