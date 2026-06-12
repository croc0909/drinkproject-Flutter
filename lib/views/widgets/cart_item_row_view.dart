import 'package:flutter/material.dart';

import '../../models/cart_item.dart';

// CartItemRowView 顯示購物車裡的一筆項目。
class CartItemRowView extends StatelessWidget {
  const CartItemRowView({
    required this.item,
    super.key,
  });

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    // 使用 ListTile 呈現飲品名稱、數量和小計。
    return ListTile(
      title: Text(
        item.drink.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('數量 ${item.quantity}'),
      trailing: Text(
        r'$' '${item.subtotal}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
