import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../services/news_service.dart';
import 'detail_article.dart';

class InfoTbcScreen extends StatefulWidget {
  final VoidCallback? onAdminLoginPressed;

  const InfoTbcScreen({
    super.key,
    this.onAdminLoginPressed,
  });

  @override
  State<InfoTbcScreen> createState() => _InfoTbcScreenState();
}

class _InfoTbcScreenState extends State<InfoTbcScreen> {
  String selectedFilter = 'Berita Terbaru';
  final List<String> filters = ['Berita Terbaru', 'Tips Kesehatan', 'Info Surabaya'];

  // 1. Inisialisasi Service API kita
  final NewsService _newsService = NewsService();

  // 2. Variabel untuk menampung masa depan (Future) dari daftar artikel
  late Future<List<Article>> _futureArticles;

  @override
  void initState() {
    super.initState();
    // 3. Memanggil API HANYA SEKALI saat halaman pertama kali dibuka
    _futureArticles = _newsService.fetchTbcNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AksesTBC',
          style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER HALAMAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pusat Informasi TBC',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temukan informasi terkini, tips kesehatan, dan berita seputar penanganan TBC.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4A5568), height: 1.5),
                  ),
                ],
              ),
            ),

            // --- FILTER CHIPS ---
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      selectedColor: const Color(0xFF007B7A),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: isSelected ? const Color(0xFF007B7A) : Colors.grey.shade300
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- FUTURE BUILDER (INTI DARI INTEGRASI API) ---
            FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                // Skenario 1: API masih memuat data (Loading)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF007B7A)),
                    ),
                  );
                }

                // Skenario 2: Terjadi masalah jaringan atau error API
                else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Ups! Gagal memuat berita.\nPastikan Anda terhubung ke internet.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // Skenario 3: Data berhasil ditarik, tapi kosong
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Belum ada berita TBC saat ini.'),
                    ),
                  );
                }

                // Skenario 4: Sukses! Kita gambar daftar artikelnya
                final articles = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final currentArticle = articles[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Navigasi ke Halaman Detail dengan membawa data artikel terkait
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailArticleScreen(article: currentArticle),
                          ),
                        );
                      },
                      child: _buildArticleCard(currentArticle),
                    );
                  },
                );
              },
            ),

            // --- FOOTER ADMIN ---
            Center(
              child: TextButton.icon(
                onPressed: () {
                  if (widget.onAdminLoginPressed != null) {
                    widget.onAdminLoginPressed!();
                  }
                },
                icon: const Icon(Icons.admin_panel_settings, color: Colors.grey, size: 16),
                label: const Text('Admin Login', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET CARD ARTIKEL ---
  Widget _buildArticleCard(Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Thumbnail dari Internet
          Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: article.imageUrl.isNotEmpty
                ? Image.network(
              article.imageUrl,
              fit: BoxFit.cover,
              // Jika gambar dari API rusak/URL mati, tampilkan ikon ini
              errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey)
              ),
            )
                : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
          ),

          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${article.category} • ${article.date}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.snippet,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}