class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // 'Suplementos', 'Accesorios', 'Ropa', 'Equipamiento'
  final String imageUrl;
  final double rating;
  final int stock;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rating = 4.8,
    this.stock = 25,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'stock': stock,
      'isFeatured': isFeatured,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ProductModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      stock: (map['stock'] as num?)?.toInt() ?? 10,
      isFeatured: map['isFeatured'] ?? false,
    );
  }
}
