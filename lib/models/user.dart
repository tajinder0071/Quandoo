class UserModel {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'password_hash': passwordHash,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'] as int?,
    name: m['name'] as String,
    email: m['email'] as String,
    passwordHash: m['password_hash'] as String,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  UserModel copyWith({int? id, String? name, String? email}) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    passwordHash: passwordHash,
    createdAt: createdAt,
  );
}
