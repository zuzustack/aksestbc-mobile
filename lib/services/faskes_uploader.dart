import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/facility.dart'; // Sesuaikan path model kamu

class FaskesUploader {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadRawJsonToFirestore(List<Map<String, dynamic>> rawJsonList) async {
    // Batasan maksimal operasi per batch di Firestore adalah 500
    const int batchSize = 500;
    WriteBatch batch = _db.batch();
    int count = 0;

    try {
      print('Memulai proses refactor dan upload ${rawJsonList.length} data...');

      for (var item in rawJsonList) {
        // 1. Ambil ID unik dari 'kdppk' sebagai ID dokumen
        final String docId = item['kdppk']?.toString().trim() ??
            DateTime.now().millisecondsSinceEpoch.toString() + count.toString();

        // 2. Bersihkan dan petakan tipe data dasar
        final String name = item['nmppk']?.toString().trim() ?? '';
        final String type = item['nmjnsppk']?.toString().trim() ?? 'Fasilitas Kesehatan';
        final String address = item['nmjlnppk']?.toString().trim() ?? '-';
        final String phone = item['telpppk']?.toString().trim() ?? '-';

        final double lat = double.tryParse(item['latitude']?.toString() ?? '0.0') ?? 0.0;
        final double lng = double.tryParse(item['longitude']?.toString() ?? '0.0') ?? 0.0;

        // 3. Berikan nilai default pintar untuk field yang tidak ada di JSON asal
        final bool isRS = type.toLowerCase().contains('rumah sakit');
        final String operatingHours = isRS ? '24 Jam' : '08:00 - 14:00';
        final String openStatus = isRS ? 'Buka 24 Jam' : 'Buka';
        final String closeTime = isRS ? '-' : '14:00';

        // Susun ke dalam model FaskesModel kamu
        final faskesData = FaskesModel(
          id: docId,
          name: name,
          type: type,
          address: address,
          phone: phone,
          operatingHours: operatingHours,
          latitude: lat,
          longitude: lng,
          patientCount: 0, // Default kosong/nol sesuai request
          status: 'Aktif',
          isUpdated: true,
          distance: 0.0,
          hasTCM: isRS,    // Asumsikan TCM tersedia jika jenisnya Rumah Sakit
          hasOAT: true,    // Default tersedia obat OAT gratis
          openStatus: openStatus,
          closeTime: closeTime,
        );

        // 4. Daftarkan dokumen ke dalam antrean batch
        DocumentReference docRef = _db.collection('fasilitas_kesehatan').doc(faskesData.id);
        batch.set(docRef, faskesData.toMap());

        count++;

        // Jika antrean batch sudah mencapai 500, eksekusi/kirim dulu lalu buat antrean baru
        if (count % batchSize == 0) {
          await batch.commit();
          batch = _db.batch();
          print('Berhasil mengirim paket batch faskes sebesar $count data...');
        }
      }

      // Komit sisa data yang belum genap kelipatan 500
      if (count % batchSize != 0) {
        await batch.commit();
      }

      print('Proses selesai! Total $count data faskes berhasil diunggah ke Firestore.');

    } catch (e) {
      print('Terjadi kesalahan saat mengunggah batch faskes: $e');
      rethrow;
    }
  }
}