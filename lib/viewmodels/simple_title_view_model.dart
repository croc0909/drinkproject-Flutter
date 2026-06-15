import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleTitleState {
  const SimpleTitleState(this.title);

  final String title;
}

class SimpleTitleViewModel extends Notifier<SimpleTitleState> {
  SimpleTitleViewModel(this.initialTitle);

  final String initialTitle;

  @override
  SimpleTitleState build() {
    return SimpleTitleState(initialTitle);
  }
}

final mallViewModelProvider =
    NotifierProvider<SimpleTitleViewModel, SimpleTitleState>(
  () => SimpleTitleViewModel('商城兌換'),
);

final newsViewModelProvider =
    NotifierProvider<SimpleTitleViewModel, SimpleTitleState>(
  () => SimpleTitleViewModel('最新消息'),
);

final nearbyStoresViewModelProvider =
    NotifierProvider<SimpleTitleViewModel, SimpleTitleState>(
  () => SimpleTitleViewModel('附近門市'),
);
