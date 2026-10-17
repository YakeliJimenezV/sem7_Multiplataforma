class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.salt,
    required this.iterations,
  });
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final String salt;
  final int iterations;

  AppUser withProfile(String name, String phone) => AppUser(
    id: id,
    name: name,
    email: email,
    phone: phone,
    passwordHash: passwordHash,
    salt: salt,
    iterations: iterations,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'passwordHash': passwordHash,
    'salt': salt,
    'iterations': iterations,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    passwordHash: json['passwordHash'] as String,
    salt: json['salt'] as String,
    iterations: json['iterations'] as int,
  );
}
