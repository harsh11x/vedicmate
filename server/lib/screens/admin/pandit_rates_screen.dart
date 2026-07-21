import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PanditRatesScreen extends StatefulWidget {
  final String panditId;
  final String panditName;

  const PanditRatesScreen({
    super.key,
    required this.panditId,
    required this.panditName,
  });

  @override
  State<PanditRatesScreen> createState() => _PanditRatesScreenState();
}

class _PanditRatesScreenState extends State<PanditRatesScreen> {
  final _videoCallController = TextEditingController();
  final _chatController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing rates if any
    _videoCallController.text = '5';
    _chatController.text = '2';
  }

  @override
  void dispose() {
    _videoCallController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _saveRates() {
    if (_videoCallController.text.isEmpty ||
        _chatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all rate fields'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Save rates logic
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rates saved successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Pandit Rates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pandit Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.yellowPrimary,
                      child: Icon(Icons.person, color: AppTheme.textDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.panditName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'ID: ${widget.panditId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.yellowPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.yellowPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set per-minute rates for this Pandit. Revenue split: 65% to Pandit, 35% platform fee.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Rate Inputs
            Text(
              'Service Rates (₹ per minute)',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Video Call Rate
            _RateInputCard(
              icon: Icons.videocam,
              title: 'Video Call',
              subtitle: 'Rate per minute for video consultations',
              controller: _videoCallController,
            ),
            const SizedBox(height: 12),
            // Chat Rate
            _RateInputCard(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Rate per minute for chat consultations',
              controller: _chatController,
            ),
            const SizedBox(height: 32),
            // Revenue Split Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Split',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _RevenueRow(
                      label: 'Pandit Share',
                      percentage: '65%',
                      color: AppTheme.successGreen,
                    ),
                    _RevenueRow(
                      label: 'Platform Fee',
                      percentage: '35%',
                      color: AppTheme.yellowPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRates,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellowPrimary,
                foregroundColor: AppTheme.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Rates'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateInputCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final TextEditingController controller;

  const _RateInputCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.yellowPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Rate (₹/min)',
                prefixText: '₹ ',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.yellowPrimary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label;
  final String percentage;
  final Color color;

  const _RevenueRow({
    required this.label,
    required this.percentage,
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percentage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

