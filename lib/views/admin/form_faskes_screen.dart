import 'package:flutter/material.dart';
import '../../models/facility.dart';

class FormFaskesScreen extends StatefulWidget {
  final Facility? facility;
  final Function(Facility) onSave;

  const FormFaskesScreen({
    super.key,
    this.facility,
    required this.onSave,
  });

  @override
  State<FormFaskesScreen> createState() => _FormFaskesScreenState();
}

class _FormFaskesScreenState extends State<FormFaskesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _hoursController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _addressController;
  
  late String _selectedType;
  late String _selectedStatus;
  late int _patientCount;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.facility?.name ?? '');
    _phoneController = TextEditingController(text: widget.facility?.phone ?? '');
    _hoursController = TextEditingController(text: widget.facility?.operatingHours ?? '');
    _latController = TextEditingController(text: widget.facility?.latitude.toString() ?? '-7.250445');
    _lngController = TextEditingController(text: widget.facility?.longitude.toString() ?? '112.768845');
    _addressController = TextEditingController(text: widget.facility?.address ?? '');
    
    _selectedType = widget.facility?.type ?? 'Puskesmas';
    _selectedStatus = widget.facility?.status ?? 'Aktif';
    _patientCount = widget.facility?.patientCount ?? 85; // fallback mock patient count
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
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
          isEditMode ? 'Edit Faskes' : 'Kelola Faskes',
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
                    const Text(
                      'Nama Fasilitas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Nama fasilitas tidak boleh kosong' : null,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Puskesmas Rungkut',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tipe Fasilitas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Puskesmas', child: Text('Puskesmas')),
                        DropdownMenuItem(value: 'Rumah Sakit', child: Text('Rumah Sakit')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedType = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. KONTAK INFO CARD
              _buildSectionCard(
                icon: Icons.phone_outlined,
                title: 'Kontak Info',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                      decoration: InputDecoration(
                        hintText: '031-XXXXXXX',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jam Operasional',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _hoursController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Jam operasional tidak boleh kosong' : null,
                      decoration: InputDecoration(
                        hintText: 'Senin - Jumat, 08:00 - 15:00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. LOKASI & ALAMAT CARD
              _buildSectionCard(
                icon: Icons.location_on_outlined,
                title: 'Lokasi & Alamat',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Map preview
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFE2E8F0),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop'), // abstract cartography blueprint
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Overlay to make the map match the gorgeous blue-teal cartography in the mockup
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color.fromRGBO(0, 123, 122, 0.12),
                            ),
                          ),
                          // Premium centered red location marker
                          const Center(
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.redAccent,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Latitude',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _latController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) => value == null || double.tryParse(value) == null ? 'Lintang tidak valid' : null,
                                decoration: InputDecoration(
                                  hintText: '-7.250445',
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
                              const Text(
                                'Longitude',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _lngController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) => value == null || double.tryParse(value) == null ? 'Bujur tidak valid' : null,
                                decoration: InputDecoration(
                                  hintText: '112.768845',
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
                    const Text(
                      'Alamat Lengkap',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Alamat lengkap tidak boleh kosong' : null,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat lengkap fasilitas kesehatan...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Switch (Optional hidden config to control status)
              _buildSectionCard(
                icon: Icons.verified_user_outlined,
                title: 'Konfigurasi Sistem (Admin Only)',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status Keaktifan Faskes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                    Switch(
                      value: _selectedStatus == 'Aktif',
                      activeThumbColor: const Color(0xFF007B7A),
                      onChanged: (bool value) {
                        setState(() {
                          _selectedStatus = value ? 'Aktif' : 'Perlu Review';
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

      // Bottom bar with Cancel & Save buttons matching mockup
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final savedData = Facility(
                        id: widget.facility?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        type: _selectedType,
                        address: _addressController.text.trim(),
                        phone: _phoneController.text.trim(),
                        operatingHours: _hoursController.text.trim(),
                        latitude: double.parse(_latController.text.trim()),
                        longitude: double.parse(_lngController.text.trim()),
                        patientCount: _patientCount,
                        status: _selectedStatus,
                        isUpdated: _selectedStatus == 'Aktif', // marked as updated if active
                        // Carry forward guest parameters if editing
                        distance: widget.facility?.distance ?? 1.5,
                        hasTCM: widget.facility?.hasTCM ?? (_selectedType == 'Rumah Sakit'),
                        hasOAT: widget.facility?.hasOAT ?? true,
                        openStatus: widget.facility?.openStatus ?? (_selectedType == 'Rumah Sakit' ? 'Buka 24 Jam' : 'Buka'),
                        closeTime: widget.facility?.closeTime ?? (_selectedType == 'Rumah Sakit' ? '-' : '14:00'),
                      );
                      widget.onSave(savedData);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
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

  // Card wrapper helper for modular sections
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
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
