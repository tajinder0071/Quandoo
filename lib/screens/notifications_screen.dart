import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    _Notif(Icons.check_circle_rounded, AppTheme.success,
        'Reservation Confirmed',
        'Your table at La Maison Élégante is confirmed for tonight at 7:30 PM.',
        '2m ago', false),
    _Notif(Icons.local_offer_rounded, AppTheme.warning,
        'Special Offer 🔥',
        'Terra Cucina is offering 20% off this weekend. Book now before it\'s gone!',
        '1h ago', false),
    _Notif(Icons.star_rounded, AppTheme.star,
        'Leave a Review',
        'How was your dinner at Sakura Omakase? Your review helps others discover great food.',
        '3h ago', true),
    _Notif(Icons.alarm_rounded, AppTheme.primary,
        'Booking Reminder',
        'Your reservation at The Ember Grill is tomorrow at 8:00 PM. We look forward to welcoming you.',
        'Yesterday', true),
    _Notif(Icons.restaurant_rounded, AppTheme.gold,
        'New Restaurant Added',
        'Spice Garden has just joined TableLux. Discover their modern Indian cuisine today.',
        '2 days ago', true),
    _Notif(Icons.celebration_rounded, AppTheme.primary,
        'It\'s Your Anniversary! 🎉',
        'You\'ve been with TableLux for 1 year. Enjoy a special treat from us.',
        '3 days ago', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Notifications', style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.text1)),
        actions: [
          TextButton(onPressed: () {},
            child: Text('Mark all read', style: GoogleFonts.dmSans(
                color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
      body: ListView.separated(
        padding:  EdgeInsets.all(16),
        separatorBuilder: (_, __) =>  SizedBox(height: 10),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final n = _items[i];
          return Container(
            padding:  EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.isRead ? AppTheme.card : AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: n.isRead
                  ? null
                  : Border.all(color: n.accentColor.withOpacity(0.3))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Icon
              Container(padding:  EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: n.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(n.icon, color: n.accentColor, size: 20)),
               SizedBox(width: 12),
              // Content
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(n.title, style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1))),
                   SizedBox(width: 8),
                  Text(n.time, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
                ]),
                 SizedBox(height: 4),
                Text(n.body, style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppTheme.text2, height: 1.55)),
              ])),
              // Unread dot
              if (!n.isRead) ...[
                 SizedBox(width: 8),
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: n.accentColor, shape: BoxShape.circle)),
              ],
            ]),
          );
        },
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color accentColor;
  final String title, body, time;
  final bool isRead;
  const _Notif(this.icon, this.accentColor, this.title, this.body, this.time, this.isRead);
}
