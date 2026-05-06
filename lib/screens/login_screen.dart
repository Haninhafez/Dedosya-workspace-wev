import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'manager');
  final _passCtrl = TextEditingController();
  String _error = '';
  bool _obscure = true;

  void _login() {
    final ok = context.read<AppProvider>().login(
      _userCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!ok) setState(() => _error = 'Invalid username or password');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: isWide ? _wideLayout() : _narrowLayout(),
    );
  }

  Widget _wideLayout() => Row(
    children: [
      Expanded(child: _leftPanel()),
      _rightPanel(width: 460),
    ],
  );

  Widget _narrowLayout() => SingleChildScrollView(
    child: Column(
      children: [
        _mobileHeader(),
        _rightPanel(width: double.infinity),
      ],
    ),
  );

  Widget _leftPanel() => Container(
    color: AppColors.navy,
    child: Stack(
      children: [
        // decorative blobs
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.teal.withOpacity(0.18), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.sky.withOpacity(0.12), Colors.transparent],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dedosya WorkSpace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'WORK · COFFEE · COMMUNITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white38,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 56),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statItem('10', 'Regular Seats'),
                  const SizedBox(width: 32),
                  _statItem('4', 'Private Offices'),
                  const SizedBox(width: 32),
                  _statItem('2', 'Meeting Rooms'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _statItem(String num, String lbl) => Column(
    children: [
      Text(
        num,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.tealLight,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        lbl.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );

  Widget _mobileHeader() => Container(
    color: AppColors.navy,
    padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
    child: Row(
      children: [
        const Icon(Icons.work_outline, color: AppColors.tealLight, size: 36),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dedosya WorkSpace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Work · Coffee · Community',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _rightPanel({required double width}) => Container(
    width: width == double.infinity ? null : width,
    color: AppColors.warmWhite,
    padding: const EdgeInsets.all(48),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back 👋',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to manage your workspace',
          style: TextStyle(fontSize: 13, color: AppColors.textSoft),
        ),
        const SizedBox(height: 36),
        // Username
        _fieldLabel('Username'),
        const SizedBox(height: 7),
        TextField(
          textInputAction: TextInputAction.next,
          controller: _userCtrl,
          decoration: const InputDecoration(hintText: 'manager'),
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 18),
        // Password
        _fieldLabel('Password'),
        const SizedBox(height: 7),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSoft,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          onSubmitted: (_) => _login(),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _error,
            style: const TextStyle(color: AppColors.red, fontSize: 12.5),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.navy,
            ),
            child: const Text(
              'Sign In →',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _fieldLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: AppColors.textMid,
    ),
  );
}
