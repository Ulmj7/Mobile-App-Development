import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/auth_service.dart';
import '../widgets/password_field.dart';

/// Sign-in on a gradient background. The router sends the user on to
/// "Газрууд" as soon as [auth] reports a session.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    // On success the router redirects, so only a failure needs handling here.
    if (!ok) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('И-мэйл эсвэл нууц үг буруу')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Light status-bar icons on a dark gradient and the other way round.
    final onGradient =
        ThemeData.estimateBrightnessForColor(scheme.primary) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final overlay =
        ThemeData.estimateBrightnessForColor(scheme.primary) == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.secondary, scheme.tertiary],
              stops: const [0, 0.55, 1],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.travel_explore, size: 72, color: onGradient),
                      const SizedBox(height: 12),
                      Text(
                        'Аяллын газрууд',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: onGradient,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Монголын үзэсгэлэнт газруудыг нээ',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: onGradient),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Нэвтрэх',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: const InputDecoration(
                                      labelText: 'И-мэйл',
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) =>
                                        (v == null || !v.contains('@'))
                                        ? 'Зөв и-мэйл оруулна уу'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  PasswordField(
                                    controller: _password,
                                    label: 'Нууц үг',
                                    helperText:
                                        'Анхны нууц үг: ${AuthService.defaultPassword}',
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (v) =>
                                        (v == null || v.length < 8)
                                        ? 'Хамгийн багадаа 8 тэмдэгт'
                                        : null,
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
                                              semanticsLabel: 'Нэвтэрч байна',
                                            ),
                                          )
                                        : const Text('Нэвтрэх'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
