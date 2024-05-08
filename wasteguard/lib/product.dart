class Product {
  String id;
  final String name;
  final String imageUrl;
  final DateTime expiryDate;
  bool expired = false;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.expiryDate,
    this.expired = false,
  });

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'image' : imageUrl,
    'expiryDate' : expiryDate.millisecondsSinceEpoch,
    'expired' : expired,
  };

  factory Product.fromJson(Map<dynamic, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['image'] as String,
    expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiryDate'] as int),
    expired: json['expired'] as bool
  );
}