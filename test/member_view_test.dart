import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluuter_drinkproject/models/auth.dart';
import 'package:fluuter_drinkproject/services/api_client.dart';
import 'package:fluuter_drinkproject/viewmodels/drink_list_view_model.dart';
import 'package:fluuter_drinkproject/views/member_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMemberApiClient extends ApiClient {
  @override
  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    return AuthResponse(
      user: User(id: 1, phone: phone, name: 'Andy'),
      token: 'login-token',
    );
  }

  @override
  Future<AuthResponse> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    return AuthResponse(
      user: User(id: 2, phone: phone, name: name),
      token: 'register-token',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildMemberView() {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeMemberApiClient()),
      ],
      child: const MaterialApp(home: MemberView()),
    );
  }

  testWidgets('login enables after required fields and shows member profile', (
    tester,
  ) async {
    await tester.pumpWidget(buildMemberView());
    await tester.pump();

    expect(find.text('歡迎回來'), findsOneWidget);
    expect(find.text('建立會員帳號'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, '請輸入手機號碼'),
      '0930585856',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '請輸入密碼'),
      'password',
    );
    await tester.pump();
    final loginButton = find.byKey(const ValueKey('member-auth-submit'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('嗨，Andy'), findsOneWidget);
    expect(find.text('會員編號 1'), findsOneWidget);
    expect(find.text('登入成功'), findsOneWidget);
  });

  testWidgets('registration reveals name field and creates member', (
    tester,
  ) async {
    await tester.pumpWidget(buildMemberView());
    await tester.pump();

    await tester.tap(find.text('註冊').first);
    await tester.pumpAndSettle();

    expect(find.text('建立會員帳號'), findsWidgets);
    expect(find.text('請輸入姓名'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, '請輸入手機號碼'),
      '0912345678',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '請輸入姓名'),
      '新會員',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '請輸入密碼'),
      'password',
    );
    await tester.pump();
    final registerButton = find.byKey(const ValueKey('member-auth-submit'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('嗨，新會員'), findsOneWidget);
    expect(find.text('會員編號 2'), findsOneWidget);
    expect(find.text('註冊成功'), findsOneWidget);
  });
}
