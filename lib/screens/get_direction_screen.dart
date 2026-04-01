import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class GetDirectionScreen extends StatefulWidget {
  final Booking booking;

  const GetDirectionScreen({super.key, required this.booking});

  @override
  State<GetDirectionScreen> createState() => _GetDirectionState();
}

class _GetDirectionState extends State<GetDirectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pinCtrl;
  late final Animation<double> _pinBounce;
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _pinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pinBounce = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _pinCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Simulated map background ──────────────────────────
          Column(
            children: [
              Expanded(
                child: _FakeMap(booking: b, pinBounce: _pinBounce),
              ),
            ],
          ),

          // ── Back button ───────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.text1,
                  size: 20,
                ),
              ),
            ),
          ),

          // ── Bottom sheet ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Restaurant info
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.restaurantName,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '28 Park Avenue, Manhattan, NY 10001',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Open',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 16),

                  // Booking mini-summary
                  Row(
                    children: [
                      _chip(
                        Icons.calendar_today_rounded,
                        DateFormat('EEE, MMM d').format(b.date),
                      ),
                      const SizedBox(width: 8),
                      _chip(Icons.access_time_rounded, b.timeSlot),
                      const SizedBox(width: 8),
                      _chip(Icons.people_rounded, '${b.guests} guests'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Distance + ETA row
                  Row(
                    children: [
                      _statBox(
                        Icons.directions_walk_rounded,
                        '1.2 km',
                        'Distance',
                      ),
                      const SizedBox(width: 12),
                      _statBox(
                        Icons.access_time_filled_rounded,
                        '~15 min',
                        'Est. Walk',
                      ),
                      const SizedBox(width: 12),
                      _statBox(
                        Icons.directions_car_rounded,
                        '~5 min',
                        'Est. Drive',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Transport buttons
                  Row(
                    children: [
                      _transportBtn(Icons.directions_walk_rounded, 'Walk'),
                      const SizedBox(width: 8),
                      _transportBtn(Icons.directions_car_rounded, 'Drive'),
                      const SizedBox(width: 8),
                      _transportBtn(
                        Icons.directions_transit_rounded,
                        'Transit',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Primary: Arrived / Start Navigation
                  if (!_arrived)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _arrived = true),
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: Text(
                          'Start Navigation',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  else
                    _ArrivedBanner(restaurantName: b.restaurantName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.text1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _statBox(IconData icon, String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3),
          ),
        ],
      ),
    ),
  );

  Widget _transportBtn(IconData icon, String label) => Expanded(
    child: OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.text2,
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

// ── Arrived banner ────────────────────────────────────────────────────────────
class _ArrivedBanner extends StatelessWidget {
  final String restaurantName;

  const _ArrivedBanner({required this.restaurantName});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.success, Color(0xFF1A6B3C)],
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppTheme.success.withOpacity(0.3),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.where_to_vote_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'ve Arrived! 🎉',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Welcome to $restaurantName. Enjoy your meal!',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Fake map widget ───────────────────────────────────────────────────────────
class _FakeMap extends StatelessWidget {
  final Booking booking;
  final Animation<double> pinBounce;

  const _FakeMap({required this.booking, required this.pinBounce});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Grid background simulating map tiles
        CustomPaint(painter: _MapPainter()),

        // Destination pin (bouncing)
        Center(
          child: AnimatedBuilder(
            animation: pinBounce,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, pinBounce.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pin shadow
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Pointer triangle
                  CustomPaint(
                    size: const Size(14, 8),
                    painter: _PinTailPainter(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Walking person (bottom-left)
        Positioned(
          bottom: 200,
          left: 80,
          child: _pulse(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),

        // Dashed route line (static decoration)
        CustomPaint(painter: _RoutePainter()),

        // Map attribution overlay (bottom-right)
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Simulated Map View',
              style: GoogleFonts.dmSans(fontSize: 9, color: AppTheme.text3),
            ),
          ),
        ),

        // Restaurant name callout
        Positioned(
          top: MediaQuery.of(context).padding.top + 58,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.restaurantName,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pulse({required Widget child}) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
      ),
      child,
    ],
  );
}

// ── Map grid painter ──────────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F1923),
    );

    // Road grid
    final roadPaint = Paint()
      ..color = const Color(0xFF1E2A3B)
      ..strokeWidth = 18;
    final minorPaint = Paint()
      ..color = const Color(0xFF182030)
      ..strokeWidth = 8;

    // Horizontal roads
    for (double y = 60; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 60; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    // Minor streets
    for (double y = 105; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }
    for (double x = 105; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }

    // Blocks (filled rectangles between roads)
    final blockPaint = Paint()..color = const Color(0xFF141E2B);
    for (double x = 0; x < size.width; x += 90) {
      for (double y = 0; y < size.height; y += 90) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 25, y + 25, 56, 56),
            const Radius.circular(4),
          ),
          blockPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Dashed route painter ──────────────────────────────────────────────────────
class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.72)
      ..lineTo(size.width * 0.22, size.height * 0.45)
      ..lineTo(size.width * 0.50, size.height * 0.45)
      ..lineTo(size.width * 0.50, size.height * 0.50);

    // Draw dashed
    const dashLen = 10.0, gapLen = 6.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dashLen).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end.toDouble()), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Pin tail triangle ─────────────────────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = AppTheme.primary,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
