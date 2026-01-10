import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../models/booking_model.dart';
import 'pandit_rates_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _OverviewTab(),
          _PanditsTab(),
          _MonitoringTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Pandits',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_outlined),
            selectedIcon: Icon(Icons.monitor),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Active Pandits',
                value: '234',
                icon: Icons.people,
                color: AppTheme.successGreen,
              ),
              _StatCard(
                title: 'Total Clients',
                value: '12,456',
                icon: Icons.person,
                color: AppTheme.yellowPrimary,
              ),
              _StatCard(
                title: 'Today\'s Revenue',
                value: '₹45,230',
                icon: Icons.account_balance_wallet,
                color: AppTheme.yellowPrimary,
              ),
              _StatCard(
                title: 'Platform Fee',
                value: '₹15,830',
                icon: Icons.monetization_on,
                color: AppTheme.goldAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _ActivityList(),
        ],
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActivityItem(
          icon: Icons.person_add,
          title: 'New Pandit Registered',
          subtitle: 'Pandit Ravi Shankar',
          time: '2 hours ago',
        ),
        _ActivityItem(
          icon: Icons.verified,
          title: 'Pandit Verified',
          subtitle: 'Pandit Priya Sharma',
          time: '5 hours ago',
        ),
        _ActivityItem(
          icon: Icons.block,
          title: 'Pandit Blocked',
          subtitle: 'Pandit John Doe',
          time: '1 day ago',
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.yellowPrimary.withOpacity(0.2),
          child: Icon(icon, color: AppTheme.yellowPrimary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _PanditsTab extends StatefulWidget {
  const _PanditsTab();

  @override
  State<_PanditsTab> createState() => _PanditsTabState();
}

class _PanditsTabState extends State<_PanditsTab> {
  String _filter = 'all'; // all, active, pending, blocked

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.creamPrimary,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Active',
                  isSelected: _filter == 'active',
                  onTap: () => setState(() => _filter = 'active'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Blocked',
                  isSelected: _filter == 'blocked',
                  onTap: () => setState(() => _filter = 'blocked'),
                ),
              ],
            ),
          ),
        ),
        // Add Pandit Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddPanditDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New Pandit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellowPrimary,
              foregroundColor: AppTheme.textDark,
            ),
          ),
        ),
        // Pandits List
        Expanded(
          child: _PanditsList(filter: _filter),
        ),
      ],
    );
  }

  void _showAddPanditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddPanditDialog(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellowPrimary : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.yellowPrimary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textDark : AppTheme.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PanditsList extends StatelessWidget {
  final String filter;

  const _PanditsList({required this.filter});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final pandits = [
      _PanditAdminData(
        id: '1',
        name: 'Pandit Ravi Shankar',
        status: 'active',
        rating: 4.8,
        totalCalls: 234,
        callMinutes: 1250,
        chatMinutes: 890,
        todayEarnings: 2500.0,
        totalEarnings: 125000.0,
        isBlocked: false,
      ),
      _PanditAdminData(
        id: '2',
        name: 'Pandit Priya Sharma',
        status: 'active',
        rating: 4.9,
        totalCalls: 189,
        callMinutes: 980,
        chatMinutes: 650,
        todayEarnings: 1800.0,
        totalEarnings: 98000.0,
        isBlocked: false,
      ),
      _PanditAdminData(
        id: '3',
        name: 'Pandit John Doe',
        status: 'blocked',
        rating: 3.5,
        totalCalls: 45,
        callMinutes: 230,
        chatMinutes: 120,
        todayEarnings: 0.0,
        totalEarnings: 12000.0,
        isBlocked: true,
      ),
    ];

    final filtered = filter == 'all'
        ? pandits
        : pandits.where((p) => p.status == filter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _PanditAdminCard(pandit: filtered[index]);
      },
    );
  }
}

class _PanditAdminData {
  final String id;
  final String name;
  final String status;
  final double rating;
  final int totalCalls;
  final int callMinutes;
  final int chatMinutes;
  final double todayEarnings;
  final double totalEarnings;
  final bool isBlocked;

