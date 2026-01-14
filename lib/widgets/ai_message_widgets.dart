import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';

/// Widget to render AI messages with clickable product links
class AIMessageText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AIMessageText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _parseMessageWithLinks(text);
    
    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5),
        children: spans,
      ),
    );
  }

  List<InlineSpan> _parseMessageWithLinks(String message) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');
    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      // Add text before the link
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      // Add the link
      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;
      
      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => _handleLinkTap(linkUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    linkText,
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }

  void _handleLinkTap(String url) {
    // Handle product links
    if (url.startsWith('/product/')) {
      // TODO: Navigate to product detail page
      // For now, just print
      print('Navigate to product: $url');
      // In actual implementation:
      // context.push(url);
    } else if (url.startsWith('http')) {
      // External link
      launchUrl(Uri.parse(url));
    }
  }
}

/// Product recommendation card to show in AI chat
class ProductRecommendationCard extends StatelessWidget {
  final String productName;
  final String productId;
  final String reason;
  final String? imageUrl;

  const ProductRecommendationCard({
    super.key,
    required this.productName,
    required this.productId,
    required this.reason,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryOrange.withOpacity(0.05),
            AppTheme.yellowPrimary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: AppTheme.primaryOrange,
              ),
            ),
          
          const SizedBox(width: 16),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.recommend,
                      size: 14,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to product page
                    print('View product: $productId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Product'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
