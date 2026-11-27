import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_plan.dart';

class AiException implements Exception {
  final String pesan;
  const AiException(this.pesan);

  @override
  String toString() => pesan;
}

class AiService {
  final _db = Supabase.instance.client;

  // riwayat format Gemini: [{role: 'user'|'model', parts: [{text: '...'}]}]
  Future<AiPlan> tanya(
    String pesan, {
    List<Map<String, dynamic>> riwayat = const [],
    String? kota,
  }) async {
    try {
      final res = await _db.functions.invoke(
        'dynamic-service',
        body: {
          'pesan': pesan,
          'riwayat': riwayat,
          if (kota != null) 'kota': kota,
        },
      );

      final data = res.data is String ? jsonDecode(res.data) : res.data;
      if (data is Map<String, dynamic>) return AiPlan.fromJson(data);
      throw const AiException('Respons AI tidak dikenali.');
    } on AiException {
      rethrow;
    } on FunctionException catch (e) {
      switch (e.status) {
        case 401:
          throw const AiException('Silakan login dulu untuk memakai AI.');
        case 503:
          throw const AiException('AI lagi sibuk, coba lagi sebentar.');
        case 400:
          throw const AiException(
              'Pesanmu belum bisa diproses. Coba dipersingkat (maks. 500 karakter).');
        default:
          throw const AiException('AI sedang bermasalah, coba lagi nanti.');
      }
    } catch (_) {
      throw const AiException('Tidak bisa terhubung. Cek koneksi internetmu.');
    }
  }
}