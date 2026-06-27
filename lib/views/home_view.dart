import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'drink_list_view.dart';
import 'member_view.dart';
import 'placeholder_feature_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _homeImages = [
    'assets/images/homeimage1.jpg',
    'assets/images/homeimage2.jpg',
    'assets/images/homeimage3.jpg',
    'assets/images/homeimage4.jpg',
    'assets/images/homeimage5.jpg',
  ];

  Timer? _timer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _homeImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openTab(HomeTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => tab.destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Image.asset(
              _homeImages[_currentImageIndex],
              key: ValueKey(_currentImageIndex),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          const _HomeGradientOverlay(),
          const _HomeHeroText(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _HomeShortcutBar(onSelected: _openTab),
          ),
        ],
      ),
    );
  }
}

class _HomeGradientOverlay extends StatelessWidget {
  const _HomeGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x0A000000),
            Color(0x2E000000),
            Color(0xB8000000),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroText extends StatelessWidget {
  const _HomeHeroText();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 28,
      right: 28,
      bottom: 192 + bottomPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your\nHealthy\nStart',
            style: TextStyle(
              color: Colors.white,
              fontSize: _heroTitleSize(context),
              fontWeight: FontWeight.w900,
              height: 1.03,
              shadows: const [
                Shadow(
                  color: Color(0x38000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ready to take control of your health? Just a few simple steps to begin.',
            style: TextStyle(
              color: Color(0xEBFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.26,
              shadows: [
                Shadow(
                  color: Color(0x38000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _heroTitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 56;
    if (width < 420) return 62;
    return 66;
  }
}

enum HomeTab {
  exchange,
  news,
  order,
  nearby,
  member;

  String get title {
    switch (this) {
      case HomeTab.exchange:
        return '商城兌換';
      case HomeTab.news:
        return '最新消息';
      case HomeTab.order:
        return '點餐';
      case HomeTab.nearby:
        return '附近門市';
      case HomeTab.member:
        return '會員專區';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeTab.exchange:
        return Icons.storefront;
      case HomeTab.news:
        return Icons.newspaper;
      case HomeTab.order:
        return Icons.shopping_bag;
      case HomeTab.nearby:
        return Icons.location_on;
      case HomeTab.member:
        return Icons.person;
    }
  }

  Widget get destination {
    switch (this) {
      case HomeTab.exchange:
        return const PlaceholderFeatureView(
          title: '商城兌換',
          icon: Icons.storefront,
          description: '未來可以放優惠券、點數兌換和會員好禮。',
        );
      case HomeTab.news:
        return const PlaceholderFeatureView(
          title: '最新消息',
          icon: Icons.newspaper,
          description: '未來可以放新品上市、活動公告和門市通知。',
        );
      case HomeTab.order:
        return const DrinkListView();
      case HomeTab.nearby:
        return const PlaceholderFeatureView(
          title: '附近門市',
          icon: Icons.location_on,
          description: '未來可以接地圖定位，顯示最近門市和營業資訊。',
        );
      case HomeTab.member:
        return const MemberView();
    }
  }
}

class _HomeShortcutBar extends StatelessWidget {
  const _HomeShortcutBar({required this.onSelected});

  static const _selectedTab = HomeTab.order;
  static const _selectedOrange = Color(0xFFFF8729);

  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxWidth / 362).clamp(0.82, 1.0);

                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final tab in HomeTab.values) ...[
                          _ShortcutItem(
                            tab: tab,
                            isSelected: tab == _selectedTab,
                            selectedColor: _selectedOrange,
                            scale: scale,
                            onTap: () => onSelected(tab),
                          ),
                          if (tab != HomeTab.values.last)
                            const SizedBox(width: 7),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.tab,
    required this.isSelected,
    required this.selectedColor,
    required this.scale,
    required this.onTap,
  });

  final HomeTab tab;
  final bool isSelected;
  final Color selectedColor;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (isSelected ? 112.0 : 56.0) * scale;
    final height = (isSelected ? 62.0 : 56.0) * scale;

    return Semantics(
      button: true,
      label: tab.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor
                  : Colors.white.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(999),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.38)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.34),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? _SelectedShortcutContent(tab: tab)
                : Icon(tab.icon),
          ),
        ),
      ),
    );
  }
}

class _SelectedShortcutContent extends StatelessWidget {
  const _SelectedShortcutContent({required this.tab});

  final HomeTab tab;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tab.icon, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            tab.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
