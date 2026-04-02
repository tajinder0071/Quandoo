import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _emailSignInCtrl = TextEditingController();
  final _passSignInCtrl  = TextEditingController();

  final _nameSignUpCtrl  = TextEditingController();
  final _emailSignUpCtrl = TextEditingController();
  final _passSignUpCtrl  = TextEditingController();

  bool _obscureIn  = true;
  bool _obscureUp  = true;
  int  _tabIndex   = 0;

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
    _emailSignInCtrl.dispose(); _passSignInCtrl.dispose();
    _nameSignUpCtrl.dispose(); _emailSignUpCtrl.dispose(); _passSignUpCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  String? _validateSignIn() {
    if (_emailSignInCtrl.text.trim().isEmpty) return 'Email is required.';
    if (!_emailSignInCtrl.text.contains('@')) return 'Enter a valid email.';
    if (_passSignInCtrl.text.isEmpty) return 'Password is required.';
    return null;
  }

  String? _validateSignUp() {
    if (_nameSignUpCtrl.text.trim().isEmpty) return 'Name is required.';
    if (_emailSignUpCtrl.text.trim().isEmpty) return 'Email is required.';
    if (!_emailSignUpCtrl.text.contains('@')) return 'Enter a valid email.';
    if (_passSignUpCtrl.text.length < 6)
      return 'Password must be at least 6 characters.';
    return null;
  }

  void _signIn(BuildContext context) {
    final err = _validateSignIn();
    if (err != null) { _showSnack(context, err); return; }
    context.read<AppBloc>().add(LoginUser(
      email: _emailSignInCtrl.text.trim(),
      password: _passSignInCtrl.text,
    ));
  }

  void _signUp(BuildContext context) {
    final err = _validateSignUp();
    if (err != null) { _showSnack(context, err); return; }
    context.read<AppBloc>().add(RegisterUser(
      name:     _nameSignUpCtrl.text.trim(),
      email:    _emailSignUpCtrl.text.trim(),
      password: _passSignUpCtrl.text,
    ));
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(color: AppTheme.white)),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return BlocListener<AppBloc, AppState>(
      listenWhen: (a, b) => a.authStatus != b.authStatus,
      listener: (context, state) {
        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MainScreen()));
        } else if (state.authStatus == AuthStatus.unauthenticated &&
            state.authError.isNotEmpty) {
          _showSnack(context, state.authError);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: SingleChildScrollView(
          child: Column(children: [

            // ── Hero ────────────────────────────────────────────
            SizedBox(
              height: 240,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(
                  'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppTheme.surface)),
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), AppTheme.bg]))),
                Positioned(bottom: 20, left: 24, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TableLux', style: GoogleFonts.playfairDisplay(
                      fontSize: 30, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  Text('Your luxury dining companion', style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppTheme.text2)),
                ])),
              ]),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
              child: Column(children: [

                // ── Tab switcher ─────────────────────────────────
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
                    tabs:  [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
                  ),
                ),
                 SizedBox(height: 28),

                // ── Forms via AnimatedSwitcher ────────────────────
                BlocBuilder<AppBloc, AppState>(
                  buildWhen: (a, b) => a.authStatus != b.authStatus,
                  builder: (context, state) {
                    final loading = state.authStatus == AuthStatus.loading;
                    return AnimatedSwitcher(
                      duration:  Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                              begin:  Offset(0.04, 0), end: Offset.zero)
                              .animate(anim),
                          child: child),
                      ),
                      child: _tabIndex == 0
                          ? _SignInForm(
                              key:  ValueKey('signin'),
                              emailCtrl: _emailSignInCtrl,
                              passCtrl: _passSignInCtrl,
                              obscure: _obscureIn,
                              onToggle: () => setState(() => _obscureIn = !_obscureIn),
                              loading: loading,
                              onSubmit: () => _signIn(context),
                            )
                          : _SignUpForm(
                              key:  ValueKey('signup'),
                              nameCtrl: _nameSignUpCtrl,
                              emailCtrl: _emailSignUpCtrl,
                              passCtrl: _passSignUpCtrl,
                              obscure: _obscureUp,
                              onToggle: () => setState(() => _obscureUp = !_obscureUp),
                              loading: loading,
                              onSubmit: () => _signUp(context),
                            ),
                    );
                  },
                ),

                 SizedBox(height: 24),
                Row(children: [
                   Expanded(child: Divider(color: AppTheme.border)),
                  Padding(padding:  EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.text3))),
                   Expanded(child: Divider(color: AppTheme.border)),
                ]),
                 SizedBox(height: 20),
                Row(children: [
                  _SocialBtn(label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () => _showSnack(context, 'Google sign-in coming soon')),
                   SizedBox(width: 12),
                  _SocialBtn(label: 'Apple',
                      icon: Icons.apple_rounded,
                      onTap: () => _showSnack(context, 'Apple sign-in coming soon')),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Sign In form ──────────────────────────────────────────────────────────────
class _SignInForm extends StatelessWidget {
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback onToggle, onSubmit;
  const _SignInForm({super.key, required this.emailCtrl, required this.passCtrl,
      required this.obscure, required this.onToggle,
      required this.loading, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    _FieldLabel('Email'),
     SizedBox(height: 6),
    _InputField(hint: 'your@email.com', ctrl: emailCtrl,
        icon: Icons.mail_outline_rounded, type: TextInputType.emailAddress),
     SizedBox(height: 14),
    _FieldLabel('Password'),
     SizedBox(height: 6),
    _InputField(hint: '••••••••', ctrl: passCtrl,
        icon: Icons.lock_outline_rounded, type: TextInputType.text,
        obscure: obscure, onToggleObscure: onToggle),
     SizedBox(height: 6),
    Align(alignment: Alignment.centerRight,
      child: TextButton(onPressed: () {},
        child: Text('Forgot Password?', style: GoogleFonts.dmSans(
            color: AppTheme.primary, fontWeight: FontWeight.w600)))),
     SizedBox(height: 12),
    _SubmitBtn(label: 'Sign In', loading: loading, onPressed: onSubmit),
  ]);
}

// ── Sign Up form ──────────────────────────────────────────────────────────────
class _SignUpForm extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback onToggle, onSubmit;
  const _SignUpForm({super.key, required this.nameCtrl, required this.emailCtrl,
      required this.passCtrl, required this.obscure, required this.onToggle,
      required this.loading, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    _FieldLabel('Full Name'),
     SizedBox(height: 6),
    _InputField(hint: 'Your name', ctrl: nameCtrl,
        icon: Icons.person_outline_rounded, type: TextInputType.name),
     SizedBox(height: 14),
    _FieldLabel('Email'),
     SizedBox(height: 6),
    _InputField(hint: 'your@email.com', ctrl: emailCtrl,
        icon: Icons.mail_outline_rounded, type: TextInputType.emailAddress),
     SizedBox(height: 14),
    _FieldLabel('Password'),
     SizedBox(height: 6),
    _InputField(hint: 'Min 6 characters', ctrl: passCtrl,
        icon: Icons.lock_outline_rounded, type: TextInputType.text,
        obscure: obscure, onToggleObscure: onToggle),
     SizedBox(height: 6),
    Text('Password must be at least 6 characters.',
        style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
     SizedBox(height: 20),
    _SubmitBtn(label: 'Create Account', loading: loading, onPressed: onSubmit),
  ]);
}

// ── Shared input sub-widgets ──────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2));
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType type;
  final bool? obscure;
  final VoidCallback? onToggleObscure;
  const _InputField({required this.hint, required this.ctrl, required this.icon,
      required this.type, this.obscure, this.onToggleObscure});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: type,
    obscureText: obscure ?? false,
    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.text3, size: 20),
      suffixIcon: obscure != null ? IconButton(
        icon: Icon(obscure! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppTheme.text3, size: 20),
        onPressed: onToggleObscure) : null,
    ),
  );
}

class _SubmitBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _SubmitBtn({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ?  SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2))
          : Text(label, style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.text1,
        side:  BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding:  EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon, size: 18, color: AppTheme.text1),
      label: Text(label, style: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text1)),
    ),
  );
}
