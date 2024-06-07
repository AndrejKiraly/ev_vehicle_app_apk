class CurrentType {
  final int id;
  final String title;
  final String description;

  const CurrentType._(this.id, this.title, this.description);

  static const CurrentType acSinglePhase = CurrentType._(
      10, "AC (Single-Phase)", "Alternating Current - Single Phase");

  static const CurrentType acThreePhase = CurrentType._(
      20, "AC (Three-Phase)", "Alternating Current - Three Phase");

  static const CurrentType dc = CurrentType._(30, "DC", "Direct Current");

  static const List<CurrentType> values = [
    acSinglePhase,
    acThreePhase,
    dc,
  ];

  static CurrentType fromId(int id) {
    for (var type in values) {
      if (type.id == id) {
        return type;
      }
    }
    return acSinglePhase;
  }
}
