import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/state/auth_service.dart';
import 'package:travel_mn/state/settings.dart';

import 'helpers.dart';

Future<void> signIn(WidgetTester tester, String email, String password) async {
  await fill(tester, 'И-мэйл', email);
  await fill(tester, 'Нууц үг', password);
  await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
  // The sign-in call takes a second; pump past it.
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle();
}

void main() {
  group('login', () {
    testWidgets('a signed-out user is sent to the login page', (tester) async {
      await openApp(tester, loggedIn: false);
      expect(find.widgetWithText(FilledButton, 'Нэвтрэх'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('empty fields show validation errors and do not sign in', (
      tester,
    ) async {
      await openApp(tester, loggedIn: false);
      await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
      await tester.pumpAndSettle();
      expect(find.text('Зөв и-мэйл оруулна уу'), findsOneWidget);
      expect(find.text('Хамгийн багадаа 8 тэмдэгт'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('the sign-in spinner is announced to screen readers', (
      tester,
    ) async {
      await openApp(tester, loggedIn: false);
      await fill(tester, 'И-мэйл', 'test@example.com');
      await fill(tester, 'Нууц үг', 'Mobile317');
      await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .semanticsLabel,
        'Нэвтэрч байна',
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('a malformed email is rejected', (tester) async {
      await openApp(tester, loggedIn: false);
      await fill(tester, 'И-мэйл', 'not-an-email');
      await fill(tester, 'Нууц үг', 'Mobile317');
      await tester.tap(find.widgetWithText(FilledButton, 'Нэвтрэх'));
      await tester.pumpAndSettle();
      expect(find.text('Зөв и-мэйл оруулна уу'), findsOneWidget);
    });

    testWidgets('a wrong password shows a snackbar and stays on login', (
      tester,
    ) async {
      await openApp(tester, loggedIn: false);
      await signIn(tester, 'test@example.com', 'Wrong12345');
      expect(find.text('И-мэйл эсвэл нууц үг буруу'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(auth.loggedIn, isFalse);
    });

    testWidgets('the default password Mobile317 signs in to the places list', (
      tester,
    ) async {
      await openApp(tester, loggedIn: false);
      await signIn(tester, 'test@example.com', 'Mobile317');
      expect(find.byType(GridView), findsOneWidget);
      expect(auth.loggedIn, isTrue);
      expect(find.text('test@example.com'), findsNothing);
    });

    testWidgets('the password can be revealed and hidden', (tester) async {
      await openApp(tester, loggedIn: false);
      await fill(tester, 'Нууц үг', 'Mobile317');
      EditableText field() => tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Нууц үг'),
          matching: find.byType(EditableText),
        ),
      );
      expect(field().obscureText, isTrue);
      await tester.tap(find.byTooltip('Харуулах'));
      await tester.pump();
      expect(field().obscureText, isFalse);
    });
  });

  group('settings', () {
    testWidgets('shows the signed-in email and logs out to the login page', (
      tester,
    ) async {
      await openApp(tester);
      await goToTab(tester, 'Тохиргоо');
      expect(find.text('test@example.com'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Гарах'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Нэвтрэх'), findsOneWidget);
      expect(auth.loggedIn, isFalse);
      // After logging out the guarded pages are unreachable.
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('the appearance dialog switches to the dark theme', (
      tester,
    ) async {
      await openApp(tester);
      await goToTab(tester, 'Тохиргоо');
      await tester.tap(find.text('Харагдац'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Бараан'));
      await tester.pumpAndSettle();
      expect(themeMode.value, ThemeMode.dark);
      final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(material.themeMode, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
    });
  });

  group('change password', () {
    Future<void> open(WidgetTester tester) async {
      await openApp(tester, height: 1000);
      await goToTab(tester, 'Тохиргоо');
      await tester.tap(find.text('Нууц үг солих'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Нууц үг солих'),
        findsOneWidget,
      );
    }

    Future<void> submit(
      WidgetTester tester, {
      required String current,
      required String next,
      required String repeat,
    }) async {
      await fill(tester, 'Одоогийн нууц үг', current);
      await fill(tester, 'Шинэ нууц үг', next);
      await fill(tester, 'Шинэ нууц үгийг давтах', repeat);
      await tester.tap(find.widgetWithText(FilledButton, 'Нууц үг солих'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    testWidgets('all fields are required', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Нууц үг солих'));
      await tester.pumpAndSettle();
      expect(find.text('Одоогийн нууц үгээ оруулна уу'), findsOneWidget);
      expect(find.text('Хамгийн багадаа 8 тэмдэгт'), findsOneWidget);
    });

    testWidgets('a wrong current password is rejected', (tester) async {
      await open(tester);
      await submit(
        tester,
        current: 'Wrong12345',
        next: 'Mobile318',
        repeat: 'Mobile318',
      );
      expect(find.text('Одоогийн нууц үг буруу байна'), findsOneWidget);
      expect(find.text('Нууц үг амжилттай солигдлоо'), findsNothing);
    });

    testWidgets(
      'editing the current password clears the wrong-password error',
      (tester) async {
        await open(tester);
        await submit(
          tester,
          current: 'Wrong12345',
          next: 'Mobile318',
          repeat: 'Mobile318',
        );
        expect(find.text('Одоогийн нууц үг буруу байна'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Одоогийн нууц үг'),
          'Wrong123456',
        );
        await tester.pump();
        expect(find.text('Одоогийн нууц үг буруу байна'), findsNothing);
      },
    );

    testWidgets('the saving spinner is announced to screen readers', (
      tester,
    ) async {
      await open(tester);
      await fill(tester, 'Одоогийн нууц үг', 'Mobile317');
      await fill(tester, 'Шинэ нууц үг', 'Mobile318');
      await fill(tester, 'Шинэ нууц үгийг давтах', 'Mobile318');
      await tester.tap(find.widgetWithText(FilledButton, 'Нууц үг солих'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .semanticsLabel,
        'Нууц үг солиж байна',
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('mismatching repeat is rejected', (tester) async {
      await open(tester);
      await submit(
        tester,
        current: 'Mobile317',
        next: 'Mobile318',
        repeat: 'Mobile319',
      );
      expect(find.text('Нууц үг таарахгүй байна'), findsOneWidget);
    });

    testWidgets('a new password equal to the current one is rejected', (
      tester,
    ) async {
      await open(tester);
      await submit(
        tester,
        current: 'Mobile317',
        next: 'Mobile317',
        repeat: 'Mobile317',
      );
      expect(
        find.text('Шинэ нууц үг одоогийнхоос өөр байх ёстой'),
        findsOneWidget,
      );
    });

    testWidgets('a weak new password is rejected by the rules', (tester) async {
      await open(tester);
      await fill(tester, 'Шинэ нууц үг', 'abc');
      await tester.tap(find.widgetWithText(FilledButton, 'Нууц үг солих'));
      await tester.pumpAndSettle();
      expect(find.text('Хамгийн багадаа 8 тэмдэгт'), findsOneWidget);
    });

    testWidgets('the strength meter follows the typed password', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Нууц үгийн хүч'), findsOneWidget);
      await fill(tester, 'Шинэ нууц үг', 'abc');
      expect(find.text('Нууц үгийн хүч: Сул'), findsOneWidget);
      await fill(tester, 'Шинэ нууц үг', 'Abcdefg1');
      expect(find.text('Нууц үгийн хүч: Дундаж'), findsOneWidget);
      await fill(tester, 'Шинэ нууц үг', 'Mobile318-Travel!');
      expect(find.text('Нууц үгийн хүч: Хүчтэй'), findsOneWidget);
    });

    testWidgets('success shows a snackbar, returns to settings, and the new '
        'password is the one that signs in afterwards', (tester) async {
      await open(tester);
      await submit(
        tester,
        current: 'Mobile317',
        next: 'Mobile318',
        repeat: 'Mobile318',
      );
      expect(find.text('Нууц үг амжилттай солигдлоо'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Нууц үг солих'), findsNothing);
      expect(find.text('Тохиргоо'), findsWidgets);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Гарах'));
      await tester.pumpAndSettle();
      await signIn(tester, 'test@example.com', 'Mobile317');
      expect(find.text('И-мэйл эсвэл нууц үг буруу'), findsOneWidget);
      await signIn(tester, 'test@example.com', 'Mobile318');
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
