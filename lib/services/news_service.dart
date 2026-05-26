// Lokasi: lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  // Ganti dengan API Key yang Anda dapatkan dari newsapi.org
  static const String _apiKey = '021cde1e690347f5b7416645169dd68e';

  // Menggunakan kata kunci 'tuberkulosis' dalam bahasa Indonesia
  static const String _baseUrl = 'https://newsapi.org/v2/everything?q=kesehatan&language=id&sortBy=publishedAt&apiKey=$_apiKey';

  Future<List<Article>> fetchTbcNews() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];

        // Mengubah list JSON menjadi list objek Article
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat berita: Kode ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}