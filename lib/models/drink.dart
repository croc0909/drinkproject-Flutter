// Drink 是飲品資料模型，對應 Swift 裡的 struct Drink: Codable。
class Drink {
  const Drink({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;

  // 把後端回傳的 JSON 轉成 Dart 的 Drink 物件。
  // Go 後端使用 snake_case，例如 image_url、is_available。
  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      isAvailable: json['is_available'] as bool,
    );
  }

  // 把 Drink 物件轉回 JSON Map。
  // 目前主要保留給之後若需要送飲品資料到後端時使用。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
    };
  }

  // 後端尚未啟動或 API 失敗時顯示的範例資料。
  static const samples = [
    Drink(
      id: 1,
      name: '珍珠奶茶',
      description: '經典奶茶搭配 Q 彈珍珠。',
      price: 65,
      category: '人氣',
      isAvailable: true,
    ),
    Drink(
      id: 2,
      name: '四季春青茶',
      description: '清香回甘，適合無糖或微糖。',
      price: 40,
      category: '茶飲',
      isAvailable: true,
    ),
    Drink(
      id: 3,
      name: '檸檬冬瓜',
      description: '酸甜清爽，夏天很可以。',
      price: 55,
      category: '特調',
      isAvailable: true,
    ),
  ];
}
