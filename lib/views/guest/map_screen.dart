import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/facility.dart';
// Pastikan path ke service ini sesuai dengan di project kamu
import '../../services/faskes_service.dart';

// Bounding box for mapping coordinates to relative pixels on our vector abstract map of Surabaya
const double minLat = -7.3100;
const double maxLat = -7.2100;
const double minLng = 112.7200;
const double maxLng = 112.8200;

class MapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? highlightName;

  const MapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.highlightName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FacilityService _faskesService = FacilityService();

  GoogleMapController? _googleMapController;
  final TransformationController _transformationController = TransformationController();

  late LatLng _currentCenter;
  late String _selectedTypeFilter; // 'Semua', 'Puskesmas', 'Rumah Sakit'
  late String _searchQuery;

  // Toggle between our gorgeous Interactive Vector Map (Default) and standard Google Maps
  bool _useGoogleMaps = false;
  FaskesModel? _selectedFacility;

  // Flag untuk memastikan fokus kamera hanya berjalan pada load pertama stream
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _selectedTypeFilter = 'Semua';
    _searchQuery = '';

    // Set default initial center coordinates (jika data gagal dimuat)
    final double initialLat = widget.initialLat ?? -7.2650;
    final double initialLng = widget.initialLng ?? 112.7700;
    _currentCenter = LatLng(initialLat, initialLng);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  // Calculate relative X coordinate for abstract map
  double _getX(double lng, double width) {
    final ratio = (lng - minLng) / (maxLng - minLng);
    return ratio.clamp(0.0, 1.0) * width;
  }

  // Calculate relative Y coordinate for abstract map
  double _getY(double lat, double height) {
    final ratio = (maxLat - lat) / (maxLat - minLat);
    return ratio.clamp(0.0, 1.0) * height;
  }

  // Animate the custom vector map coordinate to center
  void _centerVectorMap(double lat, double lng) {
    const double mapSize = 800.0;
    final double x = _getX(lng, mapSize);
    final double y = _getY(lat, mapSize);

    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height * 0.55;

    final double offsetX = (screenW / 2) - x;
    final double offsetY = (screenH / 2) - y;

    _transformationController.value = Matrix4.identity()
      ..setEntry(0, 0, 1.2) // scaleX
      ..setEntry(1, 1, 1.2) // scaleY
      ..setEntry(0, 3, offsetX) // translateX
      ..setEntry(1, 3, offsetY); // translateY
  }

  // Animate Google Map camera
  void _centerGoogleMap(double lat, double lng) {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16.0),
      ),
    );
  }

  // Handle facility card selection
  void _onFacilitySelected(FaskesModel facility) {
    setState(() {
      _selectedFacility = facility;
      _currentCenter = LatLng(facility.latitude, facility.longitude);
    });

    if (_useGoogleMaps) {
      _centerGoogleMap(facility.latitude, facility.longitude);
    } else {
      _centerVectorMap(facility.latitude, facility.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height * 0.58;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AksesTBC Layanan',
          style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: _useGoogleMaps ? 'Gunakan Peta Interaktif' : 'Gunakan Google Maps',
            icon: Icon(
              _useGoogleMaps ? Icons.map_outlined : Icons.satellite_outlined,
              color: const Color(0xFF007B7A),
            ),
            onPressed: () {
              setState(() {
                _useGoogleMaps = !_useGoogleMaps;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_useGoogleMaps) {
                  _centerGoogleMap(_currentCenter.latitude, _currentCenter.longitude);
                } else {
                  _centerVectorMap(_currentCenter.latitude, _currentCenter.longitude);
                }
              });
            },
          ),
        ],
      ),

      // StreamBuilder untuk membaca data Real-time
      body: StreamBuilder<List<FaskesModel>>(
        stream: _faskesService.streamFacilities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF007B7A)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan muat peta: ${snapshot.error}'));
          }

          final allFacilities = snapshot.data ?? [];

          // Logika First Load: Memilih highlight faskes dan memusatkan kamera HANYA saat data pertama kali masuk
          if (_isFirstLoad && allFacilities.isNotEmpty) {
            if (widget.highlightName != null) {
              _selectedFacility = allFacilities.firstWhere(
                    (f) => f.name.toLowerCase().contains(widget.highlightName!.toLowerCase()),
                orElse: () => allFacilities.first,
              );
            } else {
              _selectedFacility = allFacilities.first;
            }

            _currentCenter = LatLng(_selectedFacility!.latitude, _selectedFacility!.longitude);

            // Pusatkan peta setelah frame selesai di-render
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_useGoogleMaps) {
                _centerGoogleMap(_currentCenter.latitude, _currentCenter.longitude);
              } else {
                _centerVectorMap(_currentCenter.latitude, _currentCenter.longitude);
              }
            });
            _isFirstLoad = false;
          }

          // Pemfilteran List Berdasarkan Pencarian dan Chip
          final filteredFacilities = allFacilities.where((f) {
            final matchesSearch = f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                f.address.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesType = _selectedTypeFilter == 'Semua' || (f.type == _selectedTypeFilter);
            return matchesSearch && matchesType;
          }).toList();

          return Stack(
            children: [
              // --- LAYER 1: MAPS LAYER (CHOSEN MODE) ---
              SizedBox(
                height: viewportHeight,
                child: _useGoogleMaps
                    ? _buildGoogleMapsView(allFacilities)
                    : _buildInteractiveVectorMapView(allFacilities),
              ),

              // --- LAYER 2: Zoom/Map Mode indicator chip ---
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _useGoogleMaps ? Icons.satellite : Icons.map,
                        size: 14,
                        color: const Color(0xFF007B7A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _useGoogleMaps ? 'Mode Google Maps' : 'Peta Vektor Pintar (Aktif)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- LAYER 3: Panel Faskes Terdekat (Draggable Sheet dengan Lazy Loading) ---
              DraggableScrollableSheet(
                initialChildSize: 0.44,
                minChildSize: 0.18,
                maxChildSize: 0.9,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.06),
                          blurRadius: 16,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    // MENGGUNAKAN CUSTOM SCROLL VIEW UNTUK LAZY LOADING
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // SLIVER 1: Header statis (Handle, Judul, Search)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Column(
                              children: [
                                // Pull Handle bar
                                Center(
                                  child: Container(
                                    width: 44,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Header Row with Filter Chip Switcher
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Faskes Terdekat',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Surabaya & Sekitarnya',
                                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                    // Quick filter button
                                    TextButton.icon(
                                      onPressed: () => _showFilterDialog(),
                                      icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF007B7A), size: 16),
                                      label: Text(
                                        _selectedTypeFilter == 'Semua' ? 'Filter' : _selectedTypeFilter,
                                        style: const TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Search input
                                Container(
                                  height: 44,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Cari faskes atau kecamatan...',
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                      prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // SLIVER 2: Kondisi Kosong
                        if (filteredFacilities.isEmpty)
                          const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text('Tidak ada Faskes ditemukan', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          )
                        // SLIVER 3: LAZY LOAD LIST ITEMS
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  final faskes = filteredFacilities[index];
                                  final isSelected = _selectedFacility?.id == faskes.id;

                                  return InkWell(
                                    onTap: () => _onFacilitySelected(faskes),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 14.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF007B7A) : Colors.grey.shade200,
                                          width: isSelected ? 2.0 : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: _buildFacilityCard(faskes),
                                    ),
                                  );
                                },
                                // Beritahu Flutter jumlah total datanya
                                childCount: filteredFacilities.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // A. GOOGLE MAPS BUILDER
  Widget _buildGoogleMapsView(List<FaskesModel> facilities) {
    final bool isMobile = !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
    if (!isMobile) {
      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.satellite_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Google Maps Satellite Mode tidak didukung di platform ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silakan gunakan Peta Vektor Pintar yang aktif secara offline.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007B7A)),
              onPressed: () {
                setState(() {
                  _useGoogleMaps = false;
                });
              },
              child: const Text('Gunakan Peta Vektor', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentCenter,
        zoom: 14.5,
      ),
      onMapCreated: (GoogleMapController controller) {
        _googleMapController = controller;
        // Opsional: jika ingin menengahkan ulang saat map dibuat
        if (!_isFirstLoad) {
          _centerGoogleMap(_currentCenter.latitude, _currentCenter.longitude);
        }
      },
      markers: facilities.map((faskes) {
        final isSelected = _selectedFacility?.id == faskes.id;
        return Marker(
          markerId: MarkerId(faskes.id),
          position: LatLng(faskes.latitude, faskes.longitude),
          infoWindow: InfoWindow(
            title: faskes.name,
            snippet: faskes.hasTCM ? 'Tes TCM Tersedia' : 'Layanan TBC Dasar',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
          ),
          onTap: () {
            _onFacilitySelected(faskes);
          },
        );
      }).toSet(),
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  // B. HIGH-FIDELITY VECTOR MAP BUILDER
  Widget _buildInteractiveVectorMapView(List<FaskesModel> facilities) {
    const double mapSize = 800.0;

    return Container(
      color: const Color(0xFFE2F3F3), // stylized soft teal grid background
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 3.5,
          minScale: 0.5,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(mapSize, mapSize),
                painter: SurabayaStreetPainter(),
              ),

              ...facilities.map((faskes) {
                final double x = _getX(faskes.longitude, mapSize);
                final double y = _getY(faskes.latitude, mapSize);
                final isSelected = _selectedFacility?.id == faskes.id;

                return Positioned(
                  left: x - 18, // center offset
                  top: y - 36, // height offset
                  child: GestureDetector(
                    onTap: () {
                      _onFacilitySelected(faskes);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: isSelected ? Colors.redAccent : const Color(0xFF007B7A),
                          size: isSelected ? 40 : 32,
                        ),
                        Positioned(
                          top: 4,
                          child: Icon(
                            faskes.type == 'Rumah Sakit' ? Icons.local_hospital : Icons.medical_services_outlined,
                            color: Colors.white,
                            size: isSelected ? 16 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityCard(FaskesModel faskes) {
    final isRS = faskes.type == 'Rumah Sakit';

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRS ? const Color(0xFFE2E8F0) : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  faskes.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isRS ? const Color(0xFF475569) : const Color(0xFF1E40AF),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  faskes.address,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (faskes.hasTCM)
                _buildBadge(Icons.check_circle, 'Tersedia TCM', const Color(0xFFE6F4EA), const Color(0xFF137333)),
              const SizedBox(width: 6),
              if (faskes.hasOAT)
                _buildBadge(Icons.medical_services, 'OAT Gratis', const Color(0xFFE8F0FE), const Color(0xFF1A73E8)),
              const SizedBox(width: 6),
              _buildBadge(Icons.navigation_outlined, '${faskes.distance} km', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jam Operasional', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    '${faskes.openStatus} • ${faskes.closeTime}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
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
                  _onFacilitySelected(faskes);
                },
                icon: const Icon(Icons.directions, size: 14),
                label: const Text('Fokus Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pilih Tipe Filter', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Semua'),
              _buildFilterOption('Puskesmas'),
              _buildFilterOption('Rumah Sakit'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String val) {
    return ListTile(
      title: Text(val),
      trailing: _selectedTypeFilter == val ? const Icon(Icons.check, color: Color(0xFF007B7A)) : null,
      onTap: () {
        setState(() {
          _selectedTypeFilter = val;
        });
        Navigator.pop(context);
      },
    );
  }
}

// STUNNING ABSTRACT STREET CARTOGRAPHY PAINTER FOR ZERO-API ERROR-FREE MAP VIEW
class SurabayaStreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1.0;

    final riverPaint = Paint()
      ..color = const Color(0xFFBFE0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round;

    final primaryStreetPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double step = 80.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final riverPath = Path()
      ..moveTo(200, 0)
      ..cubicTo(260, 200, 160, 400, 320, 600)
      ..lineTo(220, 800);
    canvas.drawPath(riverPath, riverPaint);

    canvas.drawLine(const Offset(0, 300), const Offset(800, 340), primaryStreetPaint);
    canvas.drawLine(const Offset(400, 0), const Offset(360, 800), primaryStreetPaint);
    canvas.drawLine(const Offset(100, 100), const Offset(700, 700), primaryStreetPaint);

    canvas.drawLine(const Offset(0, 120), const Offset(800, 120), secondaryStreetPaint);
    canvas.drawLine(const Offset(0, 520), const Offset(800, 520), secondaryStreetPaint);
    canvas.drawLine(const Offset(180, 0), const Offset(180, 800), secondaryStreetPaint);
    canvas.drawLine(const Offset(620, 0), const Offset(620, 800), secondaryStreetPaint);

    final neighborhoodA = Path()
      ..moveTo(480, 200)
      ..lineTo(580, 200)
      ..lineTo(580, 260)
      ..lineTo(480, 260)
      ..close();
    canvas.drawPath(neighborhoodA, secondaryStreetPaint);

    final neighborhoodB = Path()
      ..moveTo(100, 450)
      ..lineTo(100, 560)
      ..lineTo(220, 560);
    canvas.drawPath(neighborhoodB, secondaryStreetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}