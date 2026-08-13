/// Bearer token রাখার সবচেয়ে সহজ জায়গা।
/// প্রোডাকশনে এটাকে flutter_secure_storage দিয়ে backed করবেন —
/// কিন্তু interface (setToken/clearToken/token) একই থাকবে,
/// তাই বাকি কোড কিছুই বদলাবে না।
class AuthTokenStore {
  AuthTokenStore._();

  static String? _token;

  static String? get token => _token;

  static void setToken(String token) => _token = token;

  static void clearToken() => _token = null;
}
