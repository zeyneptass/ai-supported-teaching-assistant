import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/match_model.dart';
import '../viewmodels/live_score_view_model.dart';
import '../widgets/league_header.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  final _searchController = TextEditingController();
  late final LiveScoreViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<LiveScoreViewModel>()..start();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.stop();
    super.dispose();
  }

  void _toggleSearch(LiveScoreViewModel viewModel) {
    viewModel.toggleSearch();
    if (!viewModel.searchOpen) _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LiveScoreViewModel>();
    final sections = viewModel.groupedMatches;
    final entries = <_ScoreEntry>[];
    for (final section in sections) {
      entries.add(_LeagueEntry(section));
      if (viewModel.isLeagueExpanded(section.id)) {
        entries.addAll(section.matches.map(_MatchEntry.new));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Canlı Sonuçlar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (viewModel.liveMatchCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${viewModel.liveMatchCount} CANLI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            tooltip: viewModel.searchOpen
                ? 'Aramayı kapat'
                : 'Takım veya lig ara',
            onPressed: () => _toggleSearch(viewModel),
            icon: Icon(
              viewModel.searchOpen ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (viewModel.searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: viewModel.setQuery,
                decoration: InputDecoration(
                  hintText: 'Takım veya lig ara',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: viewModel.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Aramayı temizle',
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.clear_rounded),
                        ),
                ),
              ),
            ),
          _DateAndLiveFilters(viewModel: viewModel),
          const SizedBox(height: 4),
          Expanded(
            child: entries.isEmpty
                ? _EmptyState(liveOnly: viewModel.liveOnly)
                : ListView.builder(
                    key: const PageStorageKey<String>('live-score-list'),
                    itemCount: entries.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      if (entry is _LeagueEntry) {
                        final section = entry.section;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LeagueHeader(
                            name: section.name,
                            country: section.country,
                            sport: section.sport,
                            matchCount: section.matches.length,
                            expanded: viewModel.isLeagueExpanded(section.id),
                            onTap: () => viewModel.toggleLeague(section.id),
                          ),
                        );
                      }

                      final match = (entry as _MatchEntry).match;
                      final latest = viewModel.matchById(match.id) ?? match;
                      return MatchCard(
                        key: ValueKey(match.id),
                        match: latest,
                        updates: viewModel.watchMatch(match.id),
                        onTap: () {
                          final current =
                              viewModel.matchById(match.id) ?? latest;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MatchDetailScreen(match: current),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateAndLiveFilters extends StatelessWidget {
  const _DateAndLiveFilters({required this.viewModel});

  final LiveScoreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final dates = List<DateTime>.generate(
      5,
      (index) => DateTime.now().add(Duration(days: index - 1)),
    );
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final date in dates)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(_dateLabel(date)),
                selected: _sameDay(viewModel.selectedDate, date),
                onSelected: (_) => viewModel.selectDate(date),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: Icon(
                Icons.circle,
                size: 9,
                color: viewModel.liveOnly
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: const Text('Sadece canlı'),
              selected: viewModel.liveOnly,
              onSelected: viewModel.setLiveOnly,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    final difference = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day));
    if (difference.inDays == -1) return 'Dün';
    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Yarın';
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.liveOnly});

  final bool liveOnly;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              liveOnly ? Icons.sensors_off_rounded : Icons.event_busy_rounded,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              liveOnly ? 'Şu anda canlı maç yok' : 'Bu tarihte maç bulunamadı',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              liveOnly
                  ? 'Diğer karşılaşmaları görmek için canlı filtresini kapatın.'
                  : 'Başka bir tarih seçebilir veya takım arayabilirsiniz.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

sealed class _ScoreEntry {
  const _ScoreEntry();
}

class _LeagueEntry extends _ScoreEntry {
  const _LeagueEntry(this.section);

  final LeagueSection section;
}

class _MatchEntry extends _ScoreEntry {
  const _MatchEntry(this.match);

  final MatchModel match;
}
