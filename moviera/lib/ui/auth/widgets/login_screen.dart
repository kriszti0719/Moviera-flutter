import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/auth_view_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch() segítségével figyeljük a ViewModel állapotváltozásait (isLoading, errorMessage)
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Moviera'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // JAVÍTÁS: A gyári ikon helyett betöltjük a saját egyedi app ikonunkat
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // Szép, modern lekerekített sarkok
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,  // Fix szélesség
                    height: 100, // Fix magasság
                    fit: BoxFit.cover,
                    // Ha a kép valamiért még nem töltene be, egy biztonsági helyőrzőt mutatunk
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.movie_outlined,
                      size: 80,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Email beviteli mező
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => authViewModel.clearError(), // Ha gépel, eltűnik a korábbi hiba
              ),
              const SizedBox(height: 16),
              
              // Jelszó beviteli mező (rejtett szöveggel)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
                onChanged: (_) => authViewModel.clearError(),
              ),
              const SizedBox(height: 12),

              // Dinamikus hibaüzenet megjelenítése piros színnel
              if (authViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 12),

              // Gomb vagy töltési animáció a ViewModel állapotától függően
              authViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        authViewModel.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
              
              const SizedBox(height: 24),
              
              // Átregisztrálási link
              TextButton(
                onPressed: () {
                  authViewModel.clearError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}