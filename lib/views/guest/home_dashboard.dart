import 'package:flutter/material.dart';

import 'map_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Warna latar abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AksesTBC',
          style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, color: Colors.black54),
            ),
            onPressed: () {
              // Aksi menuju profil/login
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di\nAksesTBC',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Platform terpadu untuk menemukan layanan kesehatan dan informasi terpercaya seputar pencegahan serta pengobatan Tuberkulosis di Surabaya.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Komponen Card yang dapat di-reuse
            _buildActionCard(
              icon: Icons.map,
              title: 'Cari Layanan Kesehatan',
              description: 'Temukan puskesmas dan fasilitas kesehatan rujukan penanganan TBC terdekat dari lokasi...',
              buttonText: 'Mulai Mencari',
              onTap: () {
                // Menambahkan navigasi push untuk berpindah ke MapScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.menu_book,
              title: 'Informasi & Edukasi TBC',
              description: 'Pelajari panduan lengkap mengenai gejala, pencegahan, dan alur pengobatan...',
              buttonText: 'Baca Panduan',
              onTap: () {
                // Navigasi
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membangun UI Card agar kode tetap DRY (Don't Repeat Yourself)
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF007B7A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(
                      color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Color(0xFF007B7A), size: 18),
              ],
            ),
          )
        ],
      ),
    );
  }
}