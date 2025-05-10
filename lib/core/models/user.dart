/// Model danych użytkownika
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool emailConfirmed;
  final List<String> providers;
  final Map<String, dynamic> userData;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.createdAt,
    this.lastSignInAt,
    this.emailConfirmed = false,
    this.providers = const [],
    required this.userData,
  });

  /// Zwraca imię i nazwisko użytkownika lub część adresu email przed @, jeśli fullName jest null
  String get displayName => fullName ?? email.split('@').first;

  /// Zwraca inicjał użytkownika (pierwszą literę imienia lub adresu email)
  String get initial =>
      (fullName?.isNotEmpty == true ? fullName!.substring(0, 1) : email.substring(0, 1)).toUpperCase();

  factory User.fromJson(Map<String, dynamic> json) {
    // Pobierz dane z user_metadata
    final userMetadata = json['user_metadata'] as Map<String, dynamic>? ?? {};

    // Pobierz dane z app_metadata
    final appMetadata = json['app_metadata'] as Map<String, dynamic>? ?? {};

    // Pobierz listę providerów
    List<String> providers = [];
    if (appMetadata.containsKey('providers') && appMetadata['providers'] is List) {
      providers = List<String>.from(appMetadata['providers']);
    } else if (appMetadata.containsKey('provider')) {
      providers = [appMetadata['provider']];
    }

    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: userMetadata['full_name'] ?? userMetadata['name'],
      avatarUrl: userMetadata['avatar_url'] ?? userMetadata['picture'],
      role: json['role'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      lastSignInAt: json['last_sign_in_at'] != null ? DateTime.parse(json['last_sign_in_at']) : null,
      emailConfirmed: json['email_confirmed_at'] != null || (userMetadata['email_verified'] == true),
      providers: providers,
      userData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'email_confirmed': emailConfirmed,
      'providers': providers,
      ...userData,
    };
  }
}
