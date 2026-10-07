import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Sesión con la cuenta de WordPress del CISNA mediante una **contraseña de aplicación** (incluida en WordPress,
/// revocable desde el perfil, distinta de la contraseña normal). Solo sirve para dar órdenes al secador.
class AuthSession {
  const AuthSession({required this.user, required this.displayName, required this.header, required this.canControl});
  final String user, displayName, header;
  /// `manage_secador` («Gestor del Secador») o administrador: lo mismo que exige el backend para los actuadores.
  final bool canControl;
}

/// Dónde se guardan las credenciales si la persona pidió «Recordarme en este equipo» (cifrado del sistema).
abstract class CredentialStore {
  Future<(String, String)?> read();
  Future<void> write(String user, String password);
  Future<void> clear();
}

class SecureCredentialStore implements CredentialStore {
  const SecureCredentialStore();
  static const _s = FlutterSecureStorage();
  @override
  Future<(String, String)?> read() async {
    final u = await _s.read(key: 'wp_user'), p = await _s.read(key: 'wp_app_password');
    return u == null || p == null ? null : (u, p);
  }
  @override
  Future<void> write(String user, String password) async {
    await _s.write(key: 'wp_user', value: user);
    await _s.write(key: 'wp_app_password', value: password);
  }
  @override
  Future<void> clear() => _s.deleteAll();
}

class MemoryCredentialStore implements CredentialStore {
  (String, String)? saved;
  @override
  Future<(String, String)?> read() async => saved;
  @override
  Future<void> write(String user, String password) async => saved = (user, password);
  @override
  Future<void> clear() async => saved = null;
}

class AuthController extends ChangeNotifier {
  AuthController({http.Client? client, CredentialStore? store, this.site = 'https://cisna.narino.gov.co'})
      : _client = client ?? http.Client(), store = store ?? const SecureCredentialStore();
  final http.Client _client;
  final CredentialStore store;
  final String site;

  AuthSession? session;
  bool busy = false;

  /// Página de WordPress donde la persona crea su contraseña de aplicación para SISCAN.
  Uri get authorizeUrl => Uri.parse('$site/wp-admin/authorize-application.php?app_name=${Uri.encodeComponent('SISCAN móvil')}');

  /// Verifica las credenciales con WordPress. Devuelve `null` si entra, o el motivo en palabras de la persona.
  Future<String?> signIn(String user, String appPassword, {bool remember = false}) async {
    final u = user.trim(), p = appPassword.replaceAll(' ', '').trim();
    if (u.isEmpty || p.isEmpty) return 'Escribe tu usuario y tu contraseña de aplicación.';
    busy = true;
    notifyListeners();
    try {
      final header = 'Basic ${base64Encode(utf8.encode('$u:$p'))}';
      final r = await _client.get(Uri.parse('$site/wp-json/wp/v2/users/me?context=edit'), headers: {'Authorization': header}).timeout(const Duration(seconds: 15));
      if (r.statusCode == 401 || r.statusCode == 403) return 'El usuario o la contraseña de aplicación no son correctos.';
      if (r.statusCode != 200) return 'No pudimos verificar tu cuenta. Intenta nuevamente.';
      final me = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final caps = (me['capabilities'] as Map?)?.cast<String, dynamic>() ?? const {};
      final can = caps['manage_secador'] == true || caps['manage_options'] == true;
      session = AuthSession(user: u, displayName: (me['name'] as String?) ?? u, header: header, canControl: can);
      if (remember) await store.write(u, p);
      return can ? null : 'Tu cuenta no tiene permiso de «Gestor del Secador». Pídelo al CISNA.';
    } catch (_) {
      return 'No pudimos conectarnos. Verifica la conexión e intenta nuevamente.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    final saved = await store.read();
    if (saved != null) await signIn(saved.$1, saved.$2);
  }

  Future<void> signOut() async {
    session = null;
    await store.clear();
    notifyListeners();
  }
}
