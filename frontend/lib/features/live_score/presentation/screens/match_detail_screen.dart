import 'package:flutter/material.dart';

import '../../domain/models/match_model.dart';
import '../widgets/live_pulse_indicator.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(match.leagueName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: colors.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${match.country} · ${match.leagueName}',
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _TeamSummary(
                          name: match.homeTeam,
                          icon: match.sport == SportKind.football
                              ? Icons.sports_soccer_rounded
                              : Icons.sports_basketball_rounded,
                        ),
                      ),
                      Text(
                        match.status == MatchStatus.scheduled
                            ? _kickoff
                            : '${match.homeScore} - ${match.awayScore}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Expanded(
                        child: _TeamSummary(
                          name: match.awayTeam,
                          icon: match.sport == SportKind.football
                              ? Icons.sports_soccer_rounded
                              : Icons.sports_basketball_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (match.isLive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LivePulseIndicator(
                          color: Color(0xFF16A34A),
                          size: 8,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          match.status == MatchStatus.halftime
                              ? 'İlk yarı'
                              : 'Canlı · ${match.minute}′',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: const Color(0xFF16A34A)),
                        ),
                      ],
                    )
                  else
                    Text(
                      match.status == MatchStatus.finished
                          ? 'Maç sona erdi'
                          : 'Başlama saati: $_kickoff',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _DetailSection(
            title: 'İstatistikler',
            icon: Icons.analytics_outlined,
            child: Column(
              children: [
                _statRow(context, 'Topla oynama', '56%', '44%', 0.56),
                const SizedBox(height: 16),
                _statRow(context, 'Şutlar', '12', '8', 0.6),
                const SizedBox(height: 16),
                _statRow(context, 'Kornerler', '5', '3', 0.625),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Kadro',
            icon: Icons.groups_2_outlined,
            child: Text(
              '${match.homeTeam}: Kaleci, Savunma, Orta saha, Forvet\n'
              '${match.awayTeam}: Kaleci, Savunma, Orta saha, Forvet',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.7, color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Canlı anlatım',
            icon: Icons.subject_rounded,
            child: Column(
              children: [
                _CommentaryRow(
                  minute: '${match.minute}′',
                  text: 'Karşılaşma devam ediyor.',
                ),
                const Divider(height: 22),
                const _CommentaryRow(
                  minute: '42′',
                  text: 'Ev sahibi takım tehlikeli bir atak geliştirdi.',
                ),
                const Divider(height: 22),
                const _CommentaryRow(
                  minute: '18′',
                  text: 'Maçın ilk önemli pozisyonu yaşandı.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _kickoff {
    final hour = match.kickoff.hour.toString().padLeft(2, '0');
    final minute = match.kickoff.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _statRow(
    BuildContext context,
    String label,
    String home,
    String away,
    double homeRatio,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Text(home, style: const TextStyle(fontWeight: FontWeight.w700)),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            Text(away, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                flex: (homeRatio * 100).round(),
                child: Container(height: 6, color: colors.primary),
              ),
              Expanded(
                flex: ((1 - homeRatio) * 100).round(),
                child: Container(height: 6, color: colors.tertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CommentaryRow extends StatelessWidget {
  const _CommentaryRow({required this.minute, required this.text});

  final String minute;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          minute,
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
