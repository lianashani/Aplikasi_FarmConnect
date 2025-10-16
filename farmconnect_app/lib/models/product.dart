class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final int? userId;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.userId,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] is int ? j['id'] as int : int.parse(j['id'].toString()),
        name: j['name'] as String,
        description: j['description'] as String?,
        price: j['price'] is num
            ? (j['price'] as num).toDouble()
            : double.parse(j['price'].toString()),
        stock: j['stock'] is int
            ? j['stock'] as int
            : int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
        imageUrl: j['image_url'] as String?,
        userId: j['user_id'] == null
            ? null
            : (j['user_id'] is int
                ? j['user_id'] as int
                : int.tryParse(j['user_id'].toString())),
      );
}
