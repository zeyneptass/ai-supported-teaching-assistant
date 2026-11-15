import 'package:flutter/material.dart';

import '../../domain/models/match_model.dart';

class LeagueHeader extends StatelessWidget {
  const LeagueHeader({
    super.key,
    required this.name,
    required this.country,
    required this.sport,
    required this.expanded,
    required this.matchCount,
    required this.onTap,
  });

  final String name;
  final String country;
  final SportKind sport;
  final bool expanded;
  final int matchCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = sport == SportKind.football
        ? Icons.sports_soccer_rounded
        : Icons.sports_basketball_rounded;
    return Material(
      color: colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: Icon(icon, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$country · $matchCount maç',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
