import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';

/// Navigation item for the desktop sidebar.
class SidebarNavItem {
  final String label;
  final IconData icon;
  final String routeName;
  final String? tooltip;

  const SidebarNavItem({
    required this.label,
    required this.icon,
    required this.routeName,
    this.tooltip,
  });
}

/// Desktop sidebar navigation widget with collapsible support.
/// Provides vertical navigation for desktop apps with icon + label layout.
class DesktopSidebar extends StatefulWidget {
  /// Navigation items to display
  final List<SidebarNavItem> items;

  /// Current route name for highlighting
  final String currentRoute;

  /// Callback when an item is tapped
  final Function(SidebarNavItem) onItemTapped;

  /// Whether sidebar starts in expanded state
  final bool initiallyExpanded;

  /// Width of expanded sidebar
  final double expandedWidth;

  /// Width of collapsed sidebar
  final double collapsedWidth;

  const DesktopSidebar({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onItemTapped,
    this.initiallyExpanded = true,
    this.expandedWidth = 250,
    this.collapsedWidth = 80,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isDesktop()) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final width = widget.collapsedWidth +
            (_animationController.value *
                (widget.expandedWidth - widget.collapsedWidth));

        return Container(
          width: width,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            children: [
              // Navigation items
              Column(
                children: [
                  // App title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_music,
                          color: Theme.of(context).primaryColor,
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Library',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  // Navigation items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isActive = widget.currentRoute == item.routeName;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: _buildNavItem(
                            context,
                            item,
                            isActive,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Collapse/Expand button
              Positioned(
                bottom: 16,
                left: 8,
                right: 8,
                child: Tooltip(
                  message: _isExpanded ? 'Collapse' : 'Expand',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSidebar,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _isExpanded
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    SidebarNavItem item,
    bool isActive,
  ) {
    return Tooltip(
      message: item.tooltip ?? item.label,
      child: Material(
        color: isActive
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => widget.onItemTapped(item),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border(
                      left: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                    size: 22,
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
