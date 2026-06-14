import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moviera/ui/auth/widgets/login_screen.dart';
import 'package:moviera/ui/auth/view_model/auth_view_model.dart';
import 'package:moviera/data/repositories/auth_repository.dart';
import 'package:moviera/domain/models/user_model.dart';

// JAVÍTVA: uid helyett a te valós UserModel struktúrádnak megfelelő 'id' paramétert használjuk
class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    return const UserModel(id: '123', email: 'test@test.com');
  }

  @override
  Future<UserModel> register(String email, String password) async {
    return const UserModel(id: '123', email: 'test@test.com');
  }

  @override
  Future<void> logout() async {}

  @override
  Stream<UserModel?> get onAuthStateChanged => const Stream.empty();
}

void main() {
  testWidgets('LoginScreen visual layout elements verification test', (WidgetTester tester) async {
    final fakeRepo = FakeAuthRepository();
    final authViewModel = AuthViewModel(authRepository: fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthViewModel>.value(
          value: authViewModel,
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Login to Moviera'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}