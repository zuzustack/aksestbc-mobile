import 'package:flutter/material.dart';
import '../../models/facility.dart';
import '../../services/faskes_service.dart';
import '../guest/map_screen.dart';
import 'form_faskes_screen.dart';

class ManageFaskesScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ManageFaskesScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<ManageFaskesScreen> createState() => _ManageFaskesScreenState();
}

class _ManageFaskesScreenState extends State<ManageFaskesScreen> {
  final FaskesService _faskesService = FaskesService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTypeFilter = 'Semua'; // 'Semua', 'Puskesmas', 'Rumah Sakit'
  late List<Facility> _facilities;

  @override
  void initState() {
    super.initState();
    _facilities = List.from(_faskesService.getFacilities());
  }

  // Filtering Logic
  List<Facility> get _filteredFacilities {
    return _facilities.where((f) {
      final matchesSearch = f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.address.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedTypeFilter == 'Semua' || f.type == _selectedTypeFilter;
      
      return matchesSearch && matchesType;
    }).toList();
  }

  // Dashboard Stats Calculations
  int get _totalFaskes => _facilities.length + 120; // Offset to match mockup stat (124 total with initial 4)
  int get _activeFaskes => _facilities.where((f) => f.status == 'Aktif').length + 115; // Offset to match active stat (118 with 3 active initial)
  int get _needsReviewFaskes => _facilities.where((f) => f.status == 'Perlu Review').length + 5; // Offset to match review stat (6 with 1 review initial)

