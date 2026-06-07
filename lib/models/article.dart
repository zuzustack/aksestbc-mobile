// Lokasi: lib/models/article_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  String? id; // Nullable karena saat membuat artikel baru, ID belum ada
  String title;
  String snippet;
  String category;
  String date;
  String imageUrl;
  String contentUrl; // Bisa berisi link atau isi artikel penuh
  bool isDraft;

  Article({
    this.id,
    required this.title,
    required this.snippet,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.isDraft,
    required this.contentUrl,
  });

  // Mengubah dari Map (Firestore) menjadi Object Dart
  factory Article.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      snippet: data['snippet'] ?? '',
      category: data['category'] ?? '',
      // Firestore menyimpan tanggal sebagai Timestamp, kita ubah ke DateTime
      date: data['date'],
      imageUrl: data['imageUrl'] ?? '',
      isDraft: data['isDraft'] ?? false,
      contentUrl: data['contentUrl'] ?? '',
    );
  }

  // Mengubah dari Object Dart menjadi Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'snippet': snippet,
      'category': category,
      'date': date,
      'imageUrl': imageUrl,
      'isDraft': isDraft,
      'contentUrl': contentUrl,
    };
  }

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
      isDraft: false,
      imageUrl: json['urlToImage'] ?? '', // Bisa null dari API
      contentUrl: json['url'] ?? '',
    );
  }

  String get formattedDate {
    if (isDraft) return 'Terakhir diedit: Hari ini';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return date;
  }
}