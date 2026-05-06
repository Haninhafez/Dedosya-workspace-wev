import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';
import 'bookings_screen.dart';
import 'cafe_screen.dart';
import 'billing_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _navItems = [
    _NavItem(Icons.grid_view_rounded, 'Dashboard'),
    _NavItem(Icons.calendar_today_outlined, 'Bookings'),
    _NavItem(Icons.coffee_outlined, 'Café'),
    _NavItem(Icons.credit_card_outlined, 'Billing'),
    _NavItem(Icons.bar_chart_outlined, 'Reports'),
    _NavItem(Icons.settings_outlined, 'Settings'),
  ];

  final _pages = const [
    DashboardScreen(),
    BookingsScreen(),
    CafeScreen(),
    BillingScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    currentIndex = context.watch<AppProvider>().currentPage;
    final isWide = MediaQuery.of(context).size.width > 640;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: isWide ? _wideLayout() : _narrowLayout(),
    );
  }

  Widget _wideLayout() => Row(
    children: [
      _Sidebar(
        items: _navItems,
        current: currentIndex,
        onTap: (i) => context.read<AppProvider>().changePage(i),
        onLogout: () {
          context.read<AppProvider>().changePage(0);
          context.read<AppProvider>().logout();
        },
      ),
      Expanded(child: _pages[currentIndex]),
    ],
  );

  Widget _narrowLayout() => Scaffold(
    backgroundColor: AppColors.cream,
    body: _pages[currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => context.read<AppProvider>().changePage(i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.navy,
      selectedItemColor: AppColors.tealLight,
      unselectedItemColor: Colors.white38,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: _navItems
          .map(
            (n) => BottomNavigationBarItem(icon: Icon(n.icon), label: n.label),
          )
          .toList(),
    ),
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _Sidebar extends StatefulWidget {
  final List<_NavItem> items;
  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.items,
    required this.current,
    required this.onTap,
    required this.onLogout,
  });

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        width: _hovered ? 214 : 68,
        color: AppColors.navy,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo
            Container(
              width: _hovered ? 80 : 36,
              height: _hovered ? 80 : 36,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
              ),
            ),
            // Nav items
            ...widget.items.asMap().entries.map(
              (e) => _navTile(e.key, e.value),
            ),
            const Spacer(),
            // Logout
            _logoutTile(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _navTile(int index, _NavItem item) {
    final active = widget.current == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(21, 12, 12, 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.teal.withOpacity(0.12)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: active ? AppColors.teal : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: active
                    ? AppColors.tealLight
                    : Colors.white.withOpacity(0.5),
              ),
              if (_hovered) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: active
                            ? AppColors.tealLight
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutTile() => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: widget.onLogout,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(21, 12, 12, 12),
        child: Row(
          children: [
            Icon(Icons.logout, size: 18, color: Colors.white.withOpacity(0.4)),
            if (_hovered) ...[
              const SizedBox(width: 12),
              Flexible(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Log Out',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
