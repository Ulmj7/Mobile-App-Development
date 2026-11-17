/// Error text for a new password, or null when it is acceptable.
String? validateNewPassword(String? value) {
  final v = value ?? '';
  if (v.length < 8) return 'Хамгийн багадаа 8 тэмдэгт';
  if (!RegExp(r'\d').hasMatch(v)) return 'Дор хаяж нэг тоо оруулна уу';
  if (!RegExp(r'\p{L}', unicode: true).hasMatch(v)) {
    return 'Дор хаяж нэг үсэг оруулна уу';
  }
  if (v.contains(' ')) return 'Хоосон зай оруулж болохгүй';
  return null;
}

enum PasswordStrength { none, weak, medium, strong }

/// Rates a password from 0 to 6 points — length (8+, 12+), lower case, upper
/// case, digit, symbol — and maps it to weak / medium / strong (task 2 #4).
PasswordStrength passwordStrength(String value) {
  if (value.isEmpty) return PasswordStrength.none;
  // Too short to be accepted at all, however many character classes it mixes.
  if (value.length < 8) return PasswordStrength.weak;
  var points = 0;
  if (value.length >= 8) points++;
  if (value.length >= 12) points++;
  if (RegExp(r'\p{Ll}', unicode: true).hasMatch(value)) points++;
  if (RegExp(r'\p{Lu}', unicode: true).hasMatch(value)) points++;
  if (RegExp(r'\d').hasMatch(value)) points++;
  if (RegExp(r'[^\p{L}\d\s]', unicode: true).hasMatch(value)) points++;
  if (points <= 2) return PasswordStrength.weak;
  if (points <= 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
