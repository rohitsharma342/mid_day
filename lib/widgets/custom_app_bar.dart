import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../controllers/cart_controller.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showCartIcon;
  final bool showProfileIcon;
  final VoidCallback? onCartPressed;
  final VoidCallback? onProfilePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showCartIcon = false,
    this.showProfileIcon = false,
    this.onCartPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        if (showCartIcon)
          Consumer<CartController>(
            builder: (context, cartController, child) {
              return badges.Badge(
                badgeContent: Text(
                  cartController.itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                showBadge: cartController.itemCount > 0,
                badgeStyle: badges.BadgeStyle(
                  badgeColor: AppConstants.primaryColor,
                ),
                child: IconButton(
                  onPressed: onCartPressed,
                  icon: const Icon(Icons.shopping_cart),
                ),
              );
            },
          ),
        if (showProfileIcon)
          IconButton(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}