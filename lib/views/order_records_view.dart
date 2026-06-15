import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../viewmodels/order_records_view_model.dart';
import 'order_details_view.dart';

class OrderRecordsView extends ConsumerStatefulWidget {
  const OrderRecordsView({super.key});

  @override
  ConsumerState<OrderRecordsView> createState() => _OrderRecordsViewState();
}

class _OrderRecordsViewState extends ConsumerState<OrderRecordsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(orderRecordsViewModelProvider.notifier).loadOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderRecordsViewModelProvider);
    final viewModel = ref.read(orderRecordsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('訂單紀錄')),
      body: RefreshIndicator(
        onRefresh: viewModel.refreshOrders,
        child: _content(context, state),
      ),
    );
  }

  Widget _content(BuildContext context, OrderRecordsState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.error_outline,
            size: 54,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    if (state.orders.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Icon(Icons.receipt_long_outlined, size: 54),
          SizedBox(height: 12),
          Center(child: Text('尚無訂單紀錄')),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        return _OrderRecordCard(order: state.orders[index]);
      },
    );
  }
}

class _OrderRecordCard extends StatelessWidget {
  const _OrderRecordCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '訂單編號 ${order.displayOrderNo}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  label: Text(order.statusText),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(order.createdAtText),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.local_cafe, size: 18),
                const SizedBox(width: 6),
                Text('共 ${order.totalQuantity} 件商品'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 18),
                Text('${order.totalPrice}'),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrderDetailsView(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.manage_search),
              label: const Text('查看明細'),
            ),
          ],
        ),
      ),
    );
  }
}
