import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/all.dart';

import '../provider/auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final authProvider = StateNotifierProvider((_) => AuthController());

class SignInPage extends HookWidget {
  final String title = 'Sign In & Out';

  @override
  Widget build(BuildContext context) {
    final firebaseUser = useProvider(authProvider.state);
    final authController = useProvider(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: Text(
                  firebaseUser == null ? '' : firebaseUser.displayName?.toString()),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                final User user = await _auth.currentUser;
                if (user == null) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('No one has signed in.'),
                  ));
                  return;
                }
                authController.setUser(null);
                _signOut();
                final String uid = user.uid;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(uid + ' has successfully signed out.'),
                ));
              },
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            OtherProvidersSignInSection(context),
          ],
        );
      }),
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }
}

class OtherProvidersSignInSection extends HookWidget {
  final TextEditingController _tokenController = TextEditingController();

  OtherProvidersSignInSection(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final authController = useProvider(authProvider);
    return Card(
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: const Text('Social Authentication',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                alignment: Alignment.center,
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.GitHub,
                  text: "Sign In",
                  onPressed: () async {
                    try {
                      UserCredential userCredential;
                      if (kIsWeb) {
                        GithubAuthProvider githubProvider =
                            GithubAuthProvider();
                        userCredential =
                            await _auth.signInWithPopup(githubProvider);
                      } else {
                        final AuthCredential credential =
                            GithubAuthProvider.credential(
                          _tokenController.text,
                        );
                        userCredential =
                            await _auth.signInWithCredential(credential);
                      }

                      final user = userCredential.user;
                      authController.setUser(user);

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Sign In ${user.uid} with GitHub"),
                      ));
                    } catch (e) {
                      print(e);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to sign in with GitHub: ${e}"),
                      ));
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.Google,
                  text: "Sign In",
                  onPressed: () async {
                    try {
                      UserCredential userCredential;

                      if (kIsWeb) {
                        GoogleAuthProvider googleProvider =
                            GoogleAuthProvider();
                        userCredential =
                            await _auth.signInWithPopup(googleProvider);
                      } else {
                        final GoogleSignInAccount googleUser =
                            await GoogleSignIn().signIn();
                        final GoogleSignInAuthentication googleAuth =
                            await googleUser.authentication;
                        final GoogleAuthCredential googleAuthCredential =
                            GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );
                        userCredential = await _auth
                            .signInWithCredential(googleAuthCredential);
                      }

                      final user = userCredential.user;

                      authController.setUser(user);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Sign In ${user.uid} with Google"),
                      ));
                    } catch (e) {
                      print(e);

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to sign in with Google: ${e}"),
                      ));
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
