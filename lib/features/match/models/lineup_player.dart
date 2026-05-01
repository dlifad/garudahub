class LineupPlayer {
  final int playerId;
  final String name;
  final String? nickname;
  final String? position;
  final int? jerseyNumber;
  final String? currentClub;
  final String? photoUrl;
  final bool isStartingEleven;
  final bool isCaptain;

  const LineupPlayer({
    required this.playerId,
    required this.name,
    this.nickname,
    this.position,
    this.jerseyNumber,
    this.currentClub,
    this.photoUrl,
    this.isStartingEleven = false,
    this.isCaptain = false,
  });

  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) return nickname!;
    final parts = name.split(' ');
    return parts.length > 1 ? parts.last : name;
  }

  factory LineupPlayer.fromJson(Map<String, dynamic> j) => LineupPlayer(
        playerId: (j['player_id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '-',
        nickname: j['nickname']?.toString(),
        position: (j['position']?.toString() ?? '').toUpperCase(),
        jerseyNumber: (j['jersey_number'] as num?)?.toInt(),
        currentClub: j['current_club']?.toString(),
        photoUrl: j['photo_url']?.toString(),
        isStartingEleven:
            j['is_starting_eleven'] == true || j['is_starting_eleven'] == 1,
        isCaptain: j['is_captain'] == true || j['is_captain'] == 1,
      );
}
