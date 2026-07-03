import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth.dart';
import '../viewmodels/member_view_model.dart';
import 'order_records_view.dart';

const _brandOrange = Color(0xFFFF8729);
const _brandOrangeDark = Color(0xFFFF641A);
const _warmBackground = Color(0xFFFFF7EB);
const _softOrange = Color(0xFFFFEDD6);
const _secondaryText = Color(0xFF8E8E93);

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
  bool _showsPassword = false;

  bool get _canSubmit {
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final hasName = _nameController.text.trim().isNotEmpty;
    return hasPhone &&
        _passwordController.text.isNotEmpty &&
        (!_isRegistering || hasName);
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_refreshForm);
    _nameController.addListener(_refreshForm);
    _passwordController.addListener(_refreshForm);
    Future.microtask(
      () => ref
          .read(memberViewModelProvider.notifier)
          .loadCurrentUserIfPossible(),
    );
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode(bool register) {
    if (_isRegistering == register) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isRegistering = register;
      _showsPassword = false;
    });
    ref.read(memberViewModelProvider.notifier).clearTransientMessages();
  }

  Future<void> _submit() async {
    final state = ref.read(memberViewModelProvider);
    if (!_canSubmit || state.isLoading) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final viewModel = ref.read(memberViewModelProvider.notifier);
    if (_isRegistering) {
      await viewModel.register(
        phone: _phoneController.text,
        name: _nameController.text,
        password: _passwordController.text,
      );
    } else {
      await viewModel.login(
        phone: _phoneController.text,
        password: _passwordController.text,
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確定要登出嗎？'),
        content: const Text('下次使用會員功能時，需要重新登入。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('登出'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    await ref.read(memberViewModelProvider.notifier).logout();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberViewModelProvider);

    ref.listen(memberViewModelProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _warmBackground,
      ),
      child: Scaffold(
        backgroundColor: _warmBackground,
        appBar: _MemberAppBar(onBack: () => Navigator.maybePop(context)),
        body: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final isProfile = child.key == const ValueKey('profile');
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(isProfile ? 0.06 : -0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: state.user == null
                ? _AuthContent(
                    key: const ValueKey('auth'),
                    state: state,
                    isRegistering: _isRegistering,
                    showsPassword: _showsPassword,
                    canSubmit: _canSubmit,
                    phoneController: _phoneController,
                    nameController: _nameController,
                    passwordController: _passwordController,
                    onModeChanged: _switchAuthMode,
                    onPasswordVisibilityChanged: () {
                      setState(() => _showsPassword = !_showsPassword);
                    },
                    onSubmit: _submit,
                  )
                : _MemberProfile(
                    key: const ValueKey('profile'),
                    user: state.user!,
                    state: state,
                    onLogout: _confirmLogout,
                  ),
          ),
        ),
      ),
    );
  }
}

