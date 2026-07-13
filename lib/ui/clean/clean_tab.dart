import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../app.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/models.dart';
import '../widgets/format_bytes.dart';
import '../widgets/photo_thumb.dart';

class CleanTab extends ConsumerStatefulWidget {
  const CleanTab({super.key});

  @override
  ConsumerState<CleanTab> createState() => _CleanTabState();
}

class _CleanTabState extends ConsumerState<CleanTab> {
  CleanCategory? _appliedCategory;
  int _appliedExactSignature = -1;
  int _appliedSimilarSignature = -1;
  int _appliedDarkSignature = -1;
  int _appliedBlurrySignature = -1;
  bool _userCleared = false;

  int _signatureForExact(List<ExactGroupView> groups) {
    return Object.hashAll([
      for (final g in groups) ...[
        g.group.id,
        g.photos.length,
        for (final p in g.photos) p.mediaId,
      ],
    ]);
  }

  int _signatureForSimilar(List<SimilarGroupView> groups) {
    return Object.hashAll([
      for (final g in groups) ...[
        g.group.id,
        g.photos.length,
        for (final p in g.photos) p.mediaId,
      ],
    ]);
  }

  int _signatureForPhotos(List<Photo> photos) {
    return Object.hashAll([for (final p in photos) p.mediaId]);
  }

