enum MatchStatus { scheduled, live, halftime, finished }

enum SportKind { football, basketball }

class MatchModel {
  const MatchModel({
    required this.id,
    required this.leagueId,
    required this.leagueName,
    required this.country,
    required this.sport,
    required this.homeTeam,
    required this.awayTeam,
    required this.kickoff,
    required this.status,
    this.homeScore = 0,
    this.awayScore = 0,
    this.minute = 0,
  });

  final String id;
  final String leagueId;
  final String leagueName;
  final String country;
  final SportKind sport;
  final String homeTeam;
  final String awayTeam;
  final DateTime kickoff;
  final MatchStatus status;
  final int homeScore;
  final int awayScore;
  final int minute;

  bool get isLive =>
      status == MatchStatus.live || status == MatchStatus.halftime;

  MatchModel copyWith({
    MatchStatus? status,
    int? homeScore,
    int? awayScore,
    int? minute,
  }) {
    return MatchModel(
      id: id,
      leagueId: leagueId,
      leagueName: leagueName,
      country: country,
      sport: sport,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      kickoff: kickoff,
      status: status ?? this.status,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      minute: minute ?? this.minute,
    );
  }
}
