import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

// ── Splash ────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Whether auth check is done — used to gate navigation
  bool _minTimeElapsed = false;
  bool _authChecked    = false;
  AuthStatus? _resolvedStatus;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0, 0.6, curve: Curves.easeOut)));

    _scale = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    // ── 1. Start logo animation ──────────────────────────────
    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      _minTimeElapsed = true;
      _tryNavigate();
    });

    // ── 2. Check DB for active session ────────────────────────
    context.read<AppBloc>().add(RestoreSession());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  /// Called when BOTH conditions are met:
  ///   a) minimum splash time has elapsed
  ///   b) auth check is complete
  void _tryNavigate() {
    if (!_minTimeElapsed || !_authChecked) return;
    if (!mounted) return;

    if (_resolvedStatus == AuthStatus.authenticated) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      // Only care about the RestoreSession result (loading → done)
      listenWhen: (a, b) =>
      a.authStatus == AuthStatus.loading &&
          (b.authStatus == AuthStatus.authenticated ||
              b.authStatus == AuthStatus.unauthenticated),
      listener: (context, state) {
        _authChecked    = true;
        _resolvedStatus = state.authStatus;
        _tryNavigate();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF0F1923), Color(0xFF1A2433)],
            ),
          ),
          child: Stack(fit: StackFit.expand, children: [

            // Decorative circles
            Positioned(top: -60, right: -60,
                child: Container(width: 220, height: 220,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.12), width: 1)))),
            Positioned(bottom: 80, left: -80,
                child: Container(width: 260, height: 260,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.gold.withOpacity(0.08), width: 1)))),

            // Logo
            Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primary, AppTheme.primaryDk]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 28, offset: const Offset(0, 8))],
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: AppTheme.white, size: 44),
                      ),
                      const SizedBox(height: 24),
                      Text('TableLux', style: GoogleFonts.playfairDisplay(
                          fontSize: 36, fontWeight: FontWeight.w700,
                          color: AppTheme.text1, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text('Reserve. Dine. Indulge.', style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppTheme.text2, letterSpacing: 0.5)),
                    ]),
                  ),
                ),
              ),
            ),

            // Bottom dots
            Positioned(
              bottom: 48, left: 0, right: 0,
              child: AnimatedBuilder(
                animation: _fade,
                builder: (_, __) => Opacity(
                  opacity: _fade.value,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Loading indicator while auth is being checked
                    BlocBuilder<AppBloc, AppState>(
                      buildWhen: (a, b) => a.authStatus != b.authStatus,
                      builder: (_, state) => AnimatedOpacity(
                        opacity: state.authStatus == AuthStatus.loading ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == 0 ? 20 : 6, height: 6,
                        decoration: BoxDecoration(
                            color: i == 0 ? AppTheme.primary : AppTheme.text3,
                            borderRadius: BorderRadius.circular(3)),
                      )),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Onboarding ────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _OBData(
      image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
      title: 'Discover Luxury\nRestaurants',
      subtitle: 'Explore the finest dining experiences curated for the most discerning palates in your city.',
      icon: Icons.explore_rounded,
    ),
    _OBData(
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
      title: 'Reserve Your\nPerfect Table',
      subtitle: 'Book in seconds. Choose your table, date, and time with our seamless reservation system.',
      icon: Icons.event_seat_rounded,
    ),
    _OBData(
      image: 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800&q=80',
      title: 'Unforgettable\nDining Moments',
      subtitle: 'Every meal tells a story. Create memories that last a lifetime at the world\'s best restaurants.',
      icon: Icons.local_dining_rounded,
    ),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  void _skip() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const AuthScreen()));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _pages.length,
          itemBuilder: (_, i) => _OBPage(data: _pages[i], size: size),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 28, 24, 32 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.bg.withOpacity(0.97),
                  AppTheme.bg,
                ],
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8, height: 8,
                  decoration: BoxDecoration(
                      color: _page == i ? AppTheme.primary : AppTheme.text3,
                      borderRadius: BorderRadius.circular(4)),
                )),
              ),
              const SizedBox(height: 24),
              if (_page < 2)
                Row(children: [
                  TextButton(
                    onPressed: _skip,
                    child: Text('Skip', style: GoogleFonts.dmSans(
                        color: AppTheme.text2, fontSize: 15,
                        fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 52)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Next', style: GoogleFonts.dmSans(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ]),
                  ),
                ])
              else
                Row(children: [
                  Expanded(child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52)),
                    child: Text('Get Started', style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
                ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _OBData {
  final String image, title, subtitle;
  final IconData icon;
  const _OBData({required this.image, required this.title,
    required this.subtitle, required this.icon});
}

class _OBPage extends StatelessWidget {
  final _OBData data;
  final Size size;
  const _OBPage({required this.data, required this.size});

  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(
      height: size.height * 0.58,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(data.image, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppTheme.surface)),
        Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.2), AppTheme.bg]))),
      ]),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(data.icon, color: AppTheme.primary, size: 22)),
        const SizedBox(height: 16),
        Text(data.title, style: GoogleFonts.playfairDisplay(
            fontSize: 30, fontWeight: FontWeight.w700,
            color: AppTheme.text1, height: 1.2)),
        const SizedBox(height: 12),
        Text(data.subtitle, style: GoogleFonts.dmSans(
            fontSize: 15, color: AppTheme.text2, height: 1.65)),
      ]),
    ),
  ]);
}