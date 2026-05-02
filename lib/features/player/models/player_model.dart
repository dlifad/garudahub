class PlayerModel {
  final int id;
  final String name;
  final String? nickname;
  final String position;
  final String? dateOfBirth;
  final bool isNaturalized;
  final String? currentClub;
  final String? clubCountry;
  final int caps;
  final int goals;
  final String? photoUrl;
  final bool isActive;
  final String? status;

  const PlayerModel({
    required this.id,
    required this.name,
    this.nickname,
    required this.position,
    this.dateOfBirth,
    required this.isNaturalized,
    this.currentClub,
    this.clubCountry,
    required this.caps,
    required this.goals,
    this.photoUrl,
    required this.isActive,
    this.status,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> j) => PlayerModel(
        id: (j['id'] as num).toInt(),
        name: j['name']?.toString() ?? '-',
        nickname: j['nickname']?.toString(),
        position: j['position']?.toString() ?? 'GK',
        dateOfBirth: j['date_of_birth']?.toString(),
        isNaturalized: j['is_naturalized'] == true || j['is_naturalized'] == 1,
        currentClub: j['current_club']?.toString(),
        clubCountry: j['club_country']?.toString(),
        caps: (j['caps'] as num?)?.toInt() ?? 0,
        goals: (j['goals'] as num?)?.toInt() ?? 0,
        photoUrl: j['photo_url']?.toString(),
        isActive: j['is_active'] == true || j['is_active'] == 1,
        status: j['status']?.toString(),
      );

  /// Nama tampil: nickname jika ada, fallback ke nama asli
  String get displayName =>
      (nickname?.isNotEmpty == true) ? nickname! : name;

  String get positionLabel {
    const map = {
      'GK': 'Penjaga Gawang',
      'DEF': 'Bertahan',
      'MID': 'Tengah',
      'FWD': 'Penyerang',
    };
    return map[position] ?? position;
  }
}

class SquadResponse {
  final String tournamentName;
  final String? headCoach;
  final int totalPlayers;
  final Map<String, List<PlayerModel>> squad; // GK, DEF, MID, FWD

  const SquadResponse({
    required this.tournamentName,
    this.headCoach,
    required this.totalPlayers,
    required this.squad,
  });

  factory SquadResponse.fromJson(Map<String, dynamic> j) {
    final rawSquad = j['squad'] as Map<String, dynamic>? ?? {};
    return SquadResponse(
      tournamentName: j['tournament']?.toString() ?? '',
      headCoach: j['head_coach']?.toString(),
      totalPlayers: (j['total_players'] as num?)?.toInt() ?? 0,
      squad: rawSquad.map(
        (key, value) => MapEntry(
          key,
          (value as List)
              .whereType<Map<String, dynamic>>()
              .map(PlayerModel.fromJson)
              .toList(),
        ),
      ),
    );
  }

  List<PlayerModel> get allPlayers =>
      ['GK', 'DEF', 'MID', 'FWD']
          .expand((p) => squad[p] ?? <PlayerModel>[])
          .toList();
}
