// Lokasi: lib/models/article_model.dart

class Article {
  final String title;
  final String snippet;
  final String category; // NewsAPI menggunakan 'source.name'
  final String date;
  final String imageUrl;
  final String contentUrl; // URL artikel asli

  Article({
    required this.title,
    required this.snippet,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.contentUrl,
  });

  // Jembatan dari NewsAPI JSON ke Objek Flutter
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Tanpa Judul',
      // Menggunakan description atau content jika snippet tidak ada
      snippet: json['description'] ?? 'Tidak ada deskripsi yang tersedia.',
      category: json['source']['name'] ?? 'Berita Kesehatan',
      // Memotong format waktu ISO 8601 (2023-10-18T10:00:00Z) menjadi tanggal saja
      date: (json['publishedAt'] != null)
          ? json['publishedAt'].toString().split('T')[0]
          : 'Tanggal tidak diketahui',
      imageUrl: json['urlToImage'] ?? '', // Bisa null dari API
      contentUrl: json['url'] ?? '',
    );
  }
}