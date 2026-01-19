class Volunteer {
  final String? id;
  final String name;
  final String email;
  final String phone;

  const Volunteer({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  Volunteer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return Volunteer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
