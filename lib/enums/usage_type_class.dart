class UsageType {
  final int id;
  final String title;

  const UsageType._(this.id, this.title);

  static const UsageType unknown = UsageType._(0, "Unknown");

  static const UsageType privateForStaffVisitors =
      UsageType._(6, "Private - For Staff, Visitors or Customers");

  static const UsageType privateRestrictedAccess =
      UsageType._(2, "Private - Restricted Access");

  static const UsageType privatelyOwned =
      UsageType._(3, "Priavately Owned - Notice Required");

  static const UsageType public = UsageType._(1, "Public");

  static const UsageType publicMembershipRequired =
      UsageType._(4, "Public - Membership Required");

  static const UsageType publicNoticeRequired =
      UsageType._(7, "Public - Notice Required");

  static const UsageType publicPayAtLocation =
      UsageType._(5, "Public - Pay at Location");

  static const List<UsageType> values = [
    public,
    privateForStaffVisitors,
    privateRestrictedAccess,
    privatelyOwned,
    publicMembershipRequired,
    publicPayAtLocation,
    publicNoticeRequired,
    unknown
  ];

  static UsageType fromId(int id) {
    for (var type in values) {
      if (type.id == id) {
        return type;
      }
    }
    return unknown;
  }
}
