import 'package:flutter/material.dart';

import '../../models/drink.dart';

// DrinkRowView 顯示單一飲品列。
// 它只負責畫面，不負責修改購物車；加入購物車的動作由外面傳進來。
class DrinkRowView extends StatelessWidget {
  const DrinkRowView({
    required this.drink,
    required this.onAdd,
    super.key,
  });

  final Drink drink;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // 從目前主題取色彩設定。
    final colorScheme = Theme.of(context).colorScheme;

    // ListTile 是 Flutter 常用的列表列元件。
    return ListTile(
      minVerticalPadding: 10,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF7A4A2A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.local_cafe,
          color: Color(0xFF7A4A2A),
        ),
      ),
      title: Row(
        children: [
          // Expanded 讓飲品名稱佔據剩餘空間，避免和價格擠在一起。
          Expanded(
            child: Text(
              drink.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            r'$' '${drink.price}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          // 讓描述、分類、暫停供應文字靠左排列。
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(drink.description),
            const SizedBox(height: 4),
            Text(drink.category),
            if (!drink.isAvailable) ...[
              const SizedBox(height: 4),
              Text(
                '暫停供應',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      trailing: IconButton(
        // 如果飲品暫停供應，onPressed 設成 null，按鈕會自動變成 disabled。
        onPressed: drink.isAvailable ? onAdd : null,
        tooltip: '加入 ${drink.name}',
        icon: const Icon(Icons.add_circle),
      ),
    );
  }
}
