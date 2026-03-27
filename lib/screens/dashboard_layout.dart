import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_theme.dart';
import '../core/routes.dart';
import '../services/web_auth_service.dart';
import '../controllers/auth_controller.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1100;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColorOf(context),
      drawer: isMobile ? const _DrawerSidebar() : null,
      body: Row(
        children: [
          if (!isMobile)
            _Sidebar(collapsed: isTablet),

          Expanded(
            child: Column(
              children: [
                _TopBar(showMenuButton: isMobile),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Sidebar (mobile) ──────────────────────────────────────────────

class _DrawerSidebar extends StatelessWidget {
  const _DrawerSidebar();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.sidebarColorOf(context),
      child: _SidebarContent(collapsed: false),
    );
  }
}

// ── Sidebar ────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final bool collapsed;
  const _Sidebar({this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final sidebarBg = AppTheme.sidebarColorOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 72 : 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _SidebarContent(collapsed: collapsed),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final bool collapsed;
  const _SidebarContent({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return Column(
      children: [
        // Logo area
        Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
          ),
          child: Row(
            mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FaceAttend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Admin Portal',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (!collapsed)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        if (!collapsed) const SizedBox(height: 4),

        _NavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Overview',
          route: AppRoutes.dashboard,
          currentRoute: currentRoute,
          collapsed: collapsed,
        ),
        _NavItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: 'Employees',
          route: AppRoutes.employees,
          currentRoute: currentRoute,
          collapsed: collapsed,
        ),
        _NavItem(
          icon: Icons.event_note_outlined,
          activeIcon: Icons.event_note,
          label: 'Attendance',
          route: AppRoutes.attendance,
          currentRoute: currentRoute,
          collapsed: collapsed,
        ),
        _NavItem(
          icon: Icons.assessment_outlined,
          activeIcon: Icons.assessment,
          label: 'Reports',
          route: AppRoutes.reports,
          currentRoute: currentRoute,
          collapsed: collapsed,
        ),

        const Spacer(),

        Divider(
          color: Colors.white.withValues(alpha: 0.1),
          height: 1,
          indent: collapsed ? 12 : 20,
          endIndent: collapsed ? 12 : 20,
        ),
        const SizedBox(height: 8),

        _LogoutButton(collapsed: collapsed),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentRoute;
  final bool collapsed;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.collapsed = false,
  });

  bool get isActive => currentRoute == route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12, vertical: 2),
      child: Material(
        color: isActive
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isActive
              ? null
              : () {
                  if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                    Navigator.pop(context);
                  }
                  Get.offAllNamed(route);
                },
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: collapsed
              ? Tooltip(
                  message: label,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? Colors.white : Colors.white54,
                      size: 20,
                    ),
                  ),
                )
              : Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 3,
                        height: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (isActive) const SizedBox(width: 6),
                      Icon(
                        isActive ? activeIcon : icon,
                        color: isActive ? Colors.white : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool collapsed;
  const _LogoutButton({this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.red.withValues(alpha: 0.15),
          onTap: () {
            if (Get.isRegistered<AuthController>()) {
              Get.find<AuthController>().logout();
            } else {
              final auth = Get.find<WebAuthService>();
              auth.logout().then((_) => Get.offAllNamed(AppRoutes.login));
            }
          },
          child: collapsed
              ? Tooltip(
                  message: 'Sign Out',
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(Icons.logout, color: Colors.white54, size: 20),
                  ),
                )
              : Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Row(
                    children: [
                      SizedBox(width: 9),
                      Icon(Icons.logout, color: Colors.white54, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool showMenuButton;
  const _TopBar({this.showMenuButton = false});

  String _pageTitleFromRoute(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 'Overview';
      case AppRoutes.employees:
        return 'Employees';
      case AppRoutes.attendance:
        return 'Attendance';
      case AppRoutes.reports:
        return 'Reports';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<WebAuthService>();
    final themeController = Get.find<DashboardThemeController>();
    final currentRoute = Get.currentRoute;
    final pageTitle = _pageTitleFromRoute(currentRoute);
    final cardBg = AppTheme.cardColorOf(context);
    final border = AppTheme.borderColorOf(context);
    final txtPrimary = AppTheme.textPrimaryOf(context);
    final txtSecondary = AppTheme.textSecondaryOf(context);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24, vertical: 8),
      child: Row(
        children: [
          if (showMenuButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: Icon(Icons.menu, color: txtPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

          Text(
            pageTitle,
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: txtPrimary,
              letterSpacing: -0.3,
            ),
          ),

          const Spacer(),

          // Dark mode toggle
          Obx(() => IconButton(
                onPressed: themeController.toggleTheme,
                tooltip: themeController.isDarkMode.value
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(
                  themeController.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 20,
                  color: txtSecondary,
                ),
              )),

          if (!isCompact) ...[
            const SizedBox(width: 8),

            // Today's date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: txtSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 13,
                      color: txtSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),
          ],

          // Admin info
          Obx(() => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.adminName.value.isNotEmpty
                                ? authService.adminName.value
                                : 'Admin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: txtPrimary,
                            ),
                          ),
                          if (authService.companyName.value.isNotEmpty)
                            Text(
                              authService.companyName.value,
                              style: TextStyle(
                                fontSize: 11,
                                color: txtSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$dayName, $month ${dt.day}, ${dt.year}';
  }
}
