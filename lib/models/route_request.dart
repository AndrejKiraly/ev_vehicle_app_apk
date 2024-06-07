class RouteRequest {
  final Origin? origin;
  final Destination? destination;
  final List<Destination>? intermediates;

  RouteRequest({
    this.origin,
    this.destination,
    this.intermediates,
  });

  Map<String, dynamic> toJson() {
    return {
      "origin": origin!.toJson(),
      "destination": destination!.toJson(),
      "intermediates": intermediates!.isEmpty
          ? null
          : intermediates!.map((e) => e.toJson()).toList(),
    };
  }
}

class Destination {
  final Loc? location;

  Destination({
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "location": location!.toJson(),
    };
  }
}

class Loc {
  final LatLong? latLng;

  Loc({
    this.latLng,
  });

  Map<String, dynamic> toJson() {
    return {
      "latLng": latLng!.toJson(),
    };
  }
}

class LatLong {
  final double? latitude;
  final double? longitude;

  LatLong({
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}

class Origin {
  final Loc? location;

  Origin({
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "location": location!.toJson(),
    };
  }
}
