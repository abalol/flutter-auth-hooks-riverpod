import 'package:hooks_riverpod/all.dart';

class AuthController extends StateNotifier {
  AuthController() : super(null);
  void setUser(tmpUser) {
    state = tmpUser;
  }
}
