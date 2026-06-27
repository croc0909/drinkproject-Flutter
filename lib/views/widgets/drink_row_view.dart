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
    const accentColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DrinkImage(drink: drink),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  drink.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${drink.price}.00',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: accentColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: drink.isAvailable ? onAdd : null,
                      tooltip: '加入 ${drink.name}',
                      style: IconButton.styleFrom(
                        backgroundColor: accentColor,
                        disabledBackgroundColor:
                            accentColor.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.85),
                        fixedSize: const Size(34, 34),
                        minimumSize: const Size(34, 34),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.add, size: 26),
                    ),
                  ],
                ),
                if (!drink.isAvailable) ...[
                  const SizedBox(height: 4),
                  Text(
                    '暫停供應',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
        width: 150,
        height: 150,
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
      color: const Color(0xFFFFE7CC),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe,
        size: 42,
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
