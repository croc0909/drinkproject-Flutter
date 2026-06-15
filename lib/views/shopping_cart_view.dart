import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/drink_list_view_model.dart';
import 'widgets/cart_item_row_view.dart';

class ShoppingCartView extends ConsumerStatefulWidget {
  const ShoppingCartView({super.key});

  @override
  ConsumerState<ShoppingCartView> createState() => _ShoppingCartViewState();
}

class _ShoppingCartViewState extends ConsumerState<ShoppingCartView> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drinkListViewModelProvider);
    final viewModel = ref.read(drinkListViewModelProvider.notifier);

    if (_noteController.text != state.note) {
      _noteController.text = state.note;
    }

    if (state.didSubmitOrder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        viewModel.resetSubmitState();
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

    return Scaffold(
      appBar: AppBar(title: const Text('購物車')),
      body: state.cartItems.isEmpty
          ? const _EmptyCart()
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
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
                const _SectionHeader(title: '購物車'),
                ...state.cartItems.map(
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
                const _SectionHeader(title: '訂單資訊'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _noteController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '訂單備註'),
                    onChanged: viewModel.updateNote,
                  ),
                ),
                ListTile(
                  title: const Text('總計'),
                  trailing: Text(
                    '\$${state.totalPrice}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: state.cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: state.isLoading ? null : viewModel.submitOrder,
                  icon: state.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('送出訂單'),
                ),
              ),
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 58),
            SizedBox(height: 12),
            Text('購物車是空的'),
            SizedBox(height: 6),
            Text('回到飲料列表，點選 + 加入想喝的飲品。'),
          ],
        ),
      ),
    );
  }
}

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
