import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import 'drink_list_view_model.dart';
import 'member_view_model.dart';

final orderRecordsViewModelProvider =
    NotifierProvider<OrderRecordsViewModel, OrderRecordsState>(
  OrderRecordsViewModel.new,
);

class OrderRecordsState {
  const OrderRecordsState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Order> orders;
  final bool isLoading;
  final String? errorMessage;

  OrderRecordsState copyWith({
    List<Order>? orders,
    bool? isLoading,
    Object? errorMessage = _unchanged,
  }) {
    return OrderRecordsState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unchanged
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class OrderRecordsViewModel extends Notifier<OrderRecordsState> {
  @override
  OrderRecordsState build() {
    return const OrderRecordsState();
  }

  Future<void> loadOrders() async {
    if (state.isLoading) return;

    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(authTokenKey);
    if (token == null || token.isEmpty) {
      state = const OrderRecordsState(
        errorMessage: '請先登入會員後再查看訂單紀錄。',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final orders = await ref.read(apiClientProvider).fetchOrders(
            token: token,
          );
      orders.sort((left, right) => right.id.compareTo(left.id));
      state = state.copyWith(orders: orders);
    } catch (error) {
      debugPrint('[OrderRecordsViewModel] load failed: $error');
      state = state.copyWith(orders: [], errorMessage: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshOrders() async {
    state = state.copyWith(isLoading: false);
    await loadOrders();
  }
}

const Object _unchanged = Object();
