import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:akses_tb/models/facility.dart';
import 'package:akses_tb/services/faskes_service.dart';

class FormFaskesScreen extends StatefulWidget {
  final FaskesModel? facility;

  const FormFaskesScreen({
    super.key,
    this.facility,
  });

  @override
  State<FormFaskesScreen> createState() => _FormFaskesScreenState();
}

class _FormFaskesScreenState extends State<FormFaskesScreen> {
  final _formKey = GlobalKey<FormState>();
  final FacilityService _facilityService = FacilityService();

  bool _isLoading = false;

  // Controllers untuk text input
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _hoursController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _addressController;
  late TextEditingController _patientCountController;
  late TextEditingController _openStatusController;
  late TextEditingController _closeTimeController;
  late TextEditingController _distanceController;

  // State untuk dropdown dan boolean (switch)
  late String _selectedType;
  late String _selectedStatus;
  late bool _hasTCM;
  late bool _hasOAT;

  // Controller & State untuk Interactive Map Picker
  GoogleMapController? _mapController;
  late LatLng _selectedMapLocation;

  @override
  void initState() {
    super.initState();
    // Default coordinate (Pusat Surabaya) atau koordinat eksisting faskes
    final initialLat = widget.facility?.latitude ?? -7.2675;
    final initialLng = widget.facility?.longitude ?? 112.7578;

    _selectedMapLocation = LatLng(initialLat, initialLng);

    _nameController = TextEditingController(text: widget.facility?.name ?? '');
    _phoneController = TextEditingController(text: widget.facility?.phone ?? '');
    _hoursController = TextEditingController(text: widget.facility?.operatingHours ?? '');
    _latController = TextEditingController(text: initialLat.toString());
    _lngController = TextEditingController(text: initialLng.toString());
    _addressController = TextEditingController(text: widget.facility?.address ?? '');

    _patientCountController = TextEditingController(text: widget.facility?.patientCount.toString() ?? '0');
    _openStatusController = TextEditingController(text: widget.facility?.openStatus ?? '');
    _closeTimeController = TextEditingController(text: widget.facility?.closeTime ?? '');
    _distanceController = TextEditingController(text: widget.facility?.distance.toString() ?? '0.0');

    _selectedType = widget.facility?.type ?? 'Puskesmas';
    _selectedStatus = widget.facility?.status ?? 'Aktif';
    _hasTCM = widget.facility?.hasTCM ?? false;
    _hasOAT = widget.facility?.hasOAT ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    _patientCountController.dispose();
    _openStatusController.dispose();
    _closeTimeController.dispose();
    _distanceController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Update map pin when user manually types in the lat/lng textfields
  void _updateMapFromTextFields() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat != null && lng != null) {
      final newLoc = LatLng(lat, lng);
      setState(() {
        _selectedMapLocation = newLoc;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(newLoc));
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final double parsedLat = double.tryParse(_latController.text.trim()) ?? 0.0;
        final double parsedLng = double.tryParse(_lngController.text.trim()) ?? 0.0;
        final double parsedDistance = double.tryParse(_distanceController.text.trim()) ?? 0.0;
        final int parsedPatient = int.tryParse(_patientCountController.text.trim()) ?? 0;

        final savedData = FaskesModel(
          id: widget.facility?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          type: _selectedType,
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          operatingHours: _hoursController.text.trim(),
          latitude: parsedLat,
          longitude: parsedLng,
          patientCount: parsedPatient,
          status: _selectedStatus,
          isUpdated: true,
          distance: parsedDistance,
          hasTCM: _hasTCM,
          hasOAT: _hasOAT,
          openStatus: _openStatusController.text.trim(),
          closeTime: _closeTimeController.text.trim(),
        );

        if (widget.facility != null) {
          await _facilityService.updateFacility(savedData);
        } else {
          await _facilityService.createFacility(savedData);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data fasilitas berhasil disimpan!'),
              ],
            ),
            backgroundColor: const Color(0xFF007B7A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal menyimpan data: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Builder khusus untuk Map
  Widget _buildMapPicker() {
    final bool isMobile = !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

    // Fallback jika tidak di mobile/tdk dukung Google Maps
    if (!isMobile) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Peta interaktif hanya tersedia di perangkat Mobile.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedMapLocation,
              zoom: 15.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedMapLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedMapLocation = location;
                // Update text fields secara otomatis saat peta di-tap
                _latController.text = location.latitude.toString();
                _lngController.text = location.longitude.toString();
              });
              _mapController?.animateCamera(CameraUpdate.newLatLng(location));
            },
            zoomControlsEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Instruksi mengambang di atas peta
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: const [
                  Icon(Icons.touch_app, size: 16, color: Color(0xFF007B7A)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ketuk area peta untuk menentukan titik koordinat otomatis.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.facility != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Faskes' : 'Tambah Faskes',
          style: const TextStyle(
            color: Color(0xFF007B7A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INFORMASI DASAR CARD
              _buildSectionCard(
                icon: Icons.business_outlined,
                title: 'Informasi Dasar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Fasilitas'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Contoh: RSUD Dr. Soetomo',
                      validatorMsg: 'Nama fasilitas tidak boleh kosong',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Tipe Fasilitas'),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Puskesmas', child: Text('Puskesmas')),
                        DropdownMenuItem(value: 'Rumah Sakit', child: Text('Rumah Sakit')),
                        DropdownMenuItem(value: 'Klinik', child: Text('Klinik')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. KONTAK & OPERASIONAL CARD
              _buildSectionCard(
                icon: Icons.access_time_outlined,
                title: 'Kontak & Operasional',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nomor Telepon'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Contoh: 031-5501078',
                      validatorMsg: 'Nomor telepon wajib diisi',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Jam Operasional (Rentang)'),
                    _buildTextField(
                      controller: _hoursController,
                      hint: 'Contoh: 24 Jam atau Senin-Jumat',
                      validatorMsg: 'Jam operasional wajib diisi',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Status Buka'),
                              _buildTextField(
                                controller: _openStatusController,
                                hint: 'Buka 24 Jam',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Jam Tutup'),
                              _buildTextField(
                                controller: _closeTimeController,
                                hint: '-',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. LAYANAN & DATA PASIEN CARD
              _buildSectionCard(
                icon: Icons.medical_services_outlined,
                title: 'Layanan Medis & Data',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Jumlah Pasien Aktif'),
                    _buildTextField(
                      controller: _patientCountController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Jumlah pasien wajib diisi',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Tersedia Layanan TCM'),
                        Switch(
                          value: _hasTCM,
                          activeColor: const Color(0xFF007B7A),
                          onChanged: (val) => setState(() => _hasTCM = val),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Tersedia Obat OAT'),
                        Switch(
                          value: _hasOAT,
                          activeColor: const Color(0xFF007B7A),
                          onChanged: (val) => setState(() => _hasOAT = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. LOKASI & ALAMAT CARD
              _buildSectionCard(
                icon: Icons.location_on_outlined,
                title: 'Lokasi Peta & Alamat',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- MAP PICKER ---
                    _buildMapPicker(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Latitude'),
                              TextFormField(
                                controller: _latController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => _updateMapFromTextFields(),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Lintang tidak valid' : null,
                                decoration: InputDecoration(
                                  hintText: '-7.2675',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Longitude'),
                              TextFormField(
                                controller: _lngController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => _updateMapFromTextFields(),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Bujur tidak valid' : null,
                                decoration: InputDecoration(
                                  hintText: '112.7578',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Estimasi Jarak (Km)'),
                    _buildTextField(
                      controller: _distanceController,
                      hint: '3.5',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Alamat Lengkap'),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Alamat lengkap wajib diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Jl. Mayjen Prof. Dr. Moestopo No.6-8...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. STATUS SISTEM CARD
              _buildSectionCard(
                icon: Icons.verified_user_outlined,
                title: 'Konfigurasi Sistem',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Status Keaktifan Faskes'),
                    Switch(
                      value: _selectedStatus == 'Aktif',
                      activeColor: const Color(0xFF007B7A),
                      onChanged: (bool value) {
                        setState(() {
                          _selectedStatus = value ? 'Aktif' : 'Nonaktif';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF007B7A),
                    side: const BorderSide(color: Color(0xFF007B7A), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007B7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Simpan Data',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (validatorMsg != null && (value == null || value.trim().isEmpty)) {
          return validatorMsg;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.01),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007B7A), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}