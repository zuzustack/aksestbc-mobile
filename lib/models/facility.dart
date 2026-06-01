class FaskesModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String operatingHours;
  final double latitude;
  final double longitude;
  final int patientCount;
  final String status;
  final bool isUpdated;
  final double distance;
  final bool hasTCM;
  final bool hasOAT;
  final String openStatus;
  final String closeTime;

  FaskesModel({
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
    required this.distance,
    required this.hasTCM,
    required this.hasOAT,
    required this.openStatus,
    required this.closeTime,
  });

  // Mengubah data dari Firestore (Map) menjadi Objek Dart
  factory FaskesModel.fromMap(String docId, Map<String, dynamic> map) {
    return FaskesModel(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      operatingHours: map['operatingHours'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      patientCount: map['patientCount'] ?? 0,
      status: map['status'] ?? '',
      isUpdated: map['isUpdated'] ?? false,
      distance: (map['distance'] as num).toDouble(),
      hasTCM: map['hasTCM'] ?? false,
      hasOAT: map['hasOAT'] ?? false,
      openStatus: map['openStatus'] ?? '',
      closeTime: map['closeTime'] ?? '',
    );
  }

  // Mengubah Objek Dart menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'address': address,
      'phone': phone,
      'operatingHours': operatingHours,
      'latitude': latitude,
      'longitude': longitude,
      'patientCount': patientCount,
      'status': status,
      'isUpdated': isUpdated,
      'distance': distance,
      'hasTCM': hasTCM,
      'hasOAT': hasOAT,
      'openStatus': openStatus,
      'closeTime': closeTime,
    };
  }
}