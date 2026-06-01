class Facility {
  final String id;
  final String name;
  final String type; // 'Puskesmas' or 'Rumah Sakit'
  final String address;
  final String phone;
  final String operatingHours;
  final double latitude;
  final double longitude;
  final int patientCount;
  final String status; // 'Aktif' or 'Perlu Review'
  final bool isUpdated;

  // Guest-specific fields with sensible defaults for dynamically added facilities
  final double distance;
  final bool hasTCM;
  final bool hasOAT;
  final String openStatus;
  final String closeTime;

  Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.operatingHours,
    required this.latitude,
    required this.longitude,
    required this.patientCount,
    required this.status,
    required this.isUpdated,
    this.distance = 1.5,
    this.hasTCM = true,
    this.hasOAT = true,
    this.openStatus = 'Buka',
    this.closeTime = '14:00',
  });

  // Helper copyWith method to allow clean immutable updates in state
  Facility copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? phone,
    String? operatingHours,
    double? latitude,
    double? longitude,
    int? patientCount,
    String? status,
    bool? isUpdated,
    double? distance,
    bool? hasTCM,
    bool? hasOAT,
    String? openStatus,
    String? closeTime,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      operatingHours: operatingHours ?? this.operatingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      patientCount: patientCount ?? this.patientCount,
      status: status ?? this.status,
      isUpdated: isUpdated ?? this.isUpdated,
      distance: distance ?? this.distance,
      hasTCM: hasTCM ?? this.hasTCM,
      hasOAT: hasOAT ?? this.hasOAT,
      openStatus: openStatus ?? this.openStatus,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}