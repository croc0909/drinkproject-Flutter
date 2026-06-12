// Order 是後端建立訂單後回傳的完整訂單資料。
class Order {
  const Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.items,
    required this.totalPrice,
    this.status,
    this.createdAt,
  });

  final int id;
  final String customerName;
  final String phone;
  final List<OrderItem> items;
  final int totalPrice;
  final String? status;
  final String? createdAt;

  // 把後端回傳的訂單 JSON 轉成 Order 物件。
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      customerName: json['customer_name'] as String,
      phone: json['phone'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: json['total_price'] as int,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

// OrderItem 是訂單裡的單一飲品項目。
// 這通常是後端回傳訂單明細時使用。
class OrderItem {
  const OrderItem({
    required this.drinkId,
    required this.quantity,
    required this.sweetness,
    required this.iceLevel,
    this.drinkName,
    this.unitPrice,
    this.subtotal,
  });

  final int drinkId;
  final String? drinkName;
  final int quantity;
  final String sweetness;
  final String iceLevel;
  final int? unitPrice;
  final int? subtotal;

  // 把後端回傳的訂單項目 JSON 轉成 OrderItem。
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      drinkId: json['drink_id'] as int,
      drinkName: json['drink_name'] as String?,
      quantity: json['quantity'] as int,
      sweetness: json['sweetness'] as String,
      iceLevel: json['ice_level'] as String,
      unitPrice: json['unit_price'] as int?,
      subtotal: json['subtotal'] as int?,
    );
  }
}

// CreateOrderRequest 是送出訂單時要傳給後端的資料。
// 它和 Order 不同：Order 是後端回傳，CreateOrderRequest 是前端送出。
class CreateOrderRequest {
  const CreateOrderRequest({
    required this.customerName,
    required this.phone,
    required this.items,
  });

  final String customerName;
  final String phone;
  final List<CreateOrderItemRequest> items;

  // 把送出訂單的資料轉成後端需要的 JSON 格式。
  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'phone': phone,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

// CreateOrderItemRequest 是送出訂單時的單一飲品項目。
class CreateOrderItemRequest {
  const CreateOrderItemRequest({
    required this.drinkId,
    required this.quantity,
    required this.sweetness,
    required this.iceLevel,
  });

  final int drinkId;
  final int quantity;
  final String sweetness;
  final String iceLevel;

  // 後端欄位使用 snake_case，所以這裡轉成 drink_id、ice_level。
  Map<String, dynamic> toJson() {
    return {
      'drink_id': drinkId,
      'quantity': quantity,
      'sweetness': sweetness,
      'ice_level': iceLevel,
    };
  }
}
