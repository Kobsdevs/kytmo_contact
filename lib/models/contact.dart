class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? company;
  final String? address;
  final bool favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.address,
    this.favorite = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Fabrique un contact "vide" (utile pour EditContactScreen)
  factory Contact.create({
    String name = '',
    String phone = '',
    String? email,
    String? company,
    String? address,
    bool favorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Contact(
      id: null, // laissé à null pour laisser SQLite auto-incrémenter
      name: name,
      phone: phone,
      email: email,
      company: company,
      address: address,
      favorite: favorite,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Clone avec modifications (pratique pour l’édition)
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? company,
    String? address,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      address: address ?? this.address,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
        id: m['id'] as int?,
        name: m['name'] as String,
        phone: m['phone'] as String,
        email: m['email'] as String?,
        company: m['company'] as String?,
        address: m['address'] as String?,
        favorite: (m['favorite'] ?? 0) == 1,
        createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
        updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
      );

  Map<String, dynamic> toMap({bool forInsert = false}) {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'address': address,
      'favorite': favorite ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    if (forInsert) map.remove('id'); // utile si id AUTOINCREMENT
    return map;
  }
}