import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_model.dart';

class PanditDashboard extends StatefulWidget {
  const PanditDashboard({super.key});

  @override
  State<PanditDashboard> createState() => _PanditDashboardState();
}

class _PanditDashboardState extends State<PanditDashboard> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Blocked check removed for demo - in production, get actual Pandit ID from auth state
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   BlockedCheck.checkAndRedirect(context, panditId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _BookingsTab(),
          _AnalyticsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: AppTheme.mediumShadow,
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            height: MediaQuery.of(context).size.height * 0.08,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppTheme.primaryLight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 300),
            destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Pandit Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryOrange,
                    AppTheme.forestDark,
                    AppTheme.accentGold,
                  ],
                ),
                boxShadow: AppTheme.glowShadow,
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.wallet_outlined),
                onPressed: () {},
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Welcome Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.forestDark,
                        AppTheme.accentGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.glowShadow,
                    border: Border.all(
                      color: AppTheme.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          color: AppTheme.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Manage your consultations and earnings',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.white.withOpacity(0.95),
                                    fontSize: 14,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Today\'s Bookings',
                        value: '5',
                        icon: Icons.calendar_today,
                        color: AppTheme.yellowPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Revenue',
                        value: '₹12,500',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Rating',
                        value: '4.8',
                        icon: Icons.star,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Clients',
                        value: '234',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Upcoming Bookings
                Text(
                  'Upcoming Bookings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _buildUpcomingBookings(context),
                const SizedBox(height: 24),
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final cross = isWide ? 3 : 2;
                    final ratio = isWide ? 2.8 : 2.5;
                    return GridView.count(
                  crossAxisCount: cross,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: ratio,
                  children: [
                    _QuickActionCard(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    _QuickActionCard(
                      icon: Icons.schedule,
                      label: 'Set Availability',
                      onTap: () {},
                    ),
                    _QuickActionCard(
                      icon: Icons.price_change,
                      label: 'Update Pricing',
                      onTap: () {},
                    ),
                    _QuickActionCard(
                      icon: Icons.analytics,
                      label: 'View Analytics',
                      onTap: () {},
                    ),
                  ],
                );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookings(BuildContext context) {
    // Mock data
    final bookings = [
      BookingModel(
        id: '1',
        clientId: 'c1',
        panditId: 'p1',
        serviceType: 'Horoscope',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        duration: 30,
        amount: 500.0,
        platformFee: 75.0,
        gst: 103.5,
        totalAmount: 678.5,
        status: BookingStatus.confirmed,
        callType: 'video',
        createdAt: DateTime.now(),
      ),
    ];

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No upcoming bookings',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: bookings.map((booking) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.yellowPrimary,
              child: const Icon(Icons.person, color: AppTheme.white),
            ),
            title: Text(booking.serviceType),
            subtitle: Text(
              '${booking.scheduledAt.hour}:${booking.scheduledAt.minute.toString().padLeft(2, '0')}',
            ),
            trailing: ElevatedButton(
              onPressed: () => context.push('/call/video/${booking.id}'),
              child: const Text('Start'),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.mediumShadow,
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppTheme.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppTheme.neutralDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralMedium,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.yellowPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Manage Bookings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage all your bookings',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/bookings/history'),
            child: const Text('View All Bookings'),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Analytics',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _AnalyticsItem(
                  label: 'This Month',
                  value: '₹45,000',
                  color: AppTheme.yellowPrimary,
                ),
                _AnalyticsItem(
                  label: 'Last Month',
                  value: '₹38,500',
                  color: Colors.grey,
                ),
                _AnalyticsItem(
                  label: 'Total Revenue',
                  value: '₹2,45,000',
                  color: AppTheme.goldAccent,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Metrics',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _AnalyticsItem(
                  label: 'Average Rating',
                  value: '4.8 ⭐',
                  color: AppTheme.goldAccent,
                ),
                _AnalyticsItem(
                  label: 'Total Sessions',
                  value: '234',
                  color: Colors.blue,
                ),
                _AnalyticsItem(
                  label: 'Completion Rate',
                  value: '98%',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnalyticsItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.yellowPrimary,
          child: Icon(Icons.person, size: 50, color: AppTheme.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Pandit Name',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _ProfileTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () => context.push('/profile/edit'),
        ),
        _ProfileTile(
          icon: Icons.schedule,
          title: 'Availability Calendar',
          onTap: () {},
        ),
        _ProfileTile(
          icon: Icons.price_change,
          title: 'Service Pricing',
          onTap: () {},
        ),
        _ProfileTile(
          icon: Icons.wallet_outlined,
          title: 'Wallet & Earnings',
          onTap: () => context.push('/payment/wallet'),
        ),
        _ProfileTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => context.push('/settings'),
        ),
        _ProfileTile(
          icon: Icons.logout,
          title: 'Logout',
          onTap: () => context.go('/login'),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

