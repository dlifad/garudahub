class TournamentModel {
  final int id;
  final String name;
  final int year;
  final String? logoUrl;
  final String? confederation;
  final String? type;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.year,
    this.logoUrl,
    this.confederation,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> j) {
    int parseInt(dynamic v, int fallback) =>
        v == null ? fallback : int.tryParse('$v') ?? fallback;

    // year: bisa dari field 'year', atau parse dari start_date
    int year = parseInt(j['year'], 0);
    if (year == 0 && j['start_date'] != null) {
      year =
          DateTime.tryParse(j['start_date'].toString())?.year ??
          DateTime.now().year;
    }
    if (year == 0) year = DateTime.now().year;

    return TournamentModel(
      id: parseInt(j['id'], 0),
      name: j['name']?.toString() ?? '-',
      year: year,
      logoUrl: j['logo_url']?.toString() ?? j['logo']?.toString(),
      confederation: j['confederation']?.toString(),
      type: j['type']?.toString(),
      status: j['status']?.toString(),
      startDate: j['start_date'] != null
          ? DateTime.tryParse(j['start_date'].toString())
          : null,
      endDate: j['end_date'] != null
          ? DateTime.tryParse(j['end_date'].toString())
          : null,
    );
  }
}
