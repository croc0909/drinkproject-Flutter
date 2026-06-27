import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/drink.dart';

// CartItemRowView 顯示購物車裡的一筆項目。
class CartItemRowView extends StatelessWidget {
  const CartItemRowView({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
    super.key,
  });

  static const _accentColor = Colors.orange;
  static const _textColor = Color(0xFF291F17);

  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _accentColor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DrinkImage(drink: item.drink),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 118,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.drink.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.drink.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: onRemove,
                        tooltip: '刪除 ${item.drink.name}',
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.delete_outline, size: 32),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '\$${item.subtotal}.00',
                        style: const TextStyle(
                          color: _accentColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _QuantityButton(
                        icon: Icons.remove,
                        tooltip: '減少數量',
                        onPressed: onDecrease,
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      _QuantityButton(
                        icon: Icons.add,
                        tooltip: '增加數量',
                        onPressed: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.orange.withValues(alpha: 0.10),
        foregroundColor: Colors.orange,
        fixedSize: const Size(36, 36),
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.20)),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _DrinkImage extends StatelessWidget {
  const _DrinkImage({required this.drink});

  final Drink drink;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 112,
        height: 112,
        child: _image,
      ),
    );
  }

  Widget get _image {
    final imageUrl = drink.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty && _isNetworkUrl(imageUrl)) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage,
      );
    }

    return _assetImage;
  }

  Widget get _assetImage {
    return Image.asset(
      _assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder,
    );
  }

  Widget get _placeholder {
    return Container(
      color: Colors.orange.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe,
        size: 34,
        color: Colors.orange,
      ),
    );
  }

  String get _assetPath {
    switch (drink.id) {
      case 1:
        return 'assets/images/BubbleTea.jpg';
      case 2:
        return 'assets/images/FourSeasons GreenTea.jpg';
      case 3:
        return 'assets/images/LemonWinterMelon.jpg';
      default:
        return 'assets/images/${drink.name}.jpg';
    }
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
