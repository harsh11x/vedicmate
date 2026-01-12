import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/animations.dart';

/// Shimmer loading skeleton widget
class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.forestBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Pandit card skeleton
class PanditCardSkeleton extends StatelessWidget {
  const PanditCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingSkeleton(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 12),
          LoadingSkeleton(width: 120, height: 16),
          const SizedBox(height: 8),
          LoadingSkeleton(width: 80, height: 12),
          const SizedBox(height: 12),
          LoadingSkeleton(width: 60, height: 24, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

/// List skeleton loader
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListSkeletonLoader({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

