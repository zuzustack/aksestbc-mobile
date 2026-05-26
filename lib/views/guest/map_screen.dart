import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps

// --- 1. UPDATE MODEL DATA ---
// Menambahkan koordinat (lat, lng) untuk menaruh pin di peta
class Facility {
  final String name;
  final String address;
  final double distance;
  final bool hasTCM;
  final bool hasOAT;
  final String openStatus;
  final String closeTime;
  final double lat; // Garis Lintang
  final double lng; // Garis Bujur

  Facility({
    required this.name,
    required this.address,
    required this.distance,
    required this.hasTCM,
    required this.hasOAT,
    required this.openStatus,
    required this.closeTime,
    required this.lat,
    required this.lng,
  });
}

// --- 2. UPDATE DATA DUMMY DENGAN KOORDINAT SURABAYA ---
final List<Facility> dummyFacilities = [
  Facility(
    name: 'Puskesmas Mulyorejo',
    address: 'Jl. Mulyorejo Utara No. 201, Mulyorejo, Surabaya',
    distance: 1.2,
    hasTCM: true,
    hasOAT: true,
    openStatus: 'Buka',
    closeTime: '14:00',
    lat: -7.2625, // Koordinat perkiraan Mulyorejo
    lng: 112.7845,
  ),
  Facility(
    name: 'RSUD Dr. Soetomo',
    address: 'Jl. Mayjen Prof. Dr. Moestopo No.6-8, Airlangga, Surabaya',
    distance: 3.5,
    hasTCM: true,
    hasOAT: true,
    openStatus: 'Buka 24 Jam',
    closeTime: '-',
    lat: -7.2675, // Koordinat RSUD Dr. Soetomo
    lng: 112.7578,
  ),
];

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller untuk mengendalikan peta (seperti menggeser kamera)
  GoogleMapController? _mapController;

  // Titik tengah awal peta saat dibuka (Area Surabaya Timur)
  final LatLng _initialCenter = const LatLng(-7.2650, 112.7700);

  // Fungsi untuk mengubah data Faskes menjadi Pin/Marker di peta
  Set<Marker> _createMarkers() {
    return dummyFacilities.map((faskes) {
      return Marker(
        markerId: MarkerId(faskes.name),
        position: LatLng(faskes.lat, faskes.lng),
        infoWindow: InfoWindow(
          title: faskes.name,
          snippet: faskes.hasTCM ? 'Tes TCM Tersedia' : 'Layanan TBC Dasar',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Warna pin tosca
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AksesTBC',
          style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // --- LAYER 1: GOOGLE MAPS ASLI ---
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 13.5, // Tingkat perbesaran awal
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _createMarkers(), // Memasukkan marker yang kita buat di atas
              zoomControlsEnabled: false, // Menyembunyikan tombol + dan - bawaan agar UI lebih bersih
              mapToolbarEnabled: false,
            ),
          ),

          // --- LAYER 2: Tombol 'My Location' ---
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                // Logika sementara: Kembalikan kamera ke titik tengah Surabaya Timur
                // Nanti kita bisa gunakan package 'geolocator' untuk lokasi GPS asli pengguna
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _initialCenter, zoom: 13.5),
                  ),
                );
              },
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // --- LAYER 3: Panel Faskes Terdekat (Draggable Sheet) ---
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Faskes Terdekat',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Surabaya Timur & Sekitarnya',
                              style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, color: Color(0xFF007B7A), size: 18),
                          label: const Text('Filter', style: TextStyle(color: Color(0xFF007B7A))),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mapping UI Card sama seperti sebelumnya
                    ...dummyFacilities.map((faskes) => _buildFacilityCard(faskes)).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Kartu Faskes (Sama dengan sebelumnya) ---
  Widget _buildFacilityCard(Facility faskes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  faskes.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route, size: 14, color: Color(0xFF007B7A)),
                    const SizedBox(width: 4),
                    Text('${faskes.distance} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007B7A))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  faskes.address,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (faskes.hasTCM)
                _buildBadge(Icons.check_circle, 'Tes TCM Tersedia', const Color(0xFFE6F4EA), const Color(0xFF137333)),
              const SizedBox(width: 8),
              if (faskes.hasOAT)
                _buildBadge(Icons.medical_services, 'OAT Gratis', const Color(0xFFE8F0FE), const Color(0xFF1A73E8)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jam Operasional', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${faskes.openStatus} • Tutup ${faskes.closeTime}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007B7A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Saat dipencet, kamera peta bergerak ke lokasi fasilitas tersebut
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(faskes.lat, faskes.lng), zoom: 16.0),
                    ),
                  );
                },
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Lihat Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}