import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/home_view.dart';

// Flutter App 的入口點，類似 SwiftUI 專案裡的 @main App。
void main() {
  // ProviderScope 是 Riverpod 的最外層容器。
  // 所有 Riverpod Provider 都需要放在 ProviderScope 底下才能被讀取。
  runApp(const ProviderScope(child: DrinkOrderingApp()));
}

// App 最外層的 Widget。
// StatelessWidget 代表這個 Widget 本身不保存會變動的狀態。
class DrinkOrderingApp extends StatelessWidget {
  const DrinkOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 是整個 Flutter App 的外殼，負責主題、首頁、導航等設定。
    return MaterialApp(
      title: '飲料訂購',
      // 關閉 Debug 模式右上角的 DEBUG 標籤。
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14336F),
        ),
        useMaterial3: true,
      ),
      // App 啟動後第一個顯示的畫面。
      home: const HomeView(),
    );
  }
}
