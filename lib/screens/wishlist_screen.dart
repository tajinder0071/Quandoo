import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'restaurant_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final favs = state.favorites;
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          automaticallyImplyLeading: false,
          title: Text('Wishlist', style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
          actions: [
            if (favs.isNotEmpty)
              Padding(
                padding:  EdgeInsets.only(right: 16),
                child: Center(child: Text('${favs.length} saved',
                    style: GoogleFonts.dmSans(
                        color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
              ),
          ],
        ),
        body: favs.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding:  EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface, shape: BoxShape.circle),
                  child:  Icon(Icons.favorite_border_rounded,
                      size: 48, color: AppTheme.text3)),
                 SizedBox(height: 20),
                Text('No saved restaurants', style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.text1)),
                 SizedBox(height: 8),
                Text('Tap the ♥ on any restaurant to save it here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
              ]))
            : GridView.builder(
                padding:  EdgeInsets.all(16),
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12,
                    mainAxisSpacing: 12, childAspectRatio: 0.78),
                itemCount: favs.length,
                itemBuilder: (context, i) => RestaurantCardV(
                  r: favs[i],
                  onTap: () {
                    context.read<AppBloc>().add(SelectRestaurant(favs[i]));
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AppBloc>(),
                          child:  RestaurantDetailScreen())));
                  },
                  onFav: () => context.read<AppBloc>().add(ToggleFavorite(favs[i].id)),
                ),
              ),
      );
    });
  }
}
