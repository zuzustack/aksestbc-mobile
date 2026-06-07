import 'package:flutter/material.dart';
// Model dari API News
import '../../models/article.dart';
// Model dari Firestore CRUD
import '../../models/article.dart' as fs_model;
import '../../services/news_service.dart';
import '../../services/article_service.dart'; // Service Firestore kita
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

// Tambahkan SingleTickerProviderStateMixin untuk TabBar animasi
class _InfoTbcScreenState extends State<InfoTbcScreen> with SingleTickerProviderStateMixin {
  // Services
  final NewsService _newsService = NewsService();
  final ArticleService _firestoreService = ArticleService();

  // Future untuk API
  late Future<List<Article>> _futureNews;

  @override
  void initState() {
    super.initState();
    // Memanggil API HANYA SEKALI
    _futureNews = _newsService.fetchTbcNews();
  }

  @override
  Widget build(BuildContext context) {
    // Membungkus seluruh Scaffold dengan DefaultTabController (2 tab)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'AksesTBC Edukasi',
            style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black54),
              onPressed: () {},
            )
          ],
          // INI ADALAH KUNCI UNTUK 2 TAB
          bottom: const TabBar(
            labelColor: Color(0xFF007B7A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF007B7A),
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: 'Berita Global (API)'),
              Tab(text: 'Info Surabaya (Admin)'),
            ],
          ),
        ),

        // TabBarView akan menampilkan konten sesuai tab yang aktif
        body: TabBarView(
          children: [
            // TAB 1: Berita dari News API (FutureBuilder)
            _buildApiNewsTab(),

            // TAB 2: Berita dari Admin Firestore (StreamBuilder)
            _buildFirestoreNewsTab(),
          ],
        ),

        // Footer Admin Tetap Ada di Bawah
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () {
                if (widget.onAdminLoginPressed != null) {
                  widget.onAdminLoginPressed!();
                }
              },
              icon: const Icon(Icons.admin_panel_settings, color: Colors.grey, size: 16),
              label: const Text('Admin Login', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: KONTEN DARI NEWS API
  // ==========================================
  Widget _buildApiNewsTab() {
    return FutureBuilder<List<Article>>(
      future: _futureNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF007B7A)));
        } else if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat berita.', style: TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada berita TBC saat ini.'));
        }

        final articles = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final currentArticle = articles[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => DetailArticleScreen(article: currentArticle),
                ));
              },
              child: _buildApiCard(currentArticle),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 2: KONTEN DARI FIRESTORE ADMIN
  // ==========================================
  Widget _buildFirestoreNewsTab() {
    // Menggunakan StreamBuilder agar data dari Admin selalu Real-time
    return StreamBuilder<List<fs_model.Article>>(
      stream: _firestoreService.streamArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF007B7A)));
        } else if (snapshot.hasError) {
          return const Center(child: Text('Gagal terhubung ke database.'));
        }

        final allArticles = snapshot.data ?? [];

        // HANYA tampilkan artikel yang statusnya "Published" (bukan draft)
        final publishedArticles = allArticles.where((a) => !a.isDraft).toList();

        if (publishedArticles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('Belum ada pengumuman dari Admin.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: publishedArticles.length,
          itemBuilder: (context, index) {
            final currentArticle = publishedArticles[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // TODO: Buka link artikel menggunakan url_launcher
                // _launchURL(currentArticle.contentUrl);
              },
              child: _buildFirestoreCard(currentArticle),
            );
          },
        );
      },
    );
  }

  // --- WIDGET CARD UNTUK API (Sama seperti sebelumnya) ---
  Widget _buildApiCard(Article article) {
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
          Container(
            height: 160, width: double.infinity, color: Colors.grey.shade300,
            child: article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                : const Icon(Icons.image),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${article.category} • ${article.date}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(article.snippet, style: const TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET CARD UNTUK FIRESTORE ---
  Widget _buildFirestoreCard(fs_model.Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200, width: 1.5), // Pembeda visual warna teal
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge "PENGUMUMAN RESMI" Overlay
          Stack(
            children: [
              Container(
                height: 160, width: double.infinity, color: Colors.teal.shade50,
                child: Image.network(article.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.apartment, size: 50, color: Colors.teal)),
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Info Resmi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oleh: admin • ${article.formattedDate}', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(article.snippet, style: const TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}