import 'drink.dart';

// CartItem 是購物車裡的一筆項目。
// 它包含一個飲品 Drink，以及使用者加入的數量。
class CartItem {
  CartItem({
    String? id,
    required this.drink,
    required this.quantity,
    // 用目前時間產生簡單唯一 id，讓畫面刪除或列表辨識每一列。
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final Drink drink;
  int quantity;

  // 小計 = 飲品單價 * 數量。
  int get subtotal => drink.price * quantity;

  // Riverpod 建議狀態更新時建立新物件，而不是直接修改原物件。
  // copyWith 讓我們可以保留原本 id 和 drink，只改 quantity。
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      drink: drink,
      quantity: quantity ?? this.quantity,
    );
  }
}
