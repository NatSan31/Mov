class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String authProvider; // 'password', 'google.com', 'github.com'
  final bool emailVerified;
  final String subscriptionTier; // 'none', 'basic', 'pro', 'black_vip'
  final DateTime? memberSince;
  final List<String> subscribedTopics;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.authProvider,
    required this.emailVerified,
    this.subscriptionTier = 'none',
    this.memberSince,
    this.subscribedTopics = const [],
  });

  /// Regla del proyecto: La edición de foto está permitida ÚNICAMENTE para cuentas vía email/password
  bool get canEditProfilePhoto => authProvider == 'password';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'emailVerified': emailVerified,
      'subscriptionTier': subscriptionTier,
      'memberSince': memberSince?.toIso8601String(),
      'subscribedTopics': subscribedTopics,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Usuario FitPulse',
      photoUrl: map['photoUrl'] ?? '',
      authProvider: map['authProvider'] ?? 'password',
      emailVerified: map['emailVerified'] ?? false,
      subscriptionTier: map['subscriptionTier'] ?? 'none',
      memberSince: map['memberSince'] != null ? DateTime.tryParse(map['memberSince']) : null,
      subscribedTopics: List<String>.from(map['subscribedTopics'] ?? []),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? authProvider,
    bool? emailVerified,
    String? subscriptionTier,
    DateTime? memberSince,
    List<String>? subscribedTopics,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      emailVerified: emailVerified ?? this.emailVerified,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      memberSince: memberSince ?? this.memberSince,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    );
  }
}