  void _applyDefaultsIfNeeded({
    required CleanCategory category,
    required List<ExactGroupView> exactGroups,
    required List<SimilarGroupView> similarGroups,
    required List<Photo> darkPhotos,
    required List<Photo> blurryPhotos,
  }) {
    if (category == CleanCategory.duplicates) {
      final signature = _signatureForExact(exactGroups);
      final changed = _appliedCategory != category ||
          _appliedExactSignature != signature;
      if (!changed) return;
      _appliedCategory = category;
      _appliedExactSignature = signature;
      _userCleared = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _userCleared) return;
        ref.read(cleanSelectionProvider.notifier).applySmartDefaults([
          for (final g in exactGroups) g.photos,
        ]);
      });
      return;
    }

    if (category == CleanCategory.similar) {
      final signature = _signatureForSimilar(similarGroups);
      final changed = _appliedCategory != category ||
          _appliedSimilarSignature != signature;
      if (!changed) return;
      _appliedCategory = category;
      _appliedSimilarSignature = signature;
      _userCleared = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _userCleared) return;
        ref.read(cleanSelectionProvider.notifier).applySmartDefaults([
          for (final g in similarGroups) g.photos,
        ]);
      });
      return;
    }

    if (category == CleanCategory.dark) {
      final signature = _signatureForPhotos(darkPhotos);
      final changed =
          _appliedCategory != category || _appliedDarkSignature != signature;
      if (!changed) return;
      _appliedCategory = category;
      _appliedDarkSignature = signature;
      _userCleared = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _userCleared) return;
        ref.read(cleanSelectionProvider.notifier).selectAll([
          for (final p in darkPhotos) p.mediaId,
        ]);
      });
      return;
    }

    final signature = _signatureForPhotos(blurryPhotos);
    final changed =
        _appliedCategory != category || _appliedBlurrySignature != signature;
    if (!changed) return;
    _appliedCategory = category;
    _appliedBlurrySignature = signature;
    _userCleared = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userCleared) return;
      ref.read(cleanSelectionProvider.notifier).selectAll([
        for (final p in blurryPhotos) p.mediaId,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(cleanCategoryProvider);
    final selection = ref.watch(cleanSelectionProvider);
    final exactAsync = ref.watch(exactGroupsProvider);
    final similarAsync = ref.watch(similarGroupsProvider);
    final darkAsync = ref.watch(darkPhotosProvider);
    final blurryAsync = ref.watch(blurryPhotosProvider);
    final progress = ref.watch(scanProgressProvider);
    final scanning = progress.phase != ScanPhase.idle &&
        progress.phase != ScanPhase.done &&
        progress.phase != ScanPhase.error;

    final exactGroups = exactAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (g) => g,
      loading: () => const <ExactGroupView>[],
      error: (_, _) => const <ExactGroupView>[],
    );
    final similarGroups = similarAsync.when(
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

    _applyDefaultsIfNeeded(
      category: category,
      exactGroups: exactGroups,
      similarGroups: similarGroups,
      darkPhotos: darkPhotos,
      blurryPhotos: blurryPhotos,
    );

    final selectedBytes = _selectedBytes(
      selection,
      exactGroups,
      similarGroups,
      darkPhotos,
      blurryPhotos,
    );

    final activePhotos = switch (category) {
      CleanCategory.duplicates => [
          for (final g in exactGroups) ...g.photos,
        ],
      CleanCategory.similar => [
          for (final g in similarGroups) ...g.photos,
        ],
      CleanCategory.dark => darkPhotos,
      CleanCategory.blurry => blurryPhotos,
    };
    final totalInCategory = activePhotos.length;
    final selectedInCategory =
        activePhotos.where((p) => selection.contains(p.mediaId)).length;
    final keptInCategory = totalInCategory - selectedInCategory;
    final exactPhotoCount = exactGroups.fold<int>(
      0,
      (sum, g) => sum + g.photos.length,
    );
    final similarPhotoCount = similarGroups.fold<int>(
      0,
      (sum, g) => sum + g.photos.length,
    );

    return Stack(
      children: [
        ColoredBox(
          color: const Color(0xFFF3F0F7),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Clean',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                      ),
                      const Spacer(),
                      if (selection.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _userCleared = true;
                            ref
                                .read(cleanSelectionProvider.notifier)
                                .clear();
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
                if (selection.isNotEmpty || totalInCategory > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _SelectionSummary(
                      selected: selectedInCategory,
                      kept: keptInCategory,
                      total: totalInCategory,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CategorySwitcher(
                    category: category,
                    exactCount: exactPhotoCount,
                    similarCount: similarPhotoCount,
                    darkCount: darkPhotos.length,
                    blurryCount: blurryPhotos.length,
                    onChanged: (value) {
                      ref
                          .read(cleanCategoryProvider.notifier)
                          .setCategory(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: switch (category) {
                    CleanCategory.duplicates => _ExactList(
                        groups: exactGroups,
                        scanning: scanning,
                        loading: exactAsync.isLoading,
                      ),
                    CleanCategory.similar => _SimilarList(
                        groups: similarGroups,
                        scanning: scanning,
                        loading: similarAsync.isLoading,
                      ),
                    CleanCategory.dark => _QualityPhotoList(
                        photos: darkPhotos,
                        scanning: scanning,
                        loading: darkAsync.isLoading,
                        emptyTitle: 'No dark photos',
                        emptySubtitle:
                            'Underexposed shots will appear here after a scan.',
                        scanningSubtitle:
                            'Checking brightness while fingerprints run.',
                      ),
                    CleanCategory.blurry => _QualityPhotoList(
                        photos: blurryPhotos,
                        scanning: scanning,
                        loading: blurryAsync.isLoading,
                        emptyTitle: 'No blurry photos',
                        emptySubtitle:
                            'Out-of-focus shots will appear here after a scan.',
                        scanningSubtitle:
                            'Checking sharpness while fingerprints run.',
                      ),
                  },
                ),
              ],
            ),
          ),
        ),
        if (selection.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _DeleteBar(
              count: selection.length,
              bytes: selectedBytes,
              onDelete: () => _confirmDelete(context, ref, selection),
            ),
          ),
      ],
    );
  }

  int _selectedBytes(
    Set<String> selection,
    List<ExactGroupView> exact,
    List<SimilarGroupView> similar,
    List<Photo> dark,
    List<Photo> blurry,
  ) {
    final photos = <String, int>{};
    for (final g in exact) {
      for (final p in g.photos) {
        photos[p.mediaId] = p.sizeBytes;
      }
    }
    for (final g in similar) {
      for (final p in g.photos) {
        photos[p.mediaId] = p.sizeBytes;
      }
    }
    for (final p in dark) {
      photos[p.mediaId] = p.sizeBytes;
    }
    for (final p in blurry) {
      photos[p.mediaId] = p.sizeBytes;
    }
    var total = 0;
    for (final id in selection) {
      total += photos[id] ?? 0;
    }
    return total;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected photos?'),
        content: Text(
          'This will remove ${ids.length} photo${ids.length == 1 ? '' : 's'} '
          'from your device. This cannot be undone from Image Finder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await PhotoManager.editor.deleteWithIds(ids.toList());
      ref.read(cleanSelectionProvider.notifier).clear();
      _appliedCategory = null;
      await ref.read(scanProgressProvider.notifier).startScan();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${ids.length} photos')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.selected,
    required this.kept,
    required this.total,
  });

  final int selected;
  final int kept;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySoft.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'Selected',
              value: '$selected',
              color: const Color(0xFFE53935),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.primarySoft.withValues(alpha: 0.8),
          ),
          Expanded(
            child: _SummaryStat(
              label: 'Keep',
              value: '$kept',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.primarySoft.withValues(alpha: 0.8),
          ),
          Expanded(
            child: _SummaryStat(
              label: 'In groups',
              value: '$total',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({
    required this.category,
    required this.exactCount,
    required this.similarCount,
    required this.darkCount,
    required this.blurryCount,
    required this.onChanged,
  });

  final CleanCategory category;
  final int exactCount;
  final int similarCount;
  final int darkCount;
  final int blurryCount;
  final ValueChanged<CleanCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Chip(
                  label: 'Duplicates',
                  count: exactCount,
                  selected: category == CleanCategory.duplicates,
                  onTap: () => onChanged(CleanCategory.duplicates),
                ),
              ),
              Expanded(
                child: _Chip(
                  label: 'Similar',
                  count: similarCount,
                  selected: category == CleanCategory.similar,
                  onTap: () => onChanged(CleanCategory.similar),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Chip(
                  label: 'Dark',
                  count: darkCount,
                  selected: category == CleanCategory.dark,
                  onTap: () => onChanged(CleanCategory.dark),
                ),
              ),
              Expanded(
                child: _Chip(
                  label: 'Blurry',
                  count: blurryCount,
                  selected: category == CleanCategory.blurry,
                  onTap: () => onChanged(CleanCategory.blurry),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExactList extends ConsumerWidget {
  const _ExactList({
    required this.groups,
    required this.scanning,
    required this.loading,
  });

  final List<ExactGroupView> groups;
  final bool scanning;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (groups.isEmpty) {
      return _EmptyClean(
        title: scanning ? 'Scanning…' : 'No duplicates yet',
        subtitle: scanning
            ? 'Hang tight while we finish detecting exact matches.'
            : 'Run a scan from Home to find identical photos.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final g = groups[index];
        final sorted = [...g.photos]
          ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        final keepId = CleanSelectionNotifier.bestPhotoId(sorted);
        return _GroupCard(
          title: '${sorted.length} photos',
          sizeLabel: formatBytes(g.group.totalBytes),
          subtitle:
              '${sorted.length - 1} can be removed · best quality kept by default',
          photos: sorted,
          keepId: keepId,
        );
      },
    );
  }
}

class _SimilarList extends ConsumerWidget {
  const _SimilarList({
    required this.groups,
    required this.scanning,
    required this.loading,
  });

  final List<SimilarGroupView> groups;
  final bool scanning;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (groups.isEmpty) {
      return _EmptyClean(
        title: scanning ? 'Scanning…' : 'No similar photos yet',
        subtitle: scanning
            ? 'Perceptual matching is still running.'
            : 'Similar near-duplicates will show up here after a scan.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final g = groups[index];
        final sorted = [...g.photos]
          ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        final keepId = CleanSelectionNotifier.bestPhotoId(sorted);
        return _GroupCard(
          title: '${sorted.length} similar',
          sizeLabel: formatBytes(
            sorted.fold<int>(0, (sum, p) => sum + p.sizeBytes),
          ),
          subtitle:
              '${sorted.length - 1} selected to clean · best copy kept',
          photos: sorted,
          keepId: keepId,
        );
      },
    );
  }
}

class _QualityPhotoList extends ConsumerWidget {
  const _QualityPhotoList({
    required this.photos,
    required this.scanning,
    required this.loading,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.scanningSubtitle,
  });

  final List<Photo> photos;
  final bool scanning;
  final bool loading;
  final String emptyTitle;
  final String emptySubtitle;
  final String scanningSubtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading && photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (photos.isEmpty) {
      return _EmptyClean(
        title: scanning ? 'Scanning…' : emptyTitle,
        subtitle: scanning ? scanningSubtitle : emptySubtitle,
      );
    }

    final selection = ref.watch(cleanSelectionProvider);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final selected = selection.contains(photo.mediaId);
        return _SelectableThumb(
          photo: photo,
          selected: selected,
          isKeep: false,
          expand: true,
          onTap: () =>
              ref.read(cleanSelectionProvider.notifier).toggle(photo.mediaId),
        );
      },
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({
    required this.title,
    required this.sizeLabel,
    required this.subtitle,
    required this.photos,
    required this.keepId,
  });

  final String title;
  final String sizeLabel;
  final String subtitle;
  final List<Photo> photos;
  final String keepId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selection = ref.watch(cleanSelectionProvider);
    final visible = photos.take(4).toList();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ref
              .read(cleanSelectionProvider.notifier)
              .applySmartDefaultsForGroup(photos);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GroupDetailPage(
                title: title,
                photos: photos,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sizeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visible.length + (photos.length > 4 ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index >= visible.length) {
                      return Container(
                        width: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '+${photos.length - 4}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }
                    final photo = visible[index];
                    final selected = selection.contains(photo.mediaId);
                    final isKeep = photo.mediaId == keepId;
                    return _SelectableThumb(
                      photo: photo,
                      selected: selected,
                      isKeep: isKeep,
                      onTap: () => ref
                          .read(cleanSelectionProvider.notifier)
                          .toggle(photo.mediaId),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableThumb extends StatelessWidget {
  const _SelectableThumb({
    required this.photo,
    required this.selected,
    required this.isKeep,
    required this.onTap,
    this.expand = false,
  });

  final Photo photo;
  final bool selected;
  final bool isKeep;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        Positioned.fill(
          child: PhotoThumb(photo: photo, borderRadius: 14),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xFFE53935)
                  : Colors.white.withValues(alpha: 0.92),
              border: Border.all(
                color: selected
                    ? const Color(0xFFE53935)
                    : Colors.white,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        if (isKeep)
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Keep',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatBytes(photo.sizeBytes),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: expand
          ? body
          : SizedBox(width: 96, height: 96, child: body),
    );
  }
}

class _DeleteBar extends StatelessWidget {
  const _DeleteBar({
    required this.count,
    required this.bytes,
    required this.onDelete,
  });

  final int count;
  final int bytes;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$count selected (${formatBytes(bytes)})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyClean extends StatelessWidget {
  const _EmptyClean({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cleaning_services_rounded,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupDetailPage extends ConsumerStatefulWidget {
  const GroupDetailPage({
    super.key,
    required this.title,
    required this.photos,
  });

  final String title;
  final List<Photo> photos;

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(cleanSelectionProvider.notifier)
          .applySmartDefaultsForGroup(widget.photos);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(cleanSelectionProvider);
    final keepId = CleanSelectionNotifier.bestPhotoId(widget.photos);
    final removable = widget.photos.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} (${widget.photos.length})'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              removable > 0
                  ? '$removable selected to clean · best copy kept by default'
                  : 'Only one photo in this group',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return _SelectableThumb(
                  photo: photo,
                  selected: selection.contains(photo.mediaId),
                  isKeep: photo.mediaId == keepId,
                  onTap: () => ref
                      .read(cleanSelectionProvider.notifier)
                      .toggle(photo.mediaId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