class _MemberAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MemberAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: _warmBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        '會員專區',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      leadingWidth: 84,
      leading: Padding(
        padding: const EdgeInsets.only(left: 18),
        child: Center(
          child: Material(
            color: const Color(0xFFFFFCF4),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const SizedBox.square(
                dimension: 48,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF171712),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({
    super.key,
    required this.state,
    required this.isRegistering,
    required this.showsPassword,
    required this.canSubmit,
    required this.phoneController,
    required this.nameController,
    required this.passwordController,
    required this.onModeChanged,
    required this.onPasswordVisibilityChanged,
    required this.onSubmit,
  });

  final MemberState state;
  final bool isRegistering;
  final bool showsPassword;
  final bool canSubmit;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onPasswordVisibilityChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
      children: [
        _WelcomeHeader(isRegistering: isRegistering),
        const SizedBox(height: 24),
        _AuthModePicker(
          isRegistering: isRegistering,
          onChanged: onModeChanged,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _brandOrange.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: _brandOrange.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _MemberField(
                title: '手機號碼',
                icon: Icons.phone_iphone_rounded,
                controller: phoneController,
                hintText: '請輸入手機號碼',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: isRegistering
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _MemberField(
                          title: '姓名',
                          icon: Icons.person_outline_rounded,
                          controller: nameController,
                          hintText: '請輸入姓名',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _MemberField(
                title: '密碼',
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
                hintText: '請輸入密碼',
                obscureText: !showsPassword,
                textInputAction: TextInputAction.done,
                autofillHints: [
                  isRegistering
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                suffixIcon: IconButton(
                  onPressed: onPasswordVisibilityChanged,
                  tooltip: showsPassword ? '隱藏密碼' : '顯示密碼',
                  icon: Icon(
                    showsPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _secondaryText,
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 16),
              _AuthSubmitButton(
                isRegistering: isRegistering,
                isLoading: state.isLoading,
                enabled: canSubmit,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
        if (state.message != null) ...[
          const SizedBox(height: 24),
          _StatusMessage(
            message: state.message!,
            isError: state.status == MemberStatus.failed,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isRegistering ? '已經是會員？' : '還不是會員？',
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed:
                  state.isLoading ? null : () => onModeChanged(!isRegistering),
              style: TextButton.styleFrom(
                foregroundColor: _brandOrange,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 40),
              ),
              child: Text(
                isRegistering ? '前往登入' : '立即註冊',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.isRegistering});

  final bool isRegistering;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: _softOrange,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRegistering
                ? Icons.person_add_alt_1_rounded
                : Icons.local_cafe_rounded,
            color: _brandOrange,
            size: 31,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  isRegistering ? '建立會員帳號' : '歡迎回來',
                  key: ValueKey(isRegistering),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isRegistering ? '加入會員，讓每一杯都有回饋。' : '登入後繼續你的飲品日常。',
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthModePicker extends StatelessWidget {
  const _AuthModePicker({
    required this.isRegistering,
    required this.onChanged,
  });

  final bool isRegistering;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _brandOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthModeButton(
              title: '登入',
              selected: !isRegistering,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _AuthModeButton(
              title: '註冊',
              selected: isRegistering,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _brandOrange : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : _brandOrange,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberField extends StatelessWidget {
  const _MemberField({
    required this.title,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final String title;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: _secondaryText),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          enableSuggestions: !obscureText,
          autocorrect: false,
          onSubmitted: onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            constraints: const BoxConstraints.tightFor(height: 50),
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFC4C4C6)),
            filled: true,
            isDense: true,
            fillColor: _warmBackground.withValues(alpha: 0.72),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _brandOrange.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _brandOrange.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _brandOrange, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthSubmitButton extends StatelessWidget {
  const _AuthSubmitButton({
    required this.isRegistering,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isRegistering;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: active ? _brandOrange : _brandOrange.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _brandOrange.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('member-auth-submit'),
          borderRadius: BorderRadius.circular(18),
          onTap: active ? onPressed : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox.square(
                  dimension: 19,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              else
                Icon(
                  isRegistering
                      ? Icons.person_add_alt_1_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              const SizedBox(width: 10),
              Text(
                isLoading
                    ? (isRegistering ? '建立帳號中…' : '登入中…')
                    : (isRegistering ? '建立會員帳號' : '登入會員'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberProfile extends StatelessWidget {
  const _MemberProfile({
    super.key,
    required this.user,
    required this.state,
    required this.onLogout,
  });

  final User user;
  final MemberState state;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_brandOrange, _brandOrangeDark],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _brandOrange.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '嗨，${user.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '今天想喝點什麼？',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '會員編號 ${user.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _brandOrange.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '會員資料',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _ProfileRow(
                title: '姓名',
                value: user.name,
                icon: Icons.person_outline_rounded,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _ProfileRow(
                title: '手機號碼',
                value: user.phone,
                icon: Icons.phone_iphone_rounded,
              ),
            ],
          ),
        ),
        if (state.message != null) ...[
          const SizedBox(height: 22),
          _StatusMessage(
            message: state.message!,
            isError: state.status == MemberStatus.failed,
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 58,
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OrderRecordsView(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long_rounded),
                SizedBox(width: 12),
                Text(
                  '查看訂單紀錄',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: _brandOrange,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: _brandOrange.withValues(alpha: 0.30),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              '登出帳號',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: _softOrange,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _brandOrange, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFD92D20) : const Color(0xFF24B95A);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_rounded : Icons.check_circle_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
