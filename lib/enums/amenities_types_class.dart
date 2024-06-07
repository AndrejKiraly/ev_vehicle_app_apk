class Amenity {
  final int id;
  final String title;

  const Amenity._({
    required this.id,
    required this.title,
  });

  static const Amenity toilets = Amenity._(id: 1, title: "Toilets");
  static const Amenity shoppingMall = Amenity._(id: 2, title: "Shopping Mall");
  static const Amenity restaurant = Amenity._(id: 3, title: "Restaurant");
  static const Amenity hotel = Amenity._(id: 4, title: "Hotel");
  static const Amenity parkingLot = Amenity._(id: 5, title: "Parking Lot");
  static const Amenity atm = Amenity._(id: 6, title: "ATM");
  static const Amenity wifi = Amenity._(id: 7, title: "Wi-Fi");
  static const Amenity park = Amenity._(id: 8, title: "Park");
  static const Amenity supermarket = Amenity._(id: 9, title: "Supermarket");

  static const List<Amenity> amenityValues = [
    toilets,
    shoppingMall,
    restaurant,
    hotel,
    parkingLot,
    atm,
    wifi,
    park,
    supermarket,
  ];

  static Amenity fromId(int id) {
    return amenityValues.firstWhere(
      (element) => element.id == id,
      orElse: () => Amenity.toilets,
    );
  }
}
