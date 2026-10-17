const productCategories = [
  'Tecnología',
  'Oficina',
  'Hogar',
  'Accesorios',
  'Otros',
];

class Product {
  const Product({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.stock,
    required this.category,
    this.imageBase64,
  });
  final String id;
  final String ownerId;
  final String name;
  final String description;
  // El dinero se almacena en céntimos para evitar errores de punto flotante.
  final int priceCents;
  final int stock;
  final String category;
  final String? imageBase64;

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'priceCents': priceCents,
    'stock': stock,
    'category': category,
    'imageBase64': imageBase64,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    priceCents: json['priceCents'] as int,
    stock: json['stock'] as int,
    category: json['category'] as String,
    imageBase64: json['imageBase64'] as String?,
  );
}
