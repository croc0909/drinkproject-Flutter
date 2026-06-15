import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({
    required this.order,
    super.key,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('訂單明細')),
      body: ListView(
        children: [
          const _SectionHeader(title: '訂單資訊'),
          _DetailRow(title: '訂單編號', value: order.displayOrderNo),
          _DetailRow(title: '訂單狀態', value: order.statusText),
          _DetailRow(title: '訂購時間', value: order.createdAtText),
          _DetailRow(title: '訂購人', value: order.customerName),
          _DetailRow(title: '手機號碼', value: order.phone),
          const _SectionHeader(title: '商品明細'),
          ...order.items.map(_OrderItemTile.new),
          const Divider(height: 32),
          ListTile(
            title: Text('共 ${order.totalQuantity} 件商品'),
            trailing: Text(
              '總計 \$${order.totalPrice}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile(this.item);

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.displayName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${item.sweetness} / ${item.iceLevel}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('x${item.quantity}'),
          Text('小計 \$${item.displaySubtotal}'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, textAlign: TextAlign.end),
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
