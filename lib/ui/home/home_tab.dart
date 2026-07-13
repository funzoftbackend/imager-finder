import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../app.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/models.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(scanProgressProvider);
    final meta = ref.watch(scanMetaProvider);
    final exact = ref.watch(exactGroupsProvider);
    final similar = ref.watch(similarGroupsProvider);
    final darkAsync = ref.watch(darkPhotosProvider);
    final blurryAsync = ref.watch(blurryPhotosProvider);
    final scanning = progress.phase != ScanPhase.idle &&
        progress.phase != ScanPhase.done &&
        progress.phase != ScanPhase.error;

    // Keep last known data while providers reload (avoids 0↔959 flicker).
    final exactGroups = exact.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (g) => g,
      loading: () => const <ExactGroupView>[],
      error: (_, _) => const <ExactGroupView>[],
    );
    final similarGroups = similar.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (g) => g,
      loading: () => const <SimilarGroupView>[],
      error: (_, _) => const <SimilarGroupView>[],
    );
    final darkPhotos = darkAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (g) => g,
      loading: () => const <Photo>[],
      error: (_, _) => const <Photo>[],
    );
    final blurryPhotos = blurryAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (g) => g,
      loading: () => const <Photo>[],
      error: (_, _) => const <Photo>[],
    );
    final photoCount = meta.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (m) => m?.photoCount ?? 0,
      loading: () => 0,
      error: (_, _) => 0,
    );
    final hasScanned = meta.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (m) => m?.lastScanAtMs != null,
      loading: () => false,
      error: (_, _) => false,
    );

    final exactGroupCount = exactGroups.isNotEmpty
        ? exactGroups.length
        : progress.exactGroups;
    final similarGroupCount = similarGroups.isNotEmpty
        ? similarGroups.length
        : progress.similarGroups;
    final exactPhotoCount = exactGroups.fold<int>(
      0,
      (sum, g) => sum + g.photos.length,
    );
    final similarPhotoCount = similarGroups.fold<int>(
      0,
      (sum, g) => sum + g.photos.length,
    );
    final darkCount = darkPhotos.isNotEmpty
        ? darkPhotos.length
        : meta.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            data: (m) => m?.darkCount ?? progress.darkCount,
            loading: () => progress.darkCount,
            error: (_, _) => progress.darkCount,
          );
    final blurryCount = blurryPhotos.isNotEmpty
        ? blurryPhotos.length
        : meta.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            data: (m) => m?.blurryCount ?? progress.blurryCount,
            loading: () => progress.blurryCount,
            error: (_, _) => progress.blurryCount,
          );

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Image Finder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const Spacer(),
                  if (hasScanned && !scanning)
                    IconButton.filledTonal(
                      tooltip: 'Rescan',
                      onPressed: () =>
                          ref.read(scanProgressProvider.notifier).startScan(),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _HeroScanCard(
                progress: progress,
                photoCount: photoCount,
                exactCount: exactGroupCount,
                similarCount: similarGroupCount,
                scanning: scanning,
                hasScanned: hasScanned,
                onScan: () =>
                    ref.read(scanProgressProvider.notifier).startScan(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Duplicates',
                          count: exactPhotoCount,
                          subtitle: exactGroupCount == 0
                              ? 'Exact matches'
                              : '$exactGroupCount groups',
                          icon: Icons.copy_all_rounded,
                          accent: const Color(0xFF7E57C2),
                          onTap: () {
                            ref
                                .read(cleanCategoryProvider.notifier)
                                .setCategory(CleanCategory.duplicates);
                            ref.read(navIndexProvider.notifier).setIndex(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          title: 'Similar',
                          count: similarPhotoCount,
                          subtitle: similarGroupCount == 0
                              ? 'Near matches'
                              : '$similarGroupCount groups',
                          icon: Icons.auto_awesome_rounded,
                          accent: const Color(0xFF9575CD),
                          onTap: () {
                            ref
                                .read(cleanCategoryProvider.notifier)
                                .setCategory(CleanCategory.similar);
                            ref.read(navIndexProvider.notifier).setIndex(1);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Dark',
                          count: darkCount,
                          subtitle: 'Too dim',
                          icon: Icons.dark_mode_rounded,
                          accent: const Color(0xFF5C6BC0),
                          onTap: () {
                            ref
                                .read(cleanCategoryProvider.notifier)
                                .setCategory(CleanCategory.dark);
                            ref.read(navIndexProvider.notifier).setIndex(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          title: 'Blurry',
                          count: blurryCount,
                          subtitle: 'Out of focus',
                          icon: Icons.blur_on_rounded,
                          accent: const Color(0xFF7986CB),
                          onTap: () {
                            ref
                                .read(cleanCategoryProvider.notifier)
                                .setCategory(CleanCategory.blurry);
                            ref.read(navIndexProvider.notifier).setIndex(1);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (progress.phase == ScanPhase.error && progress.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _ErrorCard(message: progress.error!),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard({
    required this.progress,
    required this.photoCount,
    required this.exactCount,
    required this.similarCount,
    required this.scanning,
    required this.hasScanned,
    required this.onScan,
  });

  final ScanProgress progress;
  final int photoCount;
  final int exactCount;
  final int similarCount;
  final bool scanning;
  final bool hasScanned;
  final VoidCallback onScan;

  static String _heroHeadline(ScanPhase phase) => switch (phase) {
        ScanPhase.catalog => 'Reading gallery…',
        ScanPhase.diff => 'Comparing library…',
        ScanPhase.exact => 'Finding duplicates…',
        ScanPhase.similar => 'Finding similar…',
        ScanPhase.grouping => 'Matching similar…',
        ScanPhase.persist => 'Saving results…',
        ScanPhase.permission => 'Need permission…',
        _ => 'Finding duplicates…',
      };

  static String _statusLine(ScanProgress progress) {
    final parts = <String>[progress.phase.label];
    if (progress.phase.indeterminateProgress) {
      parts.add('please wait');
    } else {
      if (progress.total > 0) {
        parts.add('${progress.processed}/${progress.total}');
      }
      if (progress.photosPerSecond > 0) {
        parts.add('${progress.photosPerSecond.toStringAsFixed(0)}/s');
      }
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const buttonOverlap = 28.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: buttonOverlap),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9B7BD4),
                Color(0xFF7B5BB5),
                Color(0xFF6A4BA8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scanning ? 'Scanning gallery' : 'Photo library',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                scanning
                    ? _heroHeadline(progress.phase)
                    : hasScanned
                        ? 'Ready to clean'
                        : 'Scan your gallery',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                scanning
                    ? (progress.message.isEmpty
                        ? 'Working through your photos'
                        : progress.message)
                    : hasScanned
                        ? '$photoCount photos indexed on this device'
                        : 'Detect duplicates, similar, dark, and blurry photos locally — fast and private.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
              ),
              if (scanning) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.phase.indeterminateProgress
                        ? null
                        : (progress.fraction > 0 ? progress.fraction : null),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusLine(progress),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ] else if (hasScanned) ...[
                const SizedBox(height: 18),
                  Row(
                  children: [
                    _HeroMetric(
                      label: 'Photos',
                      value: '$photoCount',
                    ),
                    const SizedBox(width: 18),
                    _HeroMetric(
                      label: 'Exact',
                      value: '$exactCount',
                    ),
                    const SizedBox(width: 18),
                    _HeroMetric(
                      label: 'Similar',
                      value: '$similarCount',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: _ScanActionButton(
            scanning: scanning,
            hasScanned: hasScanned,
            onPressed: scanning ? null : onScan,
          ),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
        ),
      ],
    );
  }
}

class _ScanActionButton extends StatelessWidget {
  const _ScanActionButton({
    required this.scanning,
    required this.hasScanned,
    required this.onPressed,
  });

  final bool scanning;
  final bool hasScanned;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 10,
      shadowColor: AppColors.primary.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scanning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              else
                Icon(
                  hasScanned ? Icons.refresh_rounded : Icons.search_rounded,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(width: 10),
              Text(
                scanning
                    ? 'Scanning…'
                    : hasScanned
                        ? 'Rescan library'
                        : 'Scan now',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primarySoft.withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Something went wrong',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: theme.textTheme.bodySmall),
          TextButton(
            onPressed: () => PhotoManager.openSetting(),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }
}
