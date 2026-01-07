import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1024;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1024;
  
  // Responsive padding
  static EdgeInsets padding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  // Responsive font sizes
  static double fontSize(BuildContext context, double mobile, {double? tablet, double? desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile * 1.2;
    return desktop ?? mobile * 1.5;
  }
  
  // Responsive spacing
  static double spacing(BuildContext context, double mobile, {double? tablet, double? desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile * 1.2;
    return desktop ?? mobile * 1.5;
  }
  
  // Responsive width (percentage of screen)
  static double width(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }
  
  // Responsive height (percentage of screen)
  static double height(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }
  
  // Get responsive value based on screen size
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }
}

// Responsive button widget
class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? minHeight;
  
  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.padding,
    this.minWidth,
    this.minHeight,
  });
  
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? (isMobile ? 120 : 150),
        minHeight: minHeight ?? (isMobile ? 44 : 48),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: style?.copyWith(
          padding: WidgetStateProperty.all(
            padding ?? EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ) ?? ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 16,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      ),
    );
  }
}

// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    
    return Text(
      text,
      style: baseStyle?.copyWith(
        fontSize: baseStyle.fontSize != null
            ? (isMobile ? baseStyle.fontSize : baseStyle.fontSize! * 1.1)
            : null,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}

