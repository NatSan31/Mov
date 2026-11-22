import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/global_notification_listener.dart';
import '../dashboard/home_dashboard_screen.dart';
import '../shop/products_catalog_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../map/gym_locations_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/cart_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final cartProvider = context.watch<CartProvider>();

    final screens = const [
      HomeDashboardScreen(),
      ProductsCatalogScreen(),
      SubscriptionPlansScreen(),
      GymLocationsScreen(),
      ProfileScreen(),
    ];

    return GlobalAppOverlayListener(
      child: ResponsiveLayout(
        // VERSIÓN MÓVIL (< 768px): BottomNavigationBar
        mobile: Scaffold(
          body: screens[navProvider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navProvider.currentIndex,
            onTap: (index) => navProvider.setIndex(index),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cartProvider.totalItemsCount > 0,
                  label: Text('${cartProvider.totalItemsCount}'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                activeIcon: const Icon(Icons.shopping_bag),
                label: 'Tienda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.card_membership_outlined),
                activeIcon: Icon(Icons.card_membership),
                label: 'Planes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Sedes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),

        // VERSIÓN ESCRITORIO / TABLET (>= 768px): NavigationRail lateral adaptado
        desktop: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: navProvider.currentIndex,
                onDestinationSelected: (index) => navProvider.setIndex(index),
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bolt, color: AppColors.primary, size: 32),
                      SizedBox(width: 8),
                      Text(
                        'FITPULSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: IconButton(
                        icon: Badge(
                          isLabelVisible: cartProvider.totalItemsCount > 0,
                          label: Text('${cartProvider.totalItemsCount}'),
                          child: const Icon(Icons.shopping_cart),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_bag_outlined),
                    selectedIcon: Icon(Icons.shopping_bag),
                    label: Text('Tienda'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.card_membership_outlined),
                    selectedIcon: Icon(Icons.card_membership),
                    label: Text('Planes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.map_outlined),
                    selectedIcon: Icon(Icons.map),
                    label: Text('Sedes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Perfil'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.white12),
              Expanded(
                child: screens[navProvider.currentIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