  // Dialog to delete facility
  void _confirmDeleteFacility(BuildContext context, Facility faskes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text('Hapus Fasilitas', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus "${faskes.name}" dari sistem?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _faskesService.deleteFacility(faskes.id);
                setState(() {
                  _facilities = List.from(_faskesService.getFacilities());
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Fasilitas berhasil dihapus.'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Open Faskes in the internal interactive Map Screen
  void _openInMaps(BuildContext context, Facility faskes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLat: faskes.latitude,
          initialLng: faskes.longitude,
          highlightName: faskes.name,
        ),
      ),
    );
  }

  // Filter dialog Bottom Sheet matching mockup filters
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Fasilitas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipe Fasilitas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFilterChip(setModalState, 'Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip(setModalState, 'Puskesmas'),
                      const SizedBox(width: 8),
                      _buildFilterChip(setModalState, 'Rumah Sakit'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007B7A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(StateSetter setModalState, String label) {
    final isSelected = _selectedTypeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF007B7A),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (selected) {
        if (selected) {
          setModalState(() {
            _selectedTypeFilter = label;
          });
          setState(() {
            _selectedTypeFilter = label;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // AppBar matching Image 1 exactly
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: () {
            // Confirmation dialog to logout
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Keluar dari Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Apakah Anda yakin ingin keluar dari panel admin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onLogout();
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Row(
          children: const [
            Text(
              'AksesTBC',
              style: TextStyle(
                color: Color(0xFF007B7A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Action chip to toggle back to Kelola Berita (News Dashboard)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: ActionChip(
              backgroundColor: const Color(0xFFE6F4F4),
              side: BorderSide.none,
              label: Row(
                children: const [
                  Icon(Icons.newspaper, color: Color(0xFF007B7A), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Kelola Berita',
                    style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
              onPressed: () {
                // Smoothly pop and return to the main admin news dashboard
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Manajemen Fasilitas\nKesehatan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola data Puskesmas dan Rumah Sakit rujukan TBC di Surabaya.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            // 4 Stats Cards Grid Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  _buildStatCard(
                    icon: Icons.add_box,
                    title: 'TOTAL FASKES',
                    value: _totalFaskes.toString(),
                    color: const Color(0xFF007B7A),
                    bgColor: Colors.white,
                  ),
                  _buildStatCard(
                    icon: Icons.history,
                    title: 'UPDATE TERAKHIR',
                    value: 'Hari ini,\n08:30',
                    color: const Color(0xFF64748B),
                    bgColor: Colors.white,
                    valueSize: 18,
                  ),
                  _buildStatCard(
                    icon: Icons.verified,
                    title: 'FASKES AKTIF',
                    value: _activeFaskes.toString(),
                    color: const Color(0xFF0D9488),
                    bgColor: Colors.white,
                  ),
                  _buildStatCard(
                    icon: Icons.warning,
                    title: 'PERLU REVIEW',
                    value: _needsReviewFaskes.toString(),
                    color: Colors.red.shade700,
                    bgColor: const Color(0xFFFEE2E2), // Light pink warning color as in mockup
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search and Filter Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari nama Puskesmas atau RS...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter slider button
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.tune, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daftar Fasilitas Heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Daftar Fasilitas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // List of Faskes Cards
            _filteredFacilities.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital_outlined, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          Text(
                            'Tidak ada fasilitas kesehatan ditemukan.',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: _filteredFacilities.length,
                    itemBuilder: (context, index) {
                      final faskes = _filteredFacilities[index];
                      return _buildFacilityCard(context, faskes);
                    },
                  ),
            
            // Bottom "Muat Lebih" button
            if (_filteredFacilities.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Semua faskes telah ditampilkan.')),
                      );
                    },
                    child: const Text(
                      'Muat Lebih',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Floating Action Button matching mockup
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
        child: FloatingActionButton.extended(
          elevation: 4,
          backgroundColor: const Color(0xFF007B7A), // matching active button color in Image 1
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () {
            // Navigate to Add Faskes Form
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormFaskesScreen(
                  onSave: (newFacility) {
                    _faskesService.addFacility(newFacility);
                    setState(() {
                      _facilities = List.from(_faskesService.getFacilities());
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fasilitas baru berhasil ditambahkan!'),
                        backgroundColor: Color(0xFF007B7A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text(
            'Tambah Faskes Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Statistics Card Helper
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    double valueSize = 28,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: color == const Color(0xFF64748B) ? const Color(0xFF0F172A) : color,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Facility Card Builder Helper matching Image 1
  Widget _buildFacilityCard(BuildContext context, Facility faskes) {
    final isPuskesmas = faskes.type == 'Puskesmas';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openInMaps(context, faskes),
        splashColor: const Color.fromRGBO(0, 123, 122, 0.04),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle Icon (Light teal for Rumah Sakit, Light blue for Puskesmas)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPuskesmas ? const Color(0xFFEFF6FF) : const Color(0xFFE6F4F4),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isPuskesmas ? Icons.medical_services_outlined : Icons.local_hospital_outlined,
                      color: isPuskesmas ? const Color(0xFF3B82F6) : const Color(0xFF007B7A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title and Type Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                faskes.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPuskesmas ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                faskes.type.toUpperCase(),
                                style: TextStyle(
                                  color: isPuskesmas ? const Color(0xFF1E40AF) : const Color(0xFF475569),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Address text
                        Text(
                          faskes.address,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sub-row status details & Action icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Details
                  Row(
                    children: [
                      // Patient count
                      const Icon(Icons.people_outline_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${faskes.patientCount} Pasien TBC',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      // Dot
                      Text(
                        '•',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                      const SizedBox(width: 8),
                      
                      // Status check or Red warning icon
                      if (faskes.isUpdated) ...[
                        const Icon(Icons.verified_user, size: 14, color: Color(0xFF14B8A6)),
                        const SizedBox(width: 4),
                        const Text(
                          'Aktif',
                          style: TextStyle(fontSize: 11, color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        const Icon(Icons.info, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        const Text(
                          'Data Belum Update',
                          style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),

                  // Action Edit & Delete circular buttons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to Edit Faskes Form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormFaskesScreen(
                                facility: faskes,
                                onSave: (updatedData) {
                                  _faskesService.updateFacility(updatedData);
                                  setState(() {
                                    _facilities = List.from(_faskesService.getFacilities());
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fasilitas berhasil diperbarui!'),
                                      backgroundColor: Color(0xFF007B7A),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDeleteFacility(context, faskes),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red.shade100, width: 1),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.delete_outline_outlined, size: 16, color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
