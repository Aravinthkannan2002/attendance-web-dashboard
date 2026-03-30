import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_theme.dart';
import '../core/routes.dart';
import '../services/web_auth_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_popup.dart';

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
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.02),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(Get.currentRoute),
                      child: child,
                    ),
                  ),
                ),
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
    final sidebarBg = AppTheme.sidebarColorOf(context);

    return Drawer(
      backgroundColor: sidebarBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Close button row
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: _SidebarContent(collapsed: false, isDrawer: true),
              ),
            ],
          ),
        ],
      ),
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
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
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
      child: Stack(
        children: [
          // Subtle gradient overlay (lighter at top)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          _SidebarContent(collapsed: collapsed),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final bool collapsed;
  final bool isDrawer;
  const _SidebarContent({required this.collapsed, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return Column(
      children: [
        // Logo area
        if (!isDrawer) ...[
          Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
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
        ] else ...[
          // Drawer logo area (smaller, since close button is above)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
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
                const SizedBox(width: 12),
                const Column(
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
            ),
          ),
        ],

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

        // Subtle separator with padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        _LogoutButton(collapsed: collapsed),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
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

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _hoverController;
  late final Animation<double> _hoverAnimation;

  bool get isActive => widget.currentRoute == widget.route;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    );
    _hoverController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    _isHovered = hovering;
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 8 : 12,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Material(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(
                  alpha: 0.08 * _hoverAnimation.value),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isActive
                ? null
                : () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.pop(context);
                    }
                    Get.offAllNamed(widget.route);
                  },
            hoverColor: Colors.transparent,
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: widget.collapsed
                ? _buildCollapsed()
                : _buildExpanded(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Tooltip(
      message: widget.label,
      child: Stack(
        children: [
          // Left accent bar for active item (collapsed)
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 3,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            height: 44,
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: _isHovered && !isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isActive ? widget.activeIcon : widget.icon,
                color: isActive ? Colors.white : Colors.white54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          // Left accent bar with smooth animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 3,
            height: isActive ? 28 : 0,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accentColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(1, 0),
                      ),
                    ]
                  : [],
            ),
          ),
          SizedBox(width: isActive ? 10 : 12),
          Icon(
            isActive ? widget.activeIcon : widget.icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Subtle arrow indicator on hover
          AnimatedOpacity(
            opacity: _isHovered && !isActive ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final bool collapsed;
  const _LogoutButton({this.collapsed = false});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 8 : 12,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.transparent,
              onTap: () {
                AppPopup.show(
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmText: 'Sign Out',
                  cancelText: 'Cancel',
                  isDestructive: true,
                  onConfirm: () {
                    Get.back();
                    if (Get.isRegistered<AuthController>()) {
                      Get.find<AuthController>().logout();
                    } else {
                      final auth = Get.find<WebAuthService>();
                      auth.logout().then(
                          (_) => Get.offAllNamed(AppRoutes.login));
                    }
                  },
                );
              },
              child: widget.collapsed
                  ? Tooltip(
                      message: 'Sign Out',
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: AnimatedScale(
                          scale: _isHovered ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.logout_rounded,
                            color: _isHovered
                                ? Colors.red.shade300
                                : Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 9),
                          Icon(
                            Icons.logout_rounded,
                            color: _isHovered
                                ? Colors.red.shade300
                                : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: _isHovered
                                  ? Colors.red.shade300
                                  : Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  IconData _pageIconFromRoute(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return Icons.dashboard;
      case AppRoutes.employees:
        return Icons.people;
      case AppRoutes.attendance:
        return Icons.event_note;
      case AppRoutes.reports:
        return Icons.assessment;
      default:
        return Icons.dashboard;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<WebAuthService>();
    final themeController = Get.find<DashboardThemeController>();
    final currentRoute = Get.currentRoute;
    final pageTitle = _pageTitleFromRoute(currentRoute);
    final pageIcon = _pageIconFromRoute(currentRoute);
    final cardBg = AppTheme.cardColorOf(context);
    final txtPrimary = AppTheme.textPrimaryOf(context);
    final txtSecondary = AppTheme.textSecondaryOf(context);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: 8,
      ),
      child: Row(
        children: [
          if (showMenuButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: Icon(Icons.menu_rounded, color: txtPrimary),
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppTheme.surfaceColorOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

          // Breadcrumb / page indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  pageIcon,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCompact)
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 11,
                        color: txtSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  Text(
                    pageTitle,
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: txtPrimary,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Dark mode toggle with rotation animation
          Obx(() => _AnimatedThemeToggle(
                isDarkMode: themeController.isDarkMode.value,
                onPressed: themeController.toggleTheme,
                color: txtSecondary,
              )),

          if (!isCompact) ...[
            const SizedBox(width: 8),

            // Today's date
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.borderColorOf(context)
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
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

          // Admin info with avatar initials
          Obx(() {
            final adminName = authService.adminName.value.isNotEmpty
                ? authService.adminName.value
                : 'Admin';
            final initials = _getInitials(adminName);

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  // Avatar circle with initials
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryLight,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: txtPrimary,
                          ),
                        ),
                        if (authService.companyName.value.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
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
                    ),
                  ],
                ],
              ),
            );
          }),
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

// ── Animated theme toggle with rotation ───────────────────────────────────

class _AnimatedThemeToggle extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;
  final Color color;

  const _AnimatedThemeToggle({
    required this.isDarkMode,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<_AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isDarkMode ? 1.0 : 0.0,
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      if (widget.isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed,
      tooltip: widget.isDarkMode
          ? 'Switch to Light Mode'
          : 'Switch to Dark Mode',
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.surfaceColorOf(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Transform.rotate(
        angle: _controller.value * math.pi,
        child: Icon(
          widget.isDarkMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          size: 20,
          color: widget.isDarkMode
              ? Colors.amber.shade300
              : widget.color,
        ),
      ),
    );
  }
}
