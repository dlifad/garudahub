class MerchandiseModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final String sizes;
  final String shopeeUrl;
  final String imageUrl;

  MerchandiseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sizes,
    required this.shopeeUrl,
    required this.imageUrl,
  });

  factory MerchandiseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toInt(),
      sizes: json['sizes'] ?? '',
      shopeeUrl: json['shopee_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}