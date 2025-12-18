import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enhanced animation utilities for smooth UI/UX
class AppAnimations {
  // Standard animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Standard curves
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  /// Fade in animation
  static Animation<double> fadeIn({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Slide animation
  static Animation<Offset> slideIn({
    required AnimationController controller,
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
    Curve curve = standardCurve,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Scale animation
  static Animation<double> scaleIn({
    required AnimationController controller,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Rotation animation
  static Animation<double> rotate({
    required AnimationController controller,
    double begin = 0.0,
    double end = 2 * math.pi,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Staggered animation for lists
  static Animation<double> staggered({
    required AnimationController controller,
    required int index,
    required int total,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    final delay = (index / total) * 0.3;
    final interval = Interval(delay, delay + 0.7, curve: curve);
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: interval),
    );
  }

  /// Pulse animation
  static Animation<double> pulse({
    required AnimationController controller,
    double min = 0.95,
    double max = 1.05,
  }) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: min, end: max), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: max, end: min), weight: 1),
    ]).animate(controller);
  }

  /// Shimmer animation
  static Animation<double> shimmer({
    required AnimationController controller,
  }) {
    return Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
  }
}

/// Reusable animated container widget
class AnimatedScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;

  const AnimatedScaleWidget({
    super.key,
    required this.child,
    this.onTap,
    this.duration = AppAnimations.fast,
    this.scale = 0.95,
  });

  @override
  State<AnimatedScaleWidget> createState() => _AnimatedScaleWidgetState();
}

class _AnimatedScaleWidgetState extends State<AnimatedScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.standardCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated fade in widget
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = AppAnimations.normal,
    this.curve = AppAnimations.standardCurve,
    this.delay = 0.0,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = AppAnimations.fadeIn(
      controller: _controller,
      curve: widget.curve,
    );
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

/// Slide in from bottom widget
class SlideInBottomWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double delay;

  const SlideInBottomWidget({
    super.key,
    required this.child,
    this.duration = AppAnimations.normal,
    this.curve = AppAnimations.standardCurve,
    this.delay = 0.0,
  });

  @override
  State<SlideInBottomWidget> createState() => _SlideInBottomWidgetState();
}

class _SlideInBottomWidgetState extends State<SlideInBottomWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _slideAnimation = AppAnimations.slideIn(
      controller: _controller,
      begin: const Offset(0, 0.3),
      curve: widget.curve,
    );
    _fadeAnimation = AppAnimations.fadeIn(
      controller: _controller,
      curve: widget.curve,
    );
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered list animation wrapper
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.duration = AppAnimations.normal,
    this.curve = AppAnimations.standardCurve,
  });

  @override
  Widget build(BuildContext context) {
    return _StaggeredListAnimationWidget(
      children: children,
      duration: duration,
      curve: curve,
    );
  }
}

class _StaggeredListAnimationWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const _StaggeredListAnimationWidget({
    required this.children,
    required this.duration,
    required this.curve,
  });

  @override
  State<_StaggeredListAnimationWidget> createState() =>
      _StaggeredListAnimationWidgetState();
}

class _StaggeredListAnimationWidgetState
    extends State<_StaggeredListAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) {
          final animation = AppAnimations.staggered(
            controller: _controller,
            index: index,
            total: widget.children.length,
            curve: widget.curve,
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: widget.children[index],
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse animation widget
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = AppAnimations.pulse(
      controller: _controller,
      min: widget.minScale,
      max: widget.maxScale,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

