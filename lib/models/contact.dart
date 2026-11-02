class Contact {
  int? id;
  String name;
  String phone;
  String email;
  String address;
  bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.isFavorite = false,
  });

  // Convert Contact -> Map (to save in database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  // Convert Map -> Contact (when reading from database)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
