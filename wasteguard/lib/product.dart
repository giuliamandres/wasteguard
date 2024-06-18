class Product {
  String id;
  final String name;
  final String imageUrl;
  DateTime expiryDate;
  bool expired = false;
  final String userId;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.expiryDate,
    this.expired = false,
    required this.userId,

  });

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'image' : imageUrl,
    'expiryDate' : expiryDate.millisecondsSinceEpoch,
    'expired' : expired,
    'userId' : userId
  };

  factory Product.fromJson(Map<dynamic, dynamic> json) => Product(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    imageUrl: json['image'] ?? '',
    expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiryDate'] as int),
    expired: json['expired'] ?? false,
    userId: json['userId'] ?? ''
  );
}