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
  static const _backgroundColor = Color(0xFFFFF7EB);
  static const _accentColor = Colors.orange;

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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: _backgroundColor,
        centerTitle: true,
        title: const Text('購物車'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: state.cartItems.isEmpty
          ? _EmptyCart(errorMessage: state.errorMessage)
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 18,
              ),
              children: [
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: _accentColor,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ...state.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                    child: CartItemRowView(
                      item: item,
                      onDecrease: () => viewModel.decreaseQuantity(item),
                      onIncrease: () => viewModel.increaseQuantity(item),
                      onRemove: () => viewModel.removeFromCart(item),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 32, 18, 18),
                  child: Text(
                    '訂單資訊',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _OrderInfoSection(
                  controller: _noteController,
                  totalPrice: state.totalPrice,
                  onNoteChanged: viewModel.updateNote,
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(62),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: state.isLoading ? null : viewModel.submitOrder,
                    icon: state.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 28),
                    label: const Text(
                      '送出訂單',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _OrderInfoSection extends StatelessWidget {
  const _OrderInfoSection({
    required this.controller,
    required this.totalPrice,
    required this.onNoteChanged,
  });

  final TextEditingController controller;
  final int totalPrice;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '訂單備註',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 22,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: onNoteChanged,
          ),
          Divider(height: 28, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                const Text(
                  '總計',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$$totalPrice',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 24),
            ],
            Icon(
              Icons.shopping_cart_outlined,
              size: 58,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            const Text(
              '購物車是空的',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '回到飲料列表，點選 + 加入想喝的飲品。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
