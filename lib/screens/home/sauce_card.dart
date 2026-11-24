import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../sauce_details.dart';

class SauceItemCard extends ConsumerWidget {
  final SauceWithTags sauce;

  const SauceItemCard({
    super.key,
    required this.sauce,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Handle optional description.
    final description = sauce.sauce.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    // Remove empty tags.
    final tags = sauce.tags.where((tag) => tag.trim().isNotEmpty).toList();

    // Show only the first two tags.
    final visibleTags = tags.take(2).toList();
    final remainingTags = tags.length - visibleTags.length;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SauceDetailsPage(sauce: sauce),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name
              Text(
                sauce.sauce.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 5),

              // Creation date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Created ${MaterialLocalizations.of(context).formatMediumDate(sauce.sauce.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Optional description
              if (hasDescription) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],

              // Optional tags
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tag in visibleTags) ...[
                        _TagChip(tag: tag),
                        const SizedBox(width: 6),
                      ],

                      // Remaining tags indicator
                      if (remainingTags > 0)
                        _TagChip(
                          tag: '+$remainingTags',
                          isCounter: true,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends ConsumerWidget {
  final String tag;
  final bool isCounter;

  const _TagChip({
    required this.tag,
    this.isCounter = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 140,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isCounter
            ? colors.surfaceContainerHighest
            : colors.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isCounter
              ? colors.onSurfaceVariant
              : colors.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
