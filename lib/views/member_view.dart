import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth.dart';
import '../viewmodels/member_view_model.dart';
import 'order_records_view.dart';

class MemberView extends ConsumerStatefulWidget {
  const MemberView({super.key});

  @override
  ConsumerState<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends ConsumerState<MemberView> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(memberViewModelProvider.notifier)
          .loadCurrentUserIfPossible(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('會員專區')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (state.user == null)
            _AuthForm(
              isRegistering: _isRegistering,
              phoneController: _phoneController,
              nameController: _nameController,
              passwordController: _passwordController,
              onToggleMode: () {
                setState(() => _isRegistering = !_isRegistering);
              },
            )
          else
            _MemberProfile(user: state.user!),
          if (state.message != null) ...[
            const SizedBox(height: 16),
            Text(
              state.message!,
              style: TextStyle(
                color: state.status == MemberStatus.failed
                    ? Theme.of(context).colorScheme.error
                    : Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthForm extends ConsumerWidget {
  const _AuthForm({
    required this.isRegistering,
    required this.phoneController,
    required this.nameController,
    required this.passwordController,
    required this.onToggleMode,
  });

  final bool isRegistering;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberViewModelProvider);
    final viewModel = ref.read(memberViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isRegistering ? '建立會員帳號' : '會員登入',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          isRegistering ? '加入會員後可累積點數與查看訂單。' : '登入後可查看會員資料、優惠券與訂單紀錄。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: '手機號碼'),
        ),
        if (isRegistering) ...[
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: '姓名'),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: '密碼'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (isRegistering) {
                    viewModel.register(
                      phone: phoneController.text,
                      name: nameController.text,
                      password: passwordController.text,
                    );
                  } else {
                    viewModel.login(
                      phone: phoneController.text,
                      password: passwordController.text,
                    );
                  }
                },
          child: state.isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isRegistering ? '註冊會員' : '登入'),
        ),
        TextButton(
          onPressed: state.isLoading ? null : onToggleMode,
          child: Text(isRegistering ? '已經有會員帳號？前往登入' : '還不是會員？立即註冊'),
        ),
      ],
    );
  }
}

class _MemberProfile extends ConsumerWidget {
  const _MemberProfile({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '會員資料',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '已登入，可以開始使用會員功能。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 18),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(user.phone),
                ),
                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: Text('會員編號 ${user.id}'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OrderRecordsView(),
              ),
            );
          },
          icon: const Icon(Icons.receipt_long),
          label: const Text('訂單紀錄'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(memberViewModelProvider.notifier).logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('登出'),
        ),
      ],
    );
  }
}
