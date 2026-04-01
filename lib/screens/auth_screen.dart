import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  int _tabIndex = 0;   // ← track tab manually

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() => _tabIndex = _tab.index);
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Hero image ──────────────────────────────────────
          SizedBox(
            height: 240,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                  'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppTheme.surface)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      AppTheme.bg,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TableLux',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text1)),
                    Text('Your luxury dining companion',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppTheme.text2)),
                  ],
                ),
              ),
            ]),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
            child: Column(children: [

              // ── Tab switcher ────────────────────────────────
              Container(
                height: 48,
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14)),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12)),
                  labelStyle: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  labelColor: AppTheme.white,
                  unselectedLabelColor: AppTheme.text2,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
                ),
              ),
              const SizedBox(height: 28),

              // ── Form — AnimatedSwitcher replaces TabBarView ─
              // TabBarView needs a bounded height and crashes inside
              // SingleChildScrollView; AnimatedSwitcher has no such
              // constraint.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _tabIndex == 0
                    ? _SignInForm(
                  key: const ValueKey('signin'),
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  obscure: _obscure,
                  onToggleObscure: () =>
                      setState(() => _obscure = !_obscure),
                  loading: _loading,
                  onSubmit: _submit,
                )
                    : _SignUpForm(
                  key: const ValueKey('signup'),
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  obscure: _obscure,
                  onToggleObscure: () =>
                      setState(() => _obscure = !_obscure),
                  loading: _loading,
                  onSubmit: _submit,
                ),
              ),

              const SizedBox(height: 24),

              // ── Social divider ──────────────────────────────
              Row(children: [
                const Expanded(child: Divider(color: AppTheme.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.text3)),
                ),
                const Expanded(child: Divider(color: AppTheme.border)),
              ]),
              const SizedBox(height: 20),

              // ── Social buttons ──────────────────────────────
              Row(children: [
                _SocialBtn(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: _submit),
                const SizedBox(width: 12),
                _SocialBtn(
                    label: 'Apple',
                    icon: Icons.apple_rounded,
                    onTap: _submit),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Sign In form ──────────────────────────────────────────────────────────────
class _SignInForm extends StatelessWidget {
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback onToggleObscure, onSubmit;

  const _SignInForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FieldLabel('Email'),
      const SizedBox(height: 6),
      _InputField(
        hint: 'your@email.com',
        ctrl: emailCtrl,
        icon: Icons.mail_outline_rounded,
        type: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      _FieldLabel('Password'),
      const SizedBox(height: 6),
      _InputField(
        hint: '••••••••',
        ctrl: passCtrl,
        icon: Icons.lock_outline_rounded,
        type: TextInputType.text,
        obscure: obscure,
        onToggleObscure: onToggleObscure,
      ),
      const SizedBox(height: 6),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          child: Text('Forgot Password?',
              style: GoogleFonts.dmSans(
                  color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 12),
      _SubmitBtn(label: 'Sign In', loading: loading, onPressed: onSubmit),
    ]);
  }
}

// ── Sign Up form ──────────────────────────────────────────────────────────────
class _SignUpForm extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback onToggleObscure, onSubmit;

  const _SignUpForm({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FieldLabel('Full Name'),
      const SizedBox(height: 6),
      _InputField(
        hint: 'Your name',
        ctrl: nameCtrl,
        icon: Icons.person_outline_rounded,
        type: TextInputType.name,
      ),
      const SizedBox(height: 14),
      _FieldLabel('Email'),
      const SizedBox(height: 6),
      _InputField(
        hint: 'your@email.com',
        ctrl: emailCtrl,
        icon: Icons.mail_outline_rounded,
        type: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      _FieldLabel('Password'),
      const SizedBox(height: 6),
      _InputField(
        hint: '••••••••',
        ctrl: passCtrl,
        icon: Icons.lock_outline_rounded,
        type: TextInputType.text,
        obscure: obscure,
        onToggleObscure: onToggleObscure,
      ),
      const SizedBox(height: 24),
      _SubmitBtn(label: 'Create Account', loading: loading, onPressed: onSubmit),
    ]);
  }
}

// ── Shared input widgets ──────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2),
  );
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType type;
  final bool? obscure;
  final VoidCallback? onToggleObscure;

  const _InputField({
    required this.hint,
    required this.ctrl,
    required this.icon,
    required this.type,
    this.obscure,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure ?? false,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.text3, size: 20),
        suffixIcon: obscure != null
            ? IconButton(
            icon: Icon(
                obscure!
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.text3,
                size: 20),
            onPressed: onToggleObscure)
            : null,
      ),
    );
  }
}

class _SubmitBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _SubmitBtn(
      {required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              color: AppTheme.white, strokeWidth: 2))
          : Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialBtn(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.text1,
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon, size: 18, color: AppTheme.text1),
      label: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.text1)),
    ),
  );
}