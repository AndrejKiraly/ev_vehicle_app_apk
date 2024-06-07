class Source {
  final int id;
  final String title;

  const Source._(this.id, this.title);

  static const Source mobileApp = Source._(2, "Mobile App");
  static const Source webApp = Source._(1, "OpenChargeMaps");

  static const List<Source> values = [
    mobileApp,
    webApp,
  ];

  static Source fromId(int id) {
    for (var type in values) {
      if (type.id == id) {
        return type;
      }
    }
    return mobileApp;
  }
}
