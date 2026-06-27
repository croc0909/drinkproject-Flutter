import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/drink_list_view_model.dart';
import 'shopping_cart_view.dart';
import 'widgets/drink_row_view.dart';

// DrinkListView 是主畫面，也就是使用者看到的飲料訂購頁。
class DrinkListView extends ConsumerStatefulWidget {
  const DrinkListView({super.key});

  @override
  ConsumerState<DrinkListView> createState() => _DrinkListViewState();
}

// StatefulWidget 的狀態類別。
// 這裡需要 TextEditingController，所以使用 StatefulWidget。
// ConsumerState 讓我們可以使用 ref.watch / ref.read 讀取 Riverpod Provider。
class _DrinkListViewState extends ConsumerState<DrinkListView> {
  @override
  void initState() {
    super.initState();

    // 畫面建立後載入飲品。
    // Future.microtask 避免在 initState 同步修改 Riverpod state。
    Future.microtask(
      () => ref.read(drinkListViewModelProvider.notifier).loadDrinks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch 代表監聽 Riverpod 狀態。
    // ViewModel 更新 state 時，這個畫面會重新 build。
    final state = ref.watch(drinkListViewModelProvider);
    // notifier 是真正的 ViewModel，用來呼叫方法。
    final viewModel = ref.read(drinkListViewModelProvider.notifier);

    // 如果 ViewModel 標記訂單已送出，顯示提示對話框。
    if (state.didSubmitOrder) {
      // addPostFrameCallback 代表等這次畫面 build 完，再顯示 Dialog。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(drinkListViewModelProvider.notifier).resetSubmitState();
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('訂單已送出'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('完成'),
                ),
              ],
            );
          },
        );
      });
    }

    // Scaffold 是 Material App 常用的頁面骨架，包含 AppBar 和 body。
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text('飲料訂購'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Stack(
        children: [
          // RefreshIndicator 提供下拉重新整理。
          RefreshIndicator(
            onRefresh: viewModel.loadDrinks,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // 如果有錯誤訊息，就顯示在列表上方。
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                // 將每一個 Drink 轉成一列 DrinkRowView。
                ...state.drinks.map(
                  (drink) => Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 28, 10),
                    child: DrinkRowView(
                      drink: drink,
                      onAdd: () => viewModel.addToCart(drink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // isLoading 為 true 時，蓋上一層半透明 loading 畫面。
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.08),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('載入飲品中'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: state.cartItems.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShoppingCartView(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        '購物車',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${state.totalQuantity} 項・\$${state.totalPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
