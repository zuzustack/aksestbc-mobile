import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manage_faskes_screen.dart'; // Sesuaikan path ini
import '../../models/article.dart'; // Model Firestore kita
import '../../services/article_service.dart'; // Service Firestore kita

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ArticleService _articleService = ArticleService();
  String _selectedTab = 'Published';

  // Dialog untuk menghapus artikel dari Firestore
  void _confirmDeleteArticle(BuildContext context, Article article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text('Hapus Berita', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus berita "${article.title}"?'),
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
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog konfirmasi
                try {
                  await _articleService.deleteArticle(article.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Berita berhasil dihapus.'),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus: $e')),
                    );
                  }
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuka URL di browser external
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka tautan';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka artikel: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  // Dialog Form Tambah/Edit dengan Field Lengkap sesuai Model
  void _showAddEditArticleDialog(BuildContext context, {Article? article}) {
    final titleController = TextEditingController(text: article?.title ?? '');
    final snippetController = TextEditingController(text: article?.snippet ?? '');
    final imageUrlController = TextEditingController(text: article?.imageUrl ?? '');
    final contentUrlController = TextEditingController(text: article?.contentUrl ?? '');
    final authorController = TextEditingController(text: 'Admin Dinkes');

    String category = article?.category ?? 'Kesehatan';
    String status = (article?.isDraft ?? false) ? 'Draft' : 'Published';
    bool isLoading = false;

    final List<String> categories = ['Kesehatan', 'Info Surabaya', 'Penelitian', 'Pengumuman'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                children: [
                  // Header Dialog
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article == null ? 'Tambah Berita Baru' : 'Edit Berita',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),

                  // Area Form yang bisa di-scroll
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(labelText: 'Judul Artikel', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: snippetController,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Deskripsi Singkat (Snippet)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => category = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: authorController,
                            decoration: const InputDecoration(labelText: 'Penulis / Sumber', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: imageUrlController,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(labelText: 'URL Gambar Thumbnail', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: contentUrlController,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(labelText: 'URL Konten / Link Berita', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 20),
                          const Text('Status Berita', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Published'),
                                selected: status == 'Published',
                                selectedColor: const Color(0xFF007B7A),
                                labelStyle: TextStyle(color: status == 'Published' ? Colors.white : Colors.black87),
                                onSelected: (val) { if (val) setModalState(() => status = 'Published'); },
                              ),
                              const SizedBox(width: 12),
                              ChoiceChip(
                                label: const Text('Draft'),
                                selected: status == 'Draft',
                                selectedColor: const Color(0xFF007B7A),
                                labelStyle: TextStyle(color: status == 'Draft' ? Colors.white : Colors.black87),
                                onSelected: (val) { if (val) setModalState(() => status = 'Draft'); },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Aksi Simpan
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007B7A), foregroundColor: Colors.white),
                      onPressed: isLoading ? null : () async {
                        if (titleController.text.isEmpty || contentUrlController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan URL Konten wajib diisi!')));
                          return;
                        }

                        setModalState(() => isLoading = true);

                        try {
                          final newArticle = Article(
                            id: article?.id, // Pertahankan ID jika sedang proses edit
                            title: titleController.text.trim(),
                            snippet: snippetController.text.trim(),
                            category: category,
                            date: DateTime.now().toString(), // Set selalu ke waktu sekarang saat disimpan
                            imageUrl: imageUrlController.text.trim().isEmpty
                                ? 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600&auto=format&fit=crop'
                                : imageUrlController.text.trim(),
                            isDraft: status == 'Draft',
                            contentUrl: contentUrlController.text.trim(),
                          );

                          if (article == null) {
                            await _articleService.addArticle(newArticle);
                          } else {
                            await _articleService.updateArticle(newArticle);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(article == null ? 'Berhasil ditambah!' : 'Berhasil diupdate!')));
                          }
                        } catch (e) {
                          setModalState(() => isLoading = false);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(article == null ? 'Simpan Berita' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: widget.onLogout,
        ),
        title: const Text('AksesTBC Admin', style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ActionChip(
              backgroundColor: const Color(0xFFE6F4F4),
              side: BorderSide.none,
              label: Row(
                children: const [
                  Icon(Icons.local_hospital, color: Color(0xFF007B7A), size: 14),
                  SizedBox(width: 4),
                  Text('Kelola Faskes', style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageFaskesScreen(onLogout: widget.onLogout))),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // LAZY LOAD STREAM BUILDER
      body: StreamBuilder<List<Article>>(
        stream: _articleService.streamArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF007B7A)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          }

          final allArticles = snapshot.data ?? [];

          // Filter artikel berdasarkan Tab yang dipilih
          final filteredArticles = allArticles.where((article) {
            if (_selectedTab == 'Published') return !article.isDraft;
            if (_selectedTab == 'Drafts') return article.isDraft;
            return true;
          }).toList();

          final int publishedCount = allArticles.where((a) => !a.isDraft).length;
          final int draftsCount = allArticles.where((a) => a.isDraft).length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Manajemen Berita', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Text('Kelola publikasi dan artikel informasi ', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                          Text('TBC.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: [
                      _buildTabPill('Semua', allArticles.length),
                      const SizedBox(width: 10),
                      _buildTabPill('Published', publishedCount),
                      const SizedBox(width: 10),
                      _buildTabPill('Drafts', draftsCount),
                    ],
                  ),
                ),
              ),

              if (filteredArticles.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Tidak ada berita dalam kategori $_selectedTab', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return _buildNewsCard(context, filteredArticles[index]);
                      },
                      childCount: filteredArticles.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
        child: FloatingActionButton.extended(
          elevation: 4,
          backgroundColor: const Color(0xFF005F5D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () => _showAddEditArticleDialog(context),
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text('Tambah Berita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildTabPill(String tabName, int count) {
    final displayLabel = '$tabName ($count)';
    final isSelected = _selectedTab == tabName;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005F5D) : const Color(0xFFE8F1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF005F5D) : const Color(0xFFD0E1E2), width: isSelected ? 1 : 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 10, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchURL(context, article.contentUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180, width: double.infinity, color: const Color(0xFFE2E8F0),
                  child: Image.network(
                    article.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, size: 50, color: Colors.white24)),
                  ),
                ),
                Positioned(
                  top: 14, left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(color: article.isDraft ? const Color(0xFFCBD5E1) : const Color(0xFF005F5D), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      article.isDraft ? 'Draft' : 'Published',
                      style: TextStyle(color: article.isDraft ? const Color(0xFF334155) : Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(article.isDraft ? Icons.edit_note_rounded : Icons.calendar_today_outlined, size: 14, color: const Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(article.formattedDate, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(article.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(article.snippet, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Container(height: 1, color: const Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Oleh: Admin', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _showAddEditArticleDialog(context, article: article), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)))),
                          const SizedBox(width: 4),
                          InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _confirmDeleteArticle(context, article), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.delete_outline_outlined, size: 20, color: Color(0xFF64748B)))),
                        ],
                      ),
                    ],
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