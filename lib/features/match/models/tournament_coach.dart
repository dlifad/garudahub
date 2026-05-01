class TournamentCoach {
  final int id;
  final int tournamentId;
  final String name;
  final String role;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const TournamentCoach({
    required this.id,
    required this.tournamentId,
    required this.name,
    required this.role,
    this.startDate,
    this.endDate,
    this.isActive = false,
  });

  factory TournamentCoach.fromJson(Map<String, dynamic> j) => TournamentCoach(
        id: (j['id'] as num?)?.toInt() ?? 0,
        tournamentId: (j['tournament_id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '-',
        role: j['role']?.toString() ?? 'head_coach',
        startDate: j['start_date'] != null
            ? DateTime.tryParse(j['start_date'].toString())
            : null,
        endDate: j['end_date'] != null
            ? DateTime.tryParse(j['end_date'].toString())
            : null,
        isActive: j['is_active'] == true || j['is_active'] == 1,
      );

  bool isActiveOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (startDate != null) {
      final sd = DateTime(startDate!.year, startDate!.month, startDate!.day);
      if (d.isBefore(sd)) return false;
    }
    if (endDate != null) {
      final ed = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (d.isAfter(ed)) return false;
    }
    return true;
  }
}
