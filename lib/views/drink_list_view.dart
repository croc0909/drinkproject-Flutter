import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/drink_list_view_model.dart';
import 'widgets/cart_item_row_view.dart';
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
  // 控制訂單備註輸入框的文字。
  final TextEditingController _noteController = TextEditingController();

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
  void dispose() {
    // Widget 被銷毀時釋放 controller，避免記憶體洩漏。
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch 代表監聽 Riverpod 狀態。
    // ViewModel 更新 state 時，這個畫面會重新 build。
    final state = ref.watch(drinkListViewModelProvider);
    // notifier 是真正的 ViewModel，用來呼叫方法。
    final viewModel = ref.read(drinkListViewModelProvider.notifier);

    // 當 ViewModel 清空 note 時，同步清空輸入框。
    if (_noteController.text != state.note) {
      _noteController.text = state.note;
    }

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
      appBar: AppBar(
        title: const Text('飲料訂購'),
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const _SectionHeader(title: '飲品'),
                // 將每一個 Drink 轉成一列 DrinkRowView。
                ...state.drinks.map(
                  (drink) => DrinkRowView(
                    drink: drink,
                    onAdd: () => viewModel.addToCart(drink),
                  ),
                ),
                // 只有購物車有資料時才顯示購物車區塊。
                if (state.cartItems.isNotEmpty) ...[
                  const _SectionHeader(title: '購物車'),
                  ...state.cartItems.map(
                    // Dismissible 讓使用者可以滑動刪除購物車項目。
                    (item) => Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red.shade600,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => viewModel.removeFromCart(item),
                      child: CartItemRowView(item: item),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _noteController,
                      // 最少一行，最多三行。
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '訂單備註'),
                      onChanged: viewModel.updateNote,
                    ),
                  ),
                  ListTile(
                    title: const Text('總計'),
                    trailing: Text(
                      // r'$' 避免 $ 被 Dart 當成字串插值符號。
                      r'$'
                      '${state.totalPrice}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilledButton.icon(
                      // 按下按鈕後交給 ViewModel 送出訂單。
                      onPressed: viewModel.submitOrder,
                      icon: const Icon(Icons.send),
                      label: const Text('送出訂單'),
                    ),
                  ),
                ],
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
    );
  }
}

// 區塊標題，例如「飲品」、「購物車」。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
