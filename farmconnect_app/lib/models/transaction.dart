class AppTransaction {
  final int id;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String status;
  final String? productName;

  AppTransaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.productName,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> j) => AppTransaction(
        id: j['id'] is int ? j['id'] as int : int.parse(j['id'].toString()),
        productId: j['product_id'] is int
            ? j['product_id'] as int
            : int.parse(j['product_id'].toString()),
        quantity: j['quantity'] is int
            ? j['quantity'] as int
            : int.parse(j['quantity'].toString()),
        totalPrice: j['total_price'] is num
            ? (j['total_price'] as num).toDouble()
            : double.parse(j['total_price'].toString()),
        status: (j['status'] ?? '').toString(),
        productName: (j['product'] != null)
            ? j['product']['name'] as String?
            : null,
      );
}
