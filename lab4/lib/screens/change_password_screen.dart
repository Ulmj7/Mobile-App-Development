import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_meter.dart';

/// "Нууц үг солих": current + new + confirmation, with a live strength bar.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentKey = GlobalKey<FormFieldState<String>>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  /// Set when the "server" rejected the current password; shown until the
  /// user edits that field.
  String? _currentError;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await auth.changePassword(_current.text, _next.text);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _currentError = 'Одоогийн нууц үг буруу байна';
      });
      _currentKey.currentState?.validate();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Нууц үг амжилттай солигдлоо')),
      );
    context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Нууц үг солих')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PasswordField(
                  fieldKey: _currentKey,
                  controller: _current,
                  label: 'Одоогийн нууц үг',
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) {
                    // Editing after a server "wrong password" answer clears it.
                    if (_currentError != null) {
                      _currentError = null;
                      _currentKey.currentState?.validate();
                    }
                  },
                  validator: (v) {
                    if (_currentError != null) return _currentError;
                    return (v == null || v.isEmpty)
                        ? 'Одоогийн нууц үгээ оруулна уу'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _next,
                  label: 'Шинэ нууц үг',
                  helperText:
                      'Дор хаяж 8 тэмдэгт, үсэг болон тоо агуулсан байх',
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) {
                    final problem = validateNewPassword(v ?? '');
                    if (problem != null) return problem;
                    if (v == _current.text) {
                      return 'Шинэ нууц үг одоогийнхоос өөр байх ёстой';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                PasswordStrengthMeter(controller: _next),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirm,
                  label: 'Шинэ нууц үгийг давтах',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _next.text ? 'Нууц үг таарахгүй байна' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            semanticsLabel: 'Нууц үг солиж байна',
                          ),
                        )
                      : const Text('Нууц үг солих'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
