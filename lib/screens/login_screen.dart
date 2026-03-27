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
        // Left branding panel
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5),
                ],
              ),
            ),
            child: const _BrandingPanel(),
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
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: _LoginForm(controller: controller),
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _MiniLogo(),
              SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: _LoginForm(controller: controller),
                ),
              ),
            ],
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

          // Feature bullets
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.$2, color: Colors.white70, size: 18),
                  ),
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

          // Footer
          Text(
            '© ${DateTime.now().year} FaceAttend. All rights reserved.',
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

// ── Mini logo for mobile ───────────────────────────────────────────────────

class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white30, width: 1.5),
          ),
          child: Icon(
            Icons.face_retouching_natural,
            color: Colors.white,
            size: 32,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'FaceAttend',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ── Login form ─────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final AuthController controller;
  const _LoginForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
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
          SizedBox(height: 6),
          Text(
            'Sign in to your admin account',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryOf(context),
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
            controller: controller.emailController,
            validator: controller.validateEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              hintText: 'admin@company.com',
              prefixIcon: Icon(
                Icons.email_outlined,
                size: 20,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            onFieldSubmitted: (_) => controller.login(),
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
              controller: controller.passwordController,
              validator: controller.validatePassword,
              obscureText: controller.obscurePassword.value,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppTheme.textSecondaryOf(context),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              onFieldSubmitted: (_) => controller.login(),
            ),
          ),
          SizedBox(height: 28),

          // Login button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
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

          SizedBox(height: 20),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Only admin accounts can access this dashboard.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      height: 1.4,
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

