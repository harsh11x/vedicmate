import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ServiceReportScreen extends StatelessWidget {
  final String report;
  final String title;

  const ServiceReportScreen({
    super.key,
    required this.report,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.mediumShadow,
          ),
          child: Text(
            report,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

