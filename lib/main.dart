import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:hooks_riverpod/all.dart';
import 'pages/signin_page.dart';

import './provider/auth.dart';
final authProvider = StateNotifierProvider((_) => AuthController());

void main() {
  runApp(
    ProviderScope(
      child: DietApp(),
    ),
  );
}

class DietApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Auth Hooks & Riverpod',
        theme: ThemeData.dark(),
        home: Scaffold(
          body: AuthTypeSelector(),
        ));
  }
}

class AuthTypeSelector extends HookWidget {
  // Navigates to a new page
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context) /*!*/ .push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = useProvider(authProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: Text(firebaseUser == null ? "Firebase Auth Hooks & Riverpod" : firebaseUser.displayName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: SignInButtonBuilder(
              icon: Icons.verified_user,
              backgroundColor: Colors.orange,
              text: 'Sign In',
              onPressed: () => _pushPage(context, SignInPage()),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
