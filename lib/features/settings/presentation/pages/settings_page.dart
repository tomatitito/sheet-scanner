import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings/configuration screen for the app.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Backup & Export
            _SettingsSection(
              title: 'Backup & Export',
              children: [
                ListTile(
                  title: const Text('Backup & Import'),
                  subtitle: const Text('Export data or import from backup'),
                  trailing: const Icon(Icons.backup),
                  onTap: () {
                    context.push('/backup');
                  },
                ),
              ],
            ),

            // Theme Settings
            _SettingsSection(
              title: 'Appearance',
              children: [
                ListTile(
                  title: const Text('Theme Mode'),
                  subtitle: const Text('Light mode (Coming soon)'),
                  trailing: const Icon(Icons.brightness_7),
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),

            // Database Settings
            _SettingsSection(
              title: 'Database',
              children: [
                ListTile(
                  title: const Text('Database Size'),
                  subtitle: const Text('Calculating...'),
                  trailing: const Icon(Icons.storage),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Cleanup Cache'),
                  subtitle: const Text('Remove temporary files'),
                  trailing: const Icon(Icons.delete_sweep),
                  onTap: () {
                    _showClearCacheDialog(context);
                  },
                ),
              ],
            ),

            // Search & Tags Settings
            _SettingsSection(
              title: 'Search & Tags',
              children: [
                const SwitchListTile(
                  title: Text('Full-Text Search'),
                  subtitle:
                      Text('Enable FTS5 for faster searches (Coming soon)'),
                  value: true,
                  onChanged: null,
                ),
                ListTile(
                  title: const Text('Manage Tags'),
                  subtitle: const Text('Create, delete, and merge tags'),
                  trailing: const Icon(Icons.local_offer),
                  onTap: () {
                    context.push('/tags');
                  },
                ),
              ],
            ),

            // About
            _SettingsSection(
              title: 'About',
              children: [
                ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.info),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('License'),
                  subtitle:
                      const Text('View license information (Coming soon)'),
                  trailing: const Icon(Icons.article),
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove temporary files and cache data. '
          'This operation cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for grouping settings sections
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
