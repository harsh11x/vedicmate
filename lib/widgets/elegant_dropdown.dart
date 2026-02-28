import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ElegantDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hint;
  final IconData prefixIcon;
  final bool searchable;

  const ElegantDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    required this.hint,
    required this.prefixIcon,
    this.searchable = false,
  });

  @override
  State<ElegantDropdown<T>> createState() => _ElegantDropdownState<T>();
}

class _ElegantDropdownState<T> extends State<ElegantDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divineGold.withOpacity(0.1)),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  children: widget.items.map((item) {
                    return InkWell(
                      onTap: () {
                        widget.onChanged?.call(item.value);
                        _closeDropdown();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: item.child,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.divineSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textBlack,
              width: _isOpen ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.prefixIcon, color: AppTheme.primaryOrange, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.value?.toString() ?? widget.hint,
                  style: AppTheme.bodyStyle.copyWith(
                    color: widget.value == null ? AppTheme.textLight : AppTheme.textBlack,
                    fontWeight: widget.value == null ? FontWeight.normal : FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
