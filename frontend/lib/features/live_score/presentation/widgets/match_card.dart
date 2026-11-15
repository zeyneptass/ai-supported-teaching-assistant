import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/match_model.dart';
import 'live_pulse_indicator.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.updates,
    required this.onTap,
  });

  final MatchModel match;
  final Stream<MatchModel> updates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MatchModel>(
      stream: updates,
      initialData: match,
      builder: (context, snapshot) {
        final current = snapshot.data ?? match;
        return _MatchCardBody(match: current, onTap: onTap);
      },
    );
  }
}

class _MatchCardBody extends StatelessWidget {
  const _MatchCardBody({required this.match, required this.onTap});

  final MatchModel match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showScore = match.status != MatchStatus.scheduled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              SizedBox(width: 58, child: _MatchStatus(match: match)),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 52,
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  children: [
                    _TeamRow(name: match.homeTeam),
                    const SizedBox(height: 10),
                    _TeamRow(name: match.awayTeam),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedScore(
                    key: ValueKey('${match.id}-home-score'),
                    score: showScore ? match.homeScore : null,
                  ),
                  const SizedBox(height: 10),
                  _AnimatedScore(
                    key: ValueKey('${match.id}-away-score'),
                    score: showScore ? match.awayScore : null,
                  ),
                ],
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchStatus extends StatelessWidget {
  const _MatchStatus({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (match.status == MatchStatus.live ||
        match.status == MatchStatus.halftime) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LivePulseIndicator(color: Color(0xFF16A34A), size: 8),
          const SizedBox(height: 5),
          Text(
            match.status == MatchStatus.halftime ? 'İY' : '${match.minute}′',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF16A34A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }
    if (match.status == MatchStatus.finished) {
      return Text(
        'MS',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final hour = match.kickoff.hour.toString().padLeft(2, '0');
    final minute = match.kickoff.minute.toString().padLeft(2, '0');
    return Text(
      '$hour:$minute',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.name});

  final String name;

  String get _initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part.characters.first).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          child: Text(
            _initials,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _AnimatedScore extends StatefulWidget {
  const _AnimatedScore({super.key, required this.score});

  final int? score;

  @override
  State<_AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<_AnimatedScore> {
  Timer? _highlightTimer;
  bool _highlighted = false;

  @override
  void didUpdateWidget(covariant _AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score && widget.score != null) {
      _highlightTimer?.cancel();
      setState(() => _highlighted = true);
      _highlightTimer = Timer(const Duration(milliseconds: 850), () {
        if (mounted) setState(() => _highlighted = false);
      });
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      constraints: const BoxConstraints(minWidth: 29, minHeight: 27),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _highlighted ? colors.tertiaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          widget.score?.toString() ?? '–',
          key: ValueKey(widget.score),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
        ),
      ),
    );
  }
}
