import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColorOf(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            return _MobileLayout(controller: controller);
          }
          return _DesktopLayout(controller: controller);
        },
      ),
    );
  }
}

// ── Desktop split layout ───────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final AuthController controller;
  const _DesktopLayout({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left branding panel with striking gradient overlay
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.6, 1.0],
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative radial glow
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -60,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const _BrandingPanel(),
              ],
            ),
          ),
        ),

        // Decorative vertical separator between branding and form
        Container(
          width: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.0),
                AppTheme.primaryColor.withValues(alpha: 0.3),
                AppTheme.primaryColor.withValues(alpha: 0.5),
                AppTheme.primaryColor.withValues(alpha: 0.3),
                AppTheme.primaryColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),

        // Right form panel
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.cardColorOf(context),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _LoginCard(controller: controller),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile layout ──────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final AuthController controller;
  const _MobileLayout({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0D47A1),
            Color(0xFF1E88E5),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _MiniLogo(),
              const SizedBox(height: 12),
              // Decorative dot row separator
              _DotSeparator(),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: _LoginForm(controller: controller),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dot separator decoration ───────────────────────────────────────────────

class _DotSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == 2 ? 8 : 5,
          height: i == 2 ? 8 : 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: i == 2 ? 0.6 : 0.25),
          ),
        ),
      ),
    );
  }
}

// ── Branding panel (left side on desktop) ─────────────────────────────────

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 32),

          // App name
          Text(
            'FaceAttend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 48),

          // Feature bullets with hover animation
          ...[
            ('Manage employees and attendance records', Icons.people_outline),
            ('Real-time analytics and insights', Icons.bar_chart_outlined),
            ('Face recognition attendance tracking', Icons.camera_alt_outlined),
            ('Export data for payroll processing', Icons.download_outlined),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  _HoverScaleIcon(icon: item.$2),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Decorative dot row before footer
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: List.generate(
                20,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Text(
            '\u00a9 ${DateTime.now().year} FaceAttend. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hover scale icon for feature bullets ──────────────────────────────────

class _HoverScaleIcon extends StatefulWidget {
  final IconData icon;
  const _HoverScaleIcon({required this.icon});

  @override
  State<_HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<_HoverScaleIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hovering ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}

// ── Mini logo for mobile ───────────────────────────────────────────────────

class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white30, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.face_retouching_natural,
            color: Colors.white,
            size: 34,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'FaceAttend',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Login card wrapper (desktop) with shadow and entrance animation ───────

class _LoginCard extends StatefulWidget {
  final AuthController controller;
  const _LoginCard({required this.controller});

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppTheme.cardColorOf(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderColorOf(context).withValues(alpha: 0.5),
            ),
          ),
          child: _LoginForm(controller: widget.controller),
        ),
      ),
    );
  }
}

// ── Focus-aware prefix icon ───────────────────────────────────────────────

class _FocusAwarePrefixIcon extends StatefulWidget {
  final IconData icon;
  final FocusNode focusNode;
  const _FocusAwarePrefixIcon({required this.icon, required this.focusNode});

  @override
  State<_FocusAwarePrefixIcon> createState() => _FocusAwarePrefixIconState();
}

class _FocusAwarePrefixIconState extends State<_FocusAwarePrefixIcon> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        widget.icon,
        key: ValueKey(_focused),
        size: 20,
        color: _focused
            ? AppTheme.primaryColor
            : AppTheme.textSecondaryOf(context),
      ),
    );
  }
}

// ── Login form ─────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  final AuthController controller;
  const _LoginForm({required this.controller});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm>
    with SingleTickerProviderStateMixin {
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  // Entrance animation for mobile usage (when not wrapped by _LoginCard)
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Form(
          key: widget.controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Heading
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign in to your admin account',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.85),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32),

              // Email field
              Text(
                'Email address',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              SizedBox(height: 6),
              TextFormField(
                controller: widget.controller.emailController,
                validator: widget.controller.validateEmail,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  hintText: 'admin@company.com',
                  prefixIcon: _FocusAwarePrefixIcon(
                    icon: Icons.email_outlined,
                    focusNode: _emailFocus,
                  ),
                ),
                onFieldSubmitted: (_) => widget.controller.login(),
              ),
              SizedBox(height: 20),

              // Password field
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => TextFormField(
                  controller: widget.controller.passwordController,
                  validator: widget.controller.validatePassword,
                  focusNode: _passwordFocus,
                  obscureText: widget.controller.obscurePassword.value,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                    prefixIcon: _FocusAwarePrefixIcon(
                      icon: Icons.lock_outline,
                      focusNode: _passwordFocus,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        widget.controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                      onPressed: widget.controller.togglePasswordVisibility,
                    ),
                  ),
                  onFieldSubmitted: (_) => widget.controller.login(),
                ),
              ),
              SizedBox(height: 28),

              // Login button with gradient
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: widget.controller.isLoading.value
                          ? null
                          : const LinearGradient(
                              colors: [
                                Color(0xFF0D47A1),
                                Color(0xFF1565C0),
                                Color(0xFF1E88E5),
                              ],
                            ),
                      color: widget.controller.isLoading.value
                          ? AppTheme.primaryColor.withValues(alpha: 0.6)
                          : null,
                      boxShadow: widget.controller.isLoading.value
                          ? null
                          : [
                              BoxShadow(
                                color:
                                    AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.controller.isLoading.value
                          ? null
                          : widget.controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: widget.controller.isLoading.value
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Info / help note with improved styling
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 15,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin access only',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Contact your administrator if you need help signing in.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.primaryColor.withValues(alpha: 0.75),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
