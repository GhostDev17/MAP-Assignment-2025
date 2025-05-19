// Team Registration Model
class HockeyTeam {
  final int? id;
  final String teamName;
  final String coachName;
  final String contactEmail;
  final String contactPhone;
  final DateTime registrationDate;

  HockeyTeam({
    this.id,
    required this.teamName,
    required this.coachName,
    required this.contactEmail,
    required this.contactPhone,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'coachName': coachName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }
}