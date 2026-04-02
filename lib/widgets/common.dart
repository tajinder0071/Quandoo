import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/restaurant.dart';

// ── Network image with fallback ───────────────────────────────────────────────
class NetImg extends StatelessWidget {
  final String url;
  final BoxFit fit;

  NetImg(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: fit,
    loadingBuilder: (_, child, p) => p == null
        ? child
        : Container(
            color: AppTheme.surface,
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            ),
          ),
    errorBuilder: (_, __, ___) => Container(
      color: AppTheme.surface,
      child: Icon(Icons.restaurant, color: AppTheme.text3, size: 32),
    ),
  );
}

// ── Section header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.text1,
        ),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
    ],
  );
}

// ── Star rating row ───────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;

  StarRating(this.rating, {super.key, this.count, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star_rounded, color: AppTheme.star, size: size),
      SizedBox(width: 3),
      Text(
        rating.toStringAsFixed(1),
        style: GoogleFonts.dmSans(
          fontSize: size - 1,
          fontWeight: FontWeight.w600,
          color: AppTheme.text1,
        ),
      ),
      if (count != null) ...[
        SizedBox(width: 3),
        Text(
          '($count)',
          style: GoogleFonts.dmSans(fontSize: size - 2, color: AppTheme.text2),
        ),
      ],
    ],
  );
}

// ── Restaurant card — vertical ─────────────────────────────────────────────────
class RestaurantCardV extends StatelessWidget {
  final Restaurant r;
  final VoidCallback onTap;
  final VoidCallback onFav;

  RestaurantCardV({
    super.key,
    required this.r,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: NetImg(r.imageUrl)),
              Positioned(
                top: 5,
                right: 10,
                child: GestureDetector(
                  onTap: onFav,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      r.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: r.isFavorite ? AppTheme.primary : AppTheme.text1,
                      size: 16,
                    ),
                  ),
                ),
              ),
              if (r.hasOffer && r.offerText != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      r.offerText!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: r.isOpen
                        ? AppTheme.success.withOpacity(0.9)
                        : AppTheme.error.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.isOpen ? 'Open' : 'Closed',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  r.cuisine,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.text2,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    StarRating(r.rating, count: r.reviewCount),
                    Spacer(),
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppTheme.text3,
                    ),
                    Text(
                      ' ${r.distance} km',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.text3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      r.priceString,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Restaurant card — horizontal ──────────────────────────────────────────────
class RestaurantCardH extends StatelessWidget {
  final Restaurant r;
  final VoidCallback onTap;
  final VoidCallback onFav;

  const RestaurantCardH({
    super.key,
    required this.r,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImg(r.imageUrl),
                if (r.hasOffer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: AppTheme.primary.withOpacity(0.85),
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        'OFFER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onFav,
                        child: Icon(
                          r.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: r.isFavorite
                              ? AppTheme.primary
                              : AppTheme.text3,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    r.cuisine,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),
                  SizedBox(height: 6),
                  StarRating(r.rating, count: r.reviewCount, size: 13),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.text3,
                      ),
                      Text(
                        ' ${r.location}  ·  ${r.distance} km',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppTheme.text3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Primary button ────────────────────────────────────────────────────────────
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  PrimaryBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: AppTheme.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    ),
  );
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  TagChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppTheme.white : AppTheme.text2,
        ),
      ),
    ),
  );
}

// ── Booking status badge ──────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

// ── Info row ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2),
        ),
        Spacer(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.text1,
          ),
        ),
      ],
    ),
  );
}
