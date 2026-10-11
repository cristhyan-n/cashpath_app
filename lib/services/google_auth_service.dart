import 'package:google_sign_in/google_sign_in.dart';
import 'package:cashpath_app/config/google_config.dart';

class GoogleAuthService {
  static bool _initialized = false;

  /// Devolve o id_token do Google, ou null se o usuário cancelou.
  Future<String?> getIdToken() async {
    final googleSignIn = GoogleSignIn.instance;

    if (!_initialized) {
      await googleSignIn.initialize(serverClientId: googleServerClientId);
      _initialized = true;
    }

    try {
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw Exception('O Google não retornou o token de identidade.');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw Exception('Não foi possível entrar com o Google.');
    }
  }
}
