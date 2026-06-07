import 'package:cloud_firestore/cloud_firestore.dart';
// Sesuaikan import model dengan path kamu
import '../models/article.dart';

class ArticleService {
  final CollectionReference _articleCollection =
  FirebaseFirestore.instance.collection('articles');

  Stream<List<Article>> streamArticles() {
    return _articleCollection.orderBy('date', descending: true).snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Article.fromFirestore(doc)).toList()
    );
  }

  Future<void> addArticle(Article article) async {
    await _articleCollection.add(article.toMap());
  }

  Future<void> updateArticle(Article article) async {
    if (article.id != null) {
      await _articleCollection.doc(article.id).update(article.toMap());
    }
  }

  Future<void> deleteArticle(String id) async {
    await _articleCollection.doc(id).delete();
  }
}