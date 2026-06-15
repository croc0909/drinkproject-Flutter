import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drink_list_view.dart';
import 'member_view.dart';
import 'placeholder_feature_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = 0;

  static const _pages = [
    PlaceholderFeatureView(
      title: '商城兌換',
      icon: Icons.storefront,
      description: '未來可以放優惠券、點數兌換和會員好禮。',
    ),
    PlaceholderFeatureView(
      title: '最新消息',
      icon: Icons.newspaper,
      description: '未來可以放新品上市、活動公告和門市通知。',
    ),
    DrinkListView(),
    PlaceholderFeatureView(
      title: '附近門市',
      icon: Icons.location_on,
      description: '未來可以接地圖定位，顯示最近門市和營業資訊。',
    ),
    MemberView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '商城兌換',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: '最新消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: '點餐',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: '附近門市',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '會員專區',
          ),
        ],
      ),
    );
  }
}
