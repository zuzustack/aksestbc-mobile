class Facility {
  final String name;
  final String address;
  final double distance; // dalam km
  final bool hasTCM; // Tes Cepat Molekuler
  final bool hasOAT; // Obat Anti Tuberkulosis
  final String openStatus;
  final String closeTime;

  Facility({
    required this.name,
    required this.address,
    required this.distance,
    required this.hasTCM,
    required this.hasOAT,
    required this.openStatus,
    required this.closeTime,
  });
}