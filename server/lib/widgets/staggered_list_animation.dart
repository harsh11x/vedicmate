import 'package:flutter/material.dart';

class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final double verticalOffset;
  final Duration duration;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.verticalOffset = 50.0,
    this.duration = const Duration(milliseconds: 375),
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration * widget.children.length,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (1 / widget.children.length) * index,
              (1 / widget.children.length) * (index + 1),
              curve: Curves.easeOut,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, widget.verticalOffset * (1 - animation.value)),
                child: child,
              ),
            );
          },
          child: widget.children[index],
        );
      }),
    );
  }
}
