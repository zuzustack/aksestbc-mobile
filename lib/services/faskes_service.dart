import '../models/facility.dart';

class FaskesService {
  static final FaskesService _instance = FaskesService._internal();
  factory FaskesService() => _instance;
  FaskesService._internal();

  // In-memory list of facilities, pre-populated with standard Surabaya locations
  final List<Facility> _facilities = [
    Facility(
      id: '1',
      name: 'RSUD Dr. Soetomo',
      type: 'Rumah Sakit',
      address: 'Jl. Mayjen Prof. Dr. Moestopo No.6-8, Airlangga, Kec. Gubeng',
      phone: '031-5501078',
      operatingHours: '24 Jam',
      latitude: -7.2675,
      longitude: 112.7578,
      patientCount: 450,
      status: 'Aktif',
      isUpdated: true,
      distance: 3.5,
      hasTCM: true,
      hasOAT: true,
      openStatus: 'Buka 24 Jam',
      closeTime: '-',
    ),
    Facility(
      id: '2',
      name: 'Puskesmas Ketabang',
      type: 'Puskesmas',
      address: 'Jl. Jaksa Agung Suprapto No.2, Ketabang, Kec. Genteng',
      phone: '031-5345759',
      operatingHours: 'Senin - Sabtu, 07:30 - 14:00',
      latitude: -7.2588,
      longitude: 112.7461,
      patientCount: 120,
      status: 'Aktif',
      isUpdated: true,
      distance: 1.8,
      hasTCM: true,
      hasOAT: true,
      openStatus: 'Buka',
      closeTime: '14:00',
    ),
    Facility(
      id: '3',
      name: 'Puskesmas Pucang Sewu',
      type: 'Puskesmas',
      address: 'Jl. Pucang Anom Timur No.2, Pucang Sewu, Kec. Gubeng',
      phone: '031-5018265',
      operatingHours: 'Senin - Sabtu, 07:30 - 14:00',
      latitude: -7.2721,
      longitude: 112.7601,
      patientCount: 85,
      status: 'Perlu Review',
      isUpdated: false,
      distance: 2.4,
      hasTCM: false,
      hasOAT: true,
      openStatus: 'Buka',
      closeTime: '14:00',
    ),
    Facility(
      id: '4',
      name: 'Puskesmas Mulyorejo',
      type: 'Puskesmas',
      address: 'Jl. Mulyorejo Utara No. 201, Mulyorejo, Surabaya',
      phone: '031-3814321',
      operatingHours: 'Senin - Sabtu, 07:30 - 14:00',
      latitude: -7.2625,
      longitude: 112.7845,
      patientCount: 105,
      status: 'Aktif',
      isUpdated: true,
      distance: 1.2,
      hasTCM: true,
      hasOAT: true,
      openStatus: 'Buka',
      closeTime: '14:00',
    ),
  ];

  // Retrieve all facilities
  List<Facility> getFacilities() {
    return List.unmodifiable(_facilities);
  }

  // Create/Add a facility
  void addFacility(Facility facility) {
    _facilities.add(facility);
  }

  // Update a facility
  void updateFacility(Facility updatedFacility) {
    final index = _facilities.indexWhere((f) => f.id == updatedFacility.id);
    if (index != -1) {
      _facilities[index] = updatedFacility;
    }
  }

  // Delete/Remove a facility
  void deleteFacility(String id) {
    _facilities.removeWhere((f) => f.id == id);
  }
}
