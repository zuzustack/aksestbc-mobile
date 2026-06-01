import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akses_tb/models/facility.dart'; // Sesuaikan dengan path model kamu

class FacilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nama collection yang digunakan di Firestore
  final String _collectionName = 'fasilitas_kesehatan';

  // ==========================================
  // 1. CREATE (Menambahkan Data Baru)
  // ==========================================
  Future<void> createFacility(FaskesModel facility) async {
    try {
      // Menggunakan .set() dengan ID dokumen yang spesifik
      await _db
          .collection(_collectionName)
          .doc(facility.id)
          .set(facility.toMap());
      print('Data faskes berhasil ditambahkan!');
    } catch (e) {
      print('Gagal menambahkan data: $e');
      rethrow;
    }
  }

  // ==========================================
  // 2. READ (Membaca Data secara Real-time)
  // ==========================================
  Stream<List<FaskesModel>> streamFacilities() {
    // Mengambil data secara real-time berdasarkan waktu penambahan atau nama
    return _db
        .collection(_collectionName)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Asumsi kamu memiliki factory method fromMap di model Facility
        return FaskesModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // (Opsional) READ: Mengambil data hanya sekali (One-time fetch)
  Future<List<FaskesModel>> getFacilities() async {
    try {
      QuerySnapshot snapshot = await _db.collection(_collectionName).get();
      return snapshot.docs.map((doc) {
        return FaskesModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Gagal mengambil data: $e');
      rethrow;
    }
  }

  // ==========================================
  // 3. UPDATE / EDIT (Memperbarui Data)
  // ==========================================
  Future<void> updateFacility(FaskesModel facility) async {
    try {
      // Menggunakan .update() agar hanya menimpa field yang ada
      // tanpa menghapus field lain yang mungkin tidak ikut di-map
      await _db
          .collection(_collectionName)
          .doc(facility.id)
          .update(facility.toMap());
      print('Data faskes berhasil diperbarui!');
    } catch (e) {
      print('Gagal memperbarui data: $e');
      rethrow;
    }
  }

  // ==========================================
  // 4. DELETE (Menghapus Data)
  // ==========================================
  Future<void> deleteFacility(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
      print('Data faskes dengan ID $id berhasil dihapus!');
    } catch (e) {
      print('Gagal menghapus data: $e');
      rethrow;
    }
  }
}