import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manage_faskes_screen.dart';

class DashboardArticle {
  final String id;
  String title;
  String snippet;
  String category;
  String date;
  String imageUrl;
  String author;
  String status; // 'Published' or 'Draft'
  bool isDraft;
  String contentUrl;

  DashboardArticle({
    required this.id,
    required this.title,
    required this.snippet,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.author,
    required this.status,
    required this.isDraft,
    required this.contentUrl,
  });
}

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
  String _selectedTab = 'Published'; // Standard active tab as shown in the image

  // Mock list of articles based exactly on the user's provided UI image
  final List<DashboardArticle> _articles = [
    DashboardArticle(
      id: '1',
      title: 'Panduan Lengkap Pendampingan Pasien TBC di...',
      snippet: 'Langkah-langkah penting bagi keluarga untuk memastikan kepatuhan minum obat dan..',
      category: 'Kesehatan',
      date: '24 Okt 2023',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600&auto=format&fit=crop', // Patient and caretaker representation
      author: 'dr. Anisa',
      status: 'Published',
      isDraft: false,
      contentUrl: 'https://ayosehat.kemkes.go.id/tuberkulosis-tbc',
    ),
    DashboardArticle(
      id: '2',
      title: 'Inovasi Terbaru dalam Pengobatan TBC Resistan Obat',
      snippet: 'Membahas regimen pengobatan jangka pendek yang baru direkomendasikan oleh..',
      category: 'Penelitian',
      date: 'Terakhir diedit: Hari ini',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop', // Wellness/active stretching character
      author: 'Admin',
      status: 'Draft',
      isDraft: true,
      contentUrl: 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
    ),
    DashboardArticle(
      id: '3',
      title: 'Jadwal Screening TBC Gratis di Puskesmas Surabaya Timur',
      snippet: 'Informasi lengkap mengenai jadwal, lokasi, dan syarat pendaftaran untuk program screening...',
      category: 'Info Surabaya',
      date: '18 Okt 2023',
      imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=600&auto=format&fit=crop', // Male portrait/doctor lookalike
      author: 'Dinkes SBY',
      status: 'Published',
      isDraft: false,
      contentUrl: 'https://surabaya.go.id/',
    ),
  ];

  // Logic to get articles based on selected tab filter
  List<DashboardArticle> get _filteredArticles {
    if (_selectedTab == 'Published') {
      return _articles.where((article) => !article.isDraft).toList();
    } else if (_selectedTab == 'Drafts') {
      return _articles.where((article) => article.isDraft).toList();
    } else {
      return _articles; // 'Semua'
    }
  }

  // Count helper functions
  int get _allCount => _articles.length;
  int get _publishedCount => _articles.where((a) => !a.isDraft).toList().length;
  int get _draftsCount => _articles.where((a) => a.isDraft).toList().length;

  // Dialog to delete article
  void _confirmDeleteArticle(BuildContext context, DashboardArticle article) {
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
              onPressed: () {
                setState(() {
                  _articles.removeWhere((item) => item.id == article.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Berita berhasil dihapus.'),
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

  // Launch URL helper method
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
        SnackBar(
          content: Text('Gagal membuka artikel: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Dialog to Add/Edit article - Only URL and Status needed
  void _showAddEditArticleDialog(BuildContext context, {DashboardArticle? article}) {
    final urlController = TextEditingController(text: article?.contentUrl ?? '');
    String status = article?.status ?? 'Published';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article == null ? 'Tambah Berita Baru' : 'Edit Berita',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: 'URL Berita',
                        hintText: 'Masukkan URL berita (contoh: https://detik.com/health...)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF007B7A), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Status Berita',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Published'),
                          selected: status == 'Published',
                          selectedColor: const Color(0xFF007B7A),
                          labelStyle: TextStyle(
                            color: status == 'Published' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                status = 'Published';
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Draft'),
                          selected: status == 'Draft',
                          selectedColor: const Color(0xFF007B7A),
                          labelStyle: TextStyle(
                            color: status == 'Draft' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                status = 'Draft';
                              });
                            }
                          },
                        ),
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
                        onPressed: () {
                          String url = urlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL berita tidak boleh kosong.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Ensure clean protocol format
                          if (!url.startsWith('http://') && !url.startsWith('https://')) {
                            url = 'https://$url';
                          }

                          // Auto-generate beautiful premium metadata from domain and url structure
                          String domain = 'Sumber Web';
                          String cleanTitle = 'Artikel Kesehatan Terbaru';
                          
                          try {
                            final uri = Uri.parse(url);
                            domain = uri.host.replaceFirst('www.', '');
                            
                            // Construct beautiful clean title from the URL path segments
                            if (uri.pathSegments.isNotEmpty) {
                              final lastSegment = uri.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
                              if (lastSegment.isNotEmpty) {
                                // Clean up typical URL segment markers
                                final rawWords = lastSegment
                                    .replaceAll('.html', '')
                                    .replaceAll('.php', '')
                                    .replaceAll('-', ' ')
                                    .replaceAll('_', ' ')
                                    .split(' ');
                                
                                final capitalized = rawWords
                                    .map((w) => w.isNotEmpty 
                                        ? '${w[0].toUpperCase()}${w.substring(1)}' 
                                        : '')
                                    .where((w) => w.isNotEmpty)
                                    .join(' ');
                                
                                if (capitalized.trim().isNotEmpty) {
                                  cleanTitle = capitalized;
                                }
                              }
                            }
                          } catch (_) {}

                          final snippet = 'Baca artikel kesehatan selengkapnya mengenai Tuberkulosis (TBC), penanganan medis, dan pencegahan penularan langsung di situs resmi $domain.';
                          
                          final defaultImages = [
                            'https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=600&auto=format&fit=crop',
                          ];
                          final randomImage = defaultImages[url.length % defaultImages.length];

                          if (article == null) {
                            // Add logic
                            setState(() {
                              _articles.insert(
                                0,
                                DashboardArticle(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: cleanTitle,
                                  snippet: snippet,
                                  category: 'Kesehatan',
                                  date: status == 'Draft' ? 'Terakhir diedit: Hari ini' : '26 Mei 2026',
                                  imageUrl: randomImage,
                                  author: domain,
                                  status: status,
                                  isDraft: status == 'Draft',
                                  contentUrl: url,
                                ),
                              );
                            });
                          } else {
                            // Edit logic
                            setState(() {
                              article.contentUrl = url;
                              article.title = cleanTitle;
                              article.snippet = snippet;
                              article.author = domain;
                              article.status = status;
                              article.isDraft = status == 'Draft';
                              article.date = status == 'Draft' ? 'Terakhir diedit: Hari ini' : '26 Mei 2026';
                            });
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(article == null ? 'Berita baru berhasil ditambahkan!' : 'Berita berhasil diperbarui!'),
                              backgroundColor: const Color(0xFF007B7A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          article == null ? 'Simpan Berita' : 'Simpan Perubahan',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
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
      backgroundColor: const Color(0xFFF7F9FC), // Beautiful cool light background
      
      // Clean matching AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007B7A)),
          onPressed: () {
            // Confirm logout dialog to match dashboard capabilities
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
                        Navigator.pop(context); // Close dialog
                        widget.onLogout(); // Invoke logout callback
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ActionChip(
              backgroundColor: const Color(0xFFE6F4F4),
              side: BorderSide.none,
              label: Row(
                children: const [
                  Icon(Icons.local_hospital, color: Color(0xFF007B7A), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Kelola Faskes',
                    style: TextStyle(color: Color(0xFF007B7A), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageFaskesScreen(
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () {
              // Confirm logout dialog
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
                children: [
                  const Text(
                    'Manajemen Berita',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A), // Dark slate title
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Text(
                        'Kelola publikasi dan artikel informasi ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569), // Grey subtitle
                        ),
                      ),
                      Text(
                        'TBC.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Tab Pills Section
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 20.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildTabPill('Semua', _allCount),
                  const SizedBox(width: 10),
                  _buildTabPill('Published', _publishedCount),
                  const SizedBox(width: 10),
                  _buildTabPill('Drafts', _draftsCount),
                ],
              ),
            ),

            // News List Feed
            _filteredArticles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada berita dalam kategori $_selectedTab',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      return _buildNewsCard(context, article);
                    },
                  ),
            
            // Padding bottom to avoid overlap with bottom bar & FAB
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Premium Floating Action Button exactly matching image layout
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
        child: FloatingActionButton.extended(
          elevation: 4,
          backgroundColor: const Color(0xFF005F5D), // Dark premium green as in image
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () => _showAddEditArticleDialog(context),
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text(
            'Tambah Berita',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget helper for Tab Pills
  Widget _buildTabPill(String tabName, int count) {
    // Standard names matching our tabs
    final displayLabel = tabName == 'Semua' 
        ? 'Semua ($count)' 
        : tabName == 'Published' 
            ? 'Published ($count)' 
            : 'Drafts ($count)';

    final isSelected = _selectedTab == tabName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF005F5D) // Deep premium green selected color
              : const Color(0xFFE8F1F2), // Light lavender/bluish-grey unselected color
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: const Color(0xFF005F5D), width: 1)
              : Border.all(color: const Color(0xFFD0E1E2), width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF334155),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  // Widget helper for premium styled News Cards
  Widget _buildNewsCard(BuildContext context, DashboardArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchURL(context, article.contentUrl),
        splashColor: const Color.fromRGBO(0, 123, 122, 0.04),
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Badge Overlay
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.white24),
                      ),
                    ),
                  ),
                ),
                
                // Status Badge (Published / Draft) overlay on top-left
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: article.isDraft 
                          ? const Color(0xFFCBD5E1) // Soft grey for Draft
                          : const Color(0xFF005F5D), // Dark premium green for Published
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article.isDraft ? 'Draft' : 'Published',
                      style: TextStyle(
                        color: article.isDraft ? const Color(0xFF334155) : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata Row (Calendar icon + Date / Last edited info)
                  Row(
                    children: [
                      Icon(
                        article.isDraft ? Icons.edit_note_rounded : Icons.calendar_today_outlined,
                        size: 14,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Snippet/Subtitle
                  Text(
                    article.snippet,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Thin Divider line
                  Container(
                    height: 1,
                    color: const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 14),

                  // Footer Row (Author on left, Action Buttons on right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Oleh: ${article.author}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Action Buttons (Edit & Delete)
                      Row(
                        children: [
                          // Edit button (Pencil Icon)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showAddEditArticleDialog(context, article: article),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Delete button (Trash Icon)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _confirmDeleteArticle(context, article),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.delete_outline_outlined,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
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
