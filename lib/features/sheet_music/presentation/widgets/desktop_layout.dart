import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';

/// Desktop layout widget that displays two panels side-by-side.
/// Left panel shows the list/browse view.
/// Right panel shows the detail/form view (if any).
class DesktopLayout extends StatelessWidget {
  /// The list widget to display on the left panel.
  final Widget listPanel;

  /// The detail widget to display on the right panel.
  /// If null, shows an empty placeholder.
  final Widget? detailPanel;

  /// Whether the detail panel should be shown.
  final bool showDetailPanel;

  /// Callback when close/back is pressed on detail panel.
  final VoidCallback? onDetailClose;

  /// Width ratio for the list panel (0.0 to 1.0).
  /// Default is 0.4 (40% of screen width).
  final double listPanelWidthRatio;

  const DesktopLayout({
    super.key,
    required this.listPanel,
    this.detailPanel,
    this.showDetailPanel = false,
    this.onDetailClose,
    this.listPanelWidthRatio = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop();

    if (!isDesktop) {
      // On mobile, just show the list panel
      return listPanel;
    }

    return Row(
      children: [
        // Left panel - List view
        SizedBox(
          width: MediaQuery.of(context).size.width * listPanelWidthRatio,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: listPanel,
          ),
        ),

        // Right panel - Detail view
        Expanded(
          child: showDetailPanel && detailPanel != null
              ? Stack(
                  children: [
                    detailPanel!,
                    // Close button in top-right corner
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: onDetailClose,
                        child: const Icon(Icons.close),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.select_all,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select an item from the list',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
