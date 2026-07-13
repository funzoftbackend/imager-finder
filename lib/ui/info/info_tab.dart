import 'package:flutter/material.dart';

import '../../app.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Info',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything stays on your device. Scans are optimized for speed, then cached for instant reopen.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            icon: Icons.bolt_rounded,
            title: 'Fast first scan',
            body:
                'Reads your gallery first, then finds exact duplicates and similar photos on device. Similar matches only link photos taken within 2 hours, using strict look-alike clustering (no giant mixed groups).',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.storage_rounded,
            title: 'Local cache',
            body:
                'Hashes and groups are stored locally so reopening the app does not require a full rescan.',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.sync_rounded,
            title: 'Incremental updates',
            body:
                'Later scans only process new, modified, or deleted photos whenever possible.',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Private by design',
            body:
                'No cloud upload. Photo analysis runs on-device with native Android hashing.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
