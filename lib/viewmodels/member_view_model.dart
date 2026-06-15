import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth.dart';
import 'drink_list_view_model.dart';

const authTokenKey = 'authToken';

final memberViewModelProvider =
    NotifierProvider<MemberViewModel, MemberState>(MemberViewModel.new);

enum MemberStatus {
  signedOut,
  checkingSession,
  signingIn,
  signingUp,
  signedIn,
  failed,
}

class MemberState {
  const MemberState({
    this.status = MemberStatus.signedOut,
    this.user,
    this.message,
  });

  final MemberStatus status;
  final User? user;
  final String? message;

  bool get isLoading {
    return status == MemberStatus.checkingSession ||
        status == MemberStatus.signingIn ||
        status == MemberStatus.signingUp;
  }

  bool get isLoggedIn => user != null;

  MemberState copyWith({
    MemberStatus? status,
    Object? user = _unchanged,
    Object? message = _unchanged,
  }) {
    return MemberState(
      status: status ?? this.status,
      user: user == _unchanged ? this.user : user as User?,
      message: message == _unchanged ? this.message : message as String?,
    );
  }
}

class MemberViewModel extends Notifier<MemberState> {
  @override
  MemberState build() {
    return const MemberState();
  }

  Future<void> loadCurrentUserIfPossible() async {
    if (state.user != null) return;

    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(authTokenKey);
    if (token == null || token.isEmpty) {
      state = const MemberState();
      return;
    }

    state = state.copyWith(status: MemberStatus.checkingSession, message: null);
    try {
      final user = await ref.read(apiClientProvider).fetchMe(token: token);
      state = MemberState(
        status: MemberStatus.signedIn,
        user: user,
        message: '已取得會員資料',
      );
    } catch (error) {
      await preferences.remove(authTokenKey);
      state = MemberState(
        status: MemberStatus.failed,
        message: error.toString(),
      );
    }
  }

  Future<void> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    await _performAuthAction(
      loadingStatus: MemberStatus.signingUp,
      successMessage: '註冊成功',
      action: () {
        return ref.read(apiClientProvider).register(
              phone: phone.trim(),
              name: name.trim(),
              password: password,
            );
      },
    );
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    await _performAuthAction(
      loadingStatus: MemberStatus.signingIn,
      successMessage: '登入成功',
      action: () {
        return ref.read(apiClientProvider).login(
              phone: phone.trim(),
              password: password,
            );
      },
    );
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(authTokenKey);
    state = const MemberState();
  }

  void clearTransientMessages() {
    if (state.status == MemberStatus.failed) {
      state = const MemberState();
    } else if (state.user != null && state.message != null) {
      state = state.copyWith(message: null);
    }
  }

  Future<String?> readToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(authTokenKey);
  }

  Future<void> _performAuthAction({
    required MemberStatus loadingStatus,
    required String successMessage,
    required Future<AuthResponse> Function() action,
  }) async {
    state = state.copyWith(status: loadingStatus, message: null);

    try {
      final response = await action();
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(authTokenKey, response.token);
      state = MemberState(
        status: MemberStatus.signedIn,
        user: response.user,
        message: successMessage,
      );
    } catch (error) {
      debugPrint('[MemberViewModel] auth failed: $error');
      state = MemberState(
        status: MemberStatus.failed,
        message: error.toString(),
      );
    }
  }
}

const Object _unchanged = Object();
