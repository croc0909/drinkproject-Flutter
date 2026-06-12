import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluuter_drinkproject/main.dart';
import 'package:fluuter_drinkproject/models/drink.dart';
import 'package:fluuter_drinkproject/models/order.dart';
import 'package:fluuter_drinkproject/services/api_client.dart';
import 'package:fluuter_drinkproject/viewmodels/drink_list_view_model.dart';

class FakeApiClient extends ApiClient {
  @override
  Future<List<Drink>> fetchDrinks() async {
    return Drink.samples;
  }

  @override
  Future<Order> submitOrder(CreateOrderRequest orderRequest) async {
    return const Order(
      id: 1,
      customerName: '測試客人',
      phone: '0912345678',
      items: [],
      totalPrice: 0,
    );
  }
}

void main() {
  testWidgets('shows drink ordering title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: const DrinkOrderingApp(),
      ),
    );

    expect(find.text('飲料訂購'), findsOneWidget);
  });
}
