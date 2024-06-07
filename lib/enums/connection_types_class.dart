class ConnectionType {
  final int id;
  final String title;

  const ConnectionType._({
    required this.id,
    required this.title,
  });

  static const ConnectionType unknown =
      ConnectionType._(id: 0, title: "Unknown");
  static const ConnectionType avconConnector =
      ConnectionType._(id: 7, title: "Avcon Connector");
  static const ConnectionType blueCommando =
      ConnectionType._(id: 4, title: "Blue Commando (2P+E)");
  static const ConnectionType bs1363 =
      ConnectionType._(id: 3, title: "BS1363 3 Pin 13 Amp");
  static const ConnectionType ccsType1 =
      ConnectionType._(id: 32, title: "CCS (Type 1)");
  static const ConnectionType ccsType2 =
      ConnectionType._(id: 33, title: "CCS (Type 2)");
  static const ConnectionType cee3Pin =
      ConnectionType._(id: 16, title: "CEE 3 Pin");
  static const ConnectionType cee5Pin =
      ConnectionType._(id: 17, title: "CEE 5 Pin");
  static const ConnectionType cee7Schuko =
      ConnectionType._(id: 28, title: "CEE 7/4 - Schuko - Type F");
  static const ConnectionType cee7_5 =
      ConnectionType._(id: 23, title: "CEE 7/5");
  static const ConnectionType cee7Pin =
      ConnectionType._(id: 18, title: "CEE+ 7 Pin");
  static const ConnectionType chademo =
      ConnectionType._(id: 2, title: "CHAdeMO");
  static const ConnectionType europlug2Pin =
      ConnectionType._(id: 13, title: "Europlug 2-Pin (CEE 7/16)");
  static const ConnectionType gbTAcSocket =
      ConnectionType._(id: 1038, title: "GB-T AC - GB/T 20234.2 (Socket)");
  static const ConnectionType gbTAcTetheredCable = ConnectionType._(
      id: 1039, title: "GB-T AC - GB/T 20234.2 (Tethered Cable)");
  static const ConnectionType gbTDc =
      ConnectionType._(id: 1040, title: "GB-T DC - GB/T 20234.3");
  static const ConnectionType iec60309_3Pin =
      ConnectionType._(id: 34, title: "IEC 60309 3-pin");
  static const ConnectionType iec60309_5Pin =
      ConnectionType._(id: 35, title: "IEC 60309 5-pin");
  static const ConnectionType lpInductive =
      ConnectionType._(id: 5, title: "LP Inductive");
  static const ConnectionType nacsTeslaSupercharger =
      ConnectionType._(id: 27, title: "NACS / Tesla Supercharger");
  static const ConnectionType nema14_30 =
      ConnectionType._(id: 10, title: "NEMA 14-30");
  static const ConnectionType nema14_50 =
      ConnectionType._(id: 11, title: "NEMA 14-50");
  static const ConnectionType nema5_15R =
      ConnectionType._(id: 22, title: "NEMA 5-15R");
  static const ConnectionType nema5_20R =
      ConnectionType._(id: 9, title: "NEMA 5-20R");
  static const ConnectionType nema6_15 =
      ConnectionType._(id: 15, title: "NEMA 6-15");
  static const ConnectionType nema6_20 =
      ConnectionType._(id: 14, title: "NEMA 6-20");
  static const ConnectionType nemaTT_30R =
      ConnectionType._(id: 1042, title: "NEMA TT-30R");
  static const ConnectionType scameType3A =
      ConnectionType._(id: 36, title: "SCAME Type 3A(Low Power)");
  static const ConnectionType scameType3C =
      ConnectionType._(id: 26, title: "SCAME Type 3C(Schneider-Legrand)");
  static const ConnectionType spInductive =
      ConnectionType._(id: 6, title: "SP Inductive");
  static const ConnectionType t13Sec1011 = ConnectionType._(
      id: 1037, title: "T13 - SEC1011 ( Swiss domestic 3-pin ) - Type J");
  static const ConnectionType teslaModelS_X =
      ConnectionType._(id: 30, title: "Tesla (Model S/X)");
  static const ConnectionType teslaRoadster =
      ConnectionType._(id: 8, title: "Tesla (Roadster)");
  static const ConnectionType teslaBatterySwap =
      ConnectionType._(id: 31, title: "Tesla Battery Swap");
  static const ConnectionType threePhase5Pin =
      ConnectionType._(id: 1041, title: "Three Phase 5-Pin (AS/NZ 3123)");
  static const ConnectionType type1 =
      ConnectionType._(id: 1, title: "Type 1 (J1772)");
  static const ConnectionType type2SocketOnly =
      ConnectionType._(id: 25, title: "Type 2 (Socket only)");
  static const ConnectionType type2TetheredConnector =
      ConnectionType._(id: 1036, title: "Type 2 (Tethered Connector)");
  static const ConnectionType typeI =
      ConnectionType._(id: 29, title: "Type I (AS 3112)");
  static const ConnectionType typeM =
      ConnectionType._(id: 1043, title: "Type M");
  static const ConnectionType wirelessCharging =
      ConnectionType._(id: 24, title: "Wireless Charging");
  static const ConnectionType xlrPlug4Pin =
      ConnectionType._(id: 21, title: "XLR Plug (4 pin)");

  static const List<ConnectionType> values = [
    unknown,
    avconConnector,
    blueCommando,
    bs1363,
    ccsType1,
    ccsType2,
    cee3Pin,
    cee5Pin,
    cee7Schuko,
    cee7_5,
    cee7Pin,
    chademo,
    europlug2Pin,
    gbTAcSocket,
    gbTAcTetheredCable,
    gbTDc,
    iec60309_3Pin,
    iec60309_5Pin,
    lpInductive,
    nacsTeslaSupercharger,
    nema14_30,
    nema14_50,
    nema5_15R,
    nema5_20R,
    nema6_15,
    nema6_20,
    nemaTT_30R,
    scameType3A,
    scameType3C,
    spInductive,
    t13Sec1011,
    teslaModelS_X,
    teslaRoadster,
    teslaBatterySwap,
    threePhase5Pin,
    type1,
    type2SocketOnly,
    type2TetheredConnector,
    typeI,
    typeM,
    wirelessCharging,
    xlrPlug4Pin,
  ];

  static ConnectionType fromId(int id) {
    for (var type in values) {
      if (type.id == id) {
        return type;
      }
    }
    return unknown;
  }
}
