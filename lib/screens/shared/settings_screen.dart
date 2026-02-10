import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/font_scale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  final AuthService _authService = AuthService();
  String? _supabasePhone;
  String? _supabaseEmail;
  String? _supabaseName;

  @override
  void initState() {
    super.initState();
    _loadProfileFromSupabase();
  }

  Future<void> _loadProfileFromSupabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('phone, email, name')
          .eq('id', user.uid)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() {
          _supabasePhone = data['phone'] as String?;
          _supabaseEmail = data['email'] as String?;
          _supabaseName = data['name'] as String?;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for live updates
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull ?? FirebaseAuth.instance.currentUser;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              title: Text(
          AppLocalizations.of(context)!.settings,
                style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.yellowPrimary,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Enhanced Profile Card
          SliverToBoxAdapter(
            child: Padding(
        padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.forestDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: user?.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.primaryOrange,
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _supabaseName ?? user?.displayName ?? 'User',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _supabaseEmail ?? user?.email ?? 'No email',
                            style: TextStyle(
                              color: AppTheme.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.white.withOpacity(0.9)),
                                const SizedBox(width: 6),
                                Text(
                                  'Verified Account',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: AppTheme.white, size: 20),
                      ),
                      onPressed: () async {
                        await context.push('/profile/edit');
                        _loadProfileFromSupabase();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Wallet',
                      color: AppTheme.successGreen,
                      onTap: () => context.push('/client/wallet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.shopping_bag,
                      label: 'Orders',
                      color: AppTheme.primaryOrange,
                      onTap: () => context.push('/orders'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.handshake_outlined,
                      label: 'Requests',
                      color: AppTheme.accentGold,
                      onTap: () => context.push('/custom-requests/orders'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.history,
                      label: 'History',
                      color: AppTheme.infoBlue,
                      onTap: () => context.push('/bookings/history'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.favorite,
                      label: 'Favorites',
                      color: AppTheme.errorRed,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Favorites coming soon')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Account Settings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Account Settings'),
                  const SizedBox(height: 12),
                  _SettingsCard(
        children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () async {
                          await context.push('/profile/edit');
                          _loadProfileFromSupabase();
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
              icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () {
                          _showPasswordChangeDialog(context);
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        subtitle: (_supabasePhone != null && _supabasePhone!.isNotEmpty) ? _supabasePhone! : (user?.phoneNumber ?? 'Not set'),
                        onTap: () async {
                          await context.push('/profile/edit');
                          _loadProfileFromSupabase();
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        subtitle: (_supabaseEmail != null && _supabaseEmail!.isNotEmpty) ? _supabaseEmail! : (user?.email ?? 'Not set'),
              onTap: () async {
                await context.push('/profile/edit');
                _loadProfileFromSupabase();
              },
            ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // App Preferences
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'App Preferences'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
// Language settings removed as per user request (handled in chat only)
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: AppLocalizations.of(context)!.darkMode,
                        subtitle: 'Switch to dark theme',
                        trailing: Consumer(
                          builder: (context, ref, _) {
                            final themeMode = ref.watch(themeModeProvider);
                            final isDark = themeMode == ThemeMode.dark;
                            return Switch(
                              value: isDark,
                              onChanged: (value) {
                                ref.read(themeModeProvider.notifier).setFromBool(value);
                              },
                              activeColor: AppTheme.primaryOrange,
                            );
                          },
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.text_fields,
                        title: 'Font Size',
                        subtitle: 'Adjust text size',
                        trailing: Consumer(
                          builder: (context, ref, _) {
                            final fontScale = ref.watch(fontScaleProvider);
                            final preset = ref.read(fontScaleProvider.notifier).preset;
                            final notifier = ref.read(fontScaleProvider.notifier);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: fontScale > 0.85 ? () => notifier.decrement() : null,
                                  color: fontScale > 0.85 ? AppTheme.primaryOrange : AppTheme.neutralMedium,
                                ),
                                Text(preset.label, style: const TextStyle(fontSize: 12)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: fontScale < 1.3 ? () => notifier.increment() : null,
                                  color: fontScale < 1.3 ? AppTheme.primaryOrange : AppTheme.neutralMedium,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Notifications
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_active,
                        title: 'Push Notifications',
                        subtitle: 'Receive push notifications',
                        trailing: Switch(
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                          },
                          activeColor: AppTheme.primaryOrange,
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.email,
                        title: 'Email Notifications',
                        subtitle: 'Receive email updates',
                        trailing: Switch(
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                          },
                          activeColor: AppTheme.primaryOrange,
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.vibration,
                        title: 'Vibration',
                        subtitle: 'Vibrate on notifications',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                          activeColor: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Privacy & Security
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Privacy & Security'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {
                          _showPrivacyPolicy(context);
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.security,
                        title: 'Security Settings',
                        subtitle: 'Manage your security',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Security settings coming soon')),
                );
              },
            ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.block,
                        title: 'Blocked Users',
                        subtitle: 'Manage blocked accounts',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Blocked users coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Support & About
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Support & About'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        onTap: () {
                          _showHelpCenter(context);
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        onTap: () {
                          _showTermsOfService(context);
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About Vedic Mate',
                        subtitle: 'Version 1.0.0',
              onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.star_outline,
                        title: 'Rate Us',
                        subtitle: 'Rate us on Play Store',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rate us feature coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.logout,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  void _showPasswordChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: const Text('Password change feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text('Our privacy policy will be available soon.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help & Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _HelpItem(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+91 1800-123-4567',
              onTap: () {},
            ),
            _HelpItem(
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'support@vedicmate.com',
              onTap: () {},
            ),
            _HelpItem(
              icon: Icons.chat_bubble,
              title: 'Live Chat',
              subtitle: 'Available 24/7',
              onTap: () {},
            ),
            _HelpItem(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Frequently asked questions',
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text('Terms of service will be available soon.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vedic Mate',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryOrange, AppTheme.yellowPrimary],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.spa, color: AppTheme.white, size: 30),
      ),
      applicationLegalese: '© 2024 Vedic Mate. All rights reserved.\n\nVedic Mate is your trusted companion for spiritual guidance and astrological consultations. Connect with verified AI Pandits and get personalized insights.',
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.neutralDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralDark,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange.withOpacity(0.15),
                      AppTheme.yellowPrimary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryOrange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                            fontSize: 16,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralMedium,
                            fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(Icons.chevron_right, color: AppTheme.forestBackground, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.forestBackground.withOpacity(0.5),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryOrange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
