import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cashpath_app/config/google_config.dart';

class GoogleAuthService {
  static bool _initialized = false;

  /// Devolve o id_token do Google, ou null se o usuário cancelou.
  Future<String?> getIdToken() async {
    final googleSignIn = GoogleSignIn.instance;

    try {
      if (!_initialized) {
        await googleSignIn.initialize(serverClientId: googleServerClientId);
        _initialized = true;
      }

      // Authenticate is always started from an explicit button tap. Clear only
      // the app's current Google session first so the native account chooser
      // can offer another account instead of silently reusing the last one.
      // This does not revoke consent; disconnect() is reserved for account
      // deletion.
      try {
        await googleSignIn.signOut();
      } catch (e) {
        // Signing out can fail when the device has no previous Google
        // session. Continue so Credential Manager can offer another account.
        debugPrint('Não havia sessão Google anterior para encerrar: $e');
      }
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw Exception('O Google não retornou o token de identidade.');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In falhou: $e');
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw Exception('Não foi possível entrar com o Google.');
    } catch (e) {
      debugPrint('Google Sign-In erro inesperado: $e');
      rethrow;
    }
  }

  /// Revokes the app's Google authorization when a CashPath account is deleted.
  Future<void> disconnect() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_initialized) {
      await googleSignIn.initialize(serverClientId: googleServerClientId);
      _initialized = true;
    }
    await googleSignIn.disconnect();
  }
}
