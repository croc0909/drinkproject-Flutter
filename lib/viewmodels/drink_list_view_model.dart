import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/drink.dart';
import '../models/order.dart';
import '../services/api_client.dart';
import 'member_view_model.dart';

// ApiClient 的 Riverpod Provider。
// ViewModel 可以透過 ref.read(apiClientProvider) 取得 API 服務。
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// DrinkListViewModel 的 Riverpod Provider。
// NotifierProvider 會提供兩種東西：
// 1. DrinkListState：給 View 顯示畫面
// 2. DrinkListViewModel：給 View 呼叫方法，例如 addToCart、submitOrder
final drinkListViewModelProvider =
    NotifierProvider<DrinkListViewModel, DrinkListState>(
  DrinkListViewModel.new,
);

// Riverpod 版本的畫面狀態。
// 以前 ChangeNotifier 直接把 drinks、isLoading 放在 ViewModel 裡；
// Riverpod 更常見的做法是把所有畫面狀態集中成一個不可變物件。
class DrinkListState {
  const DrinkListState({
    this.drinks = const [],
    this.cartItems = const [],
    this.note = '',
    this.isLoading = false,
    this.errorMessage,
    this.didSubmitOrder = false,
  });

  final List<Drink> drinks;
  final List<CartItem> cartItems;
  final String note;
  final bool isLoading;
  final String? errorMessage;
  final bool didSubmitOrder;

  // 購物車總金額。
  int get totalPrice {
    return cartItems.fold(0, (total, item) => total + item.subtotal);
  }

  int get totalQuantity {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  // 建立一份新狀態。
  // Riverpod 的狀態更新通常不是修改原物件，而是產生新的 state。
  DrinkListState copyWith({
    List<Drink>? drinks,
    List<CartItem>? cartItems,
    String? note,
    bool? isLoading,
    Object? errorMessage = _unchanged,
    bool? didSubmitOrder,
  }) {
    return DrinkListState(
      drinks: drinks ?? this.drinks,
      cartItems: cartItems ?? this.cartItems,
      note: note ?? this.note,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unchanged
          ? this.errorMessage
          : errorMessage as String?,
      didSubmitOrder: didSubmitOrder ?? this.didSubmitOrder,
    );
  }
}

// copyWith 用的特殊標記。
// 因為 errorMessage 可能要設定成 null，所以需要分辨「不改」和「改成 null」。
const Object _unchanged = Object();

// DrinkListViewModel 是這個畫面的 ViewModel。
// Riverpod 版使用 Notifier<DrinkListState>，不再 extends ChangeNotifier。
class DrinkListViewModel extends Notifier<DrinkListState> {
  late final ApiClient _apiClient;

  @override
  DrinkListState build() {
    // ref 是 Riverpod 提供的讀取工具，類似以前 Provider 的 context.read。
    _apiClient = ref.read(apiClientProvider);
    return const DrinkListState();
  }

  // 載入飲品資料。
  // 成功時使用後端資料，失敗時使用 Drink.samples 範例資料。
  Future<void> loadDrinks() async {
    _log('loadDrinks -> start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fetchedDrinks = await _apiClient.fetchDrinks();
      _log('loadDrinks <- backend success, drinks: ${fetchedDrinks.length}');
      state = state.copyWith(drinks: fetchedDrinks);
    } catch (error) {
      _log('loadDrinks <- backend failed, use samples. error: $error');
      state = state.copyWith(
        drinks: Drink.samples,
        errorMessage: '目前使用範例資料，請確認 Go 後端是否已啟動。',
      );
    } finally {
      state = state.copyWith(isLoading: false);
      _log('loadDrinks -> finished, showing ${state.drinks.length} drinks');
    }
  }

  // 將飲品加入購物車。
  // 如果購物車已經有同一個飲品，就建立一筆數量 +1 的新 CartItem。
  void addToCart(Drink drink) {
    _log('addToCart -> ${drink.name}, id: ${drink.id}');
    final cartItems = [...state.cartItems];
    final index = cartItems.indexWhere((item) => item.drink.id == drink.id);

    if (index >= 0) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      cartItems.add(CartItem(drink: drink, quantity: 1));
    }

    state = state.copyWith(cartItems: cartItems);
    _log(
        'addToCart <- cart items: ${state.cartItems.length}, total: ${state.totalPrice}');
  }

  // 從購物車刪除某一筆項目。
  void removeFromCart(CartItem item) {
    _log('removeFromCart -> ${item.drink.name}, item id: ${item.id}');
    state = state.copyWith(
      cartItems:
          state.cartItems.where((cartItem) => cartItem.id != item.id).toList(),
    );
    _log(
      'removeFromCart <- cart items: ${state.cartItems.length}, total: ${state.totalPrice}',
    );
  }

  // 更新訂單備註。
  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  // View 顯示完「訂單已送出」對話框後，將狀態重設。
  void resetSubmitState() {
    state = state.copyWith(didSubmitOrder: false);
  }

  // 送出訂單到後端。
  Future<void> submitOrder() async {
    if (state.cartItems.isEmpty) {
      _log('submitOrder -> skipped, cart is empty');
      return;
    }

    final token = await ref.read(memberViewModelProvider.notifier).readToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(errorMessage: '請先登入會員後再送出訂單。');
      return;
    }

    _log(
      'submitOrder -> items: ${state.cartItems.length}, total: ${state.totalPrice}',
    );
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await ref.read(apiClientProvider).fetchMe(token: token);

      // 把購物車資料轉成後端需要的 CreateOrderRequest。
      final orderRequest = CreateOrderRequest(
        customerName: user.name,
        items: state.cartItems.map((item) {
          return CreateOrderItemRequest(
            drinkId: item.drink.id,
            quantity: item.quantity,
            sweetness: '半糖',
            iceLevel: '少冰',
          );
        }).toList(),
      );

      final order = await _apiClient.submitOrder(orderRequest, token: token);
      _log('submitOrder <- success, order id: ${order.id}');
      // 成功後清空購物車與備註，並讓 View 顯示成功提示。
      state = state.copyWith(
        cartItems: [],
        note: '',
        didSubmitOrder: true,
      );
    } catch (error) {
      // 失敗時保留購物車，讓使用者可以稍後再送出。
      _log('submitOrder <- failed, error: $error');
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
      _log('submitOrder -> finished');
    }
  }

  // 統一 ViewModel log 前綴，方便在 Android Studio Console 搜尋。
  void _log(String message) {
    debugPrint('[DrinkListViewModel] $message');
  }
}
