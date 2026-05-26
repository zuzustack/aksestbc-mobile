// Lokasi: lib/views/guest/detail_article.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka browser luar
import '../../models/article.dart';

class DetailArticleScreen extends StatelessWidget {
  // Menerima objek Article dinamis dari halaman InfoTbcScreen
  final Article article;

  const DetailArticleScreen({super.key, required this.article});

  // Fungsi helper untuk membuka URL berita asli di browser HP pengguna
  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(article.contentUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka tautan';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka artikel asli: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Berita TBC',
          style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Opsional: Integrasikan share package di masa depan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. GAMBAR UTAMA DARI API ---
            Container(
              width: double.infinity,
              height: 240,
              color: Colors.grey.shade200,
              child: article.imageUrl.isNotEmpty
                  ? Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              )
                  : const Center(
                child: Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. META DATA (Kategori/Sumber & Tanggal) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F2F2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          article.category, // Nama sumber berita (cth: Detikcom, Kompas)
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF007B7A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        article.date, // Tanggal publikasi dari API
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- 3. JUDUL BERITA DINAMIS ---
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                  const SizedBox(height: 16),

                  // --- 4. ISI RINGKASAN BERITA ---
                  const Text(
                    'Ringkasan Artikel:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.snippet, // Deskripsi/konten singkat dari API
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D3748),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 5. CALL TO ACTION (CTA) UNTUK MEMBACA SELENGKAPNYA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.chrome_reader_mode_outlined, size: 40, color: Color(0xFF007B7A)),
                        const SizedBox(height: 12),
                        const Text(
                          'Ingin Membaca Artikel Secara Lengkap?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Anda akan diarahkan ke situs web eksternal resmi penyedia berita ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007B7A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () => _launchURL(context),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text(
                              'Baca Artikel Asli',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}