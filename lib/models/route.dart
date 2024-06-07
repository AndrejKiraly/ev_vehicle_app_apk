class Route {
  int? id;
  int userId;
  String encodedRoute;
  final double approximatedDistance;
  final double approximatedDuration;
  final double actualDuration;
  final double actualDistance;

  Route({
    this.id,
    required this.userId,
    required this.encodedRoute,
    required this.approximatedDistance,
    required this.approximatedDuration,
    required this.actualDuration,
    required this.actualDistance,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      userId: json['userId'],
      encodedRoute: json['encodedRoute'],
      approximatedDistance: json['approximatedDistance'],
      approximatedDuration: json['approximatedDuration'],
      actualDuration: json['actualDuration'],
      actualDistance: json['actualDistance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'encodedRoute': encodedRoute,
      'approximatedDistance': approximatedDistance,
      'approximatedDuration': approximatedDuration,
      'actualDuration': actualDuration,
      'actualDistance': actualDistance,
    };
  }

  factory Route.emptyRoute() {
    return Route(
      userId: 0,
      encodedRoute: '',
      approximatedDistance: 0,
      approximatedDuration: 0,
      actualDuration: 0,
      actualDistance: 0,
    );
  }
}