  _PanditAdminData({
    required this.id,
    required this.name,
    required this.status,
    required this.rating,
    required this.totalCalls,
    required this.callMinutes,
    required this.chatMinutes,
    required this.todayEarnings,
    required this.totalEarnings,
    required this.isBlocked,
  });
}

class _PanditAdminCard extends StatelessWidget {
  final _PanditAdminData pandit;

  const _PanditAdminCard({required this.pandit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: pandit.isBlocked ? Colors.red : AppTheme.yellowPrimary,
          child: Text(
            pandit.name[0],
            style: const TextStyle(color: AppTheme.white),
          ),
        ),
        title: Text(pandit.name),
        subtitle: Text('Rating: ${pandit.rating} ⭐ | Status: ${pandit.status}'),
        trailing: pandit.isBlocked
            ? const Chip(
                label: Text('BLOCKED'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: AppTheme.white),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Total Calls', value: '${pandit.totalCalls}'),
                _InfoRow(label: 'Call Minutes', value: '${pandit.callMinutes} min'),
                _InfoRow(label: 'Chat Minutes', value: '${pandit.chatMinutes} min'),
                _InfoRow(
                  label: 'Today\'s Earnings',
                  value: '₹${pandit.todayEarnings.toStringAsFixed(2)}',
                ),
                _InfoRow(
                  label: 'Total Earnings',
                  value: '₹${pandit.totalEarnings.toStringAsFixed(2)}',
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Edit pandit
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showBlockDialog(context, pandit);
                        },
                        icon: Icon(pandit.isBlocked ? Icons.check : Icons.block),
                        label: Text(pandit.isBlocked ? 'Unblock' : 'Block'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pandit.isBlocked
                              ? AppTheme.successGreen
                              : Colors.red,
                          foregroundColor: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Monitor live
                    context.push('/admin/monitor/${pandit.id}');
                  },
                  icon: const Icon(Icons.monitor),
                  label: const Text('Live Monitor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yellowPrimary,
                    foregroundColor: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context, _PanditAdminData pandit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pandit.isBlocked ? 'Unblock Pandit' : 'Block Pandit'),
        content: Text(
          pandit.isBlocked
              ? 'Are you sure you want to unblock ${pandit.name}?'
              : 'Are you sure you want to block ${pandit.name}? This will prevent them from accessing the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle block/unblock
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    pandit.isBlocked
                        ? '${pandit.name} has been unblocked'
                        : '${pandit.name} has been blocked',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pandit.isBlocked ? AppTheme.successGreen : Colors.red,
            ),
            child: Text(pandit.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _AddPanditDialog extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  _AddPanditDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Pandit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add pandit logic
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Live Monitoring',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _MonitoringCard(
          panditName: 'Pandit Ravi Shankar',
          callType: 'Video Call',
          duration: '15:30',
          clientName: 'Client A',
          onView: () {},
        ),
        _MonitoringCard(
          panditName: 'Pandit Priya Sharma',
          callType: 'Chat',
          duration: '8:45',
          clientName: 'Client B',
          onView: () {},
        ),
      ],
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  final String panditName;
  final String callType;
  final String duration;
  final String clientName;
  final VoidCallback onView;

  const _MonitoringCard({
    required this.panditName,
    required this.callType,
    required this.duration,
    required this.clientName,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.fiber_manual_record, color: AppTheme.white, size: 16),
        ),
        title: Text(panditName),
        subtitle: Text('$callType with $clientName'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              duration,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton(
              onPressed: onView,
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        _SettingsTile(
          icon: Icons.rate_review,
          title: 'Set Pandit Rates',
          subtitle: 'Configure per-minute rates for calls and chats',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PanditRatesScreen(
                  panditId: '1',
                  panditName: 'Pandit Ravi Shankar',
                ),
              ),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.security,
          title: 'Security Settings',
          subtitle: 'Manage admin security',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Configure notification settings',
          onTap: () {},
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.yellowPrimary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}



