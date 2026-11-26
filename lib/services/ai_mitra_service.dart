import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/session_manager.dart';

class AiMitraException implements Exception {
  final String pesan;
  const AiMitraException(this.pesan);

  @override
  String toString() => pesan;
}

class AiMitraService {
  final _db = Supabase.instance.client;

  Future<String> buatDeskripsi(Map<String, String> data) async {
    final token = await SessionManager.currentMitraToken();
    if (token == null || token.isEmpty) {
      throw const AiMitraException('Sesi mitra berakhir. Silakan login kembali.');
    }

    try {
      final response = await _db.functions.invoke(
        'mitra-ai-description',
        body: {
          'mitra_session': token,
          ...data,
        },
      );
      final payload = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (payload is Map && payload['deskripsi'] is String) {
        final result = (payload['deskripsi'] as String).trim();
        if (result.isNotEmpty) return result;
      }
      if (payload is Map && payload['error'] is String) {
        throw AiMitraException(payload['error'] as String);
      }
      throw const AiMitraException('AI belum menghasilkan deskripsi.');
    } on AiMitraException {
      rethrow;
    } on FunctionException catch (error) {
      if (error.status == 401) {
        throw const AiMitraException('Sesi mitra berakhir. Silakan login kembali.');
      }
      if (error.status == 503) {
        throw const AiMitraException('AI sedang sibuk. Coba lagi sebentar.');
      }
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw AiMitraException(details['error'] as String);
      }
      throw const AiMitraException('AI belum bisa membuat deskripsi. Coba lagi.');
    } catch (_) {
      throw const AiMitraException('Tidak bisa terhubung ke layanan AI.');
    }
  }
}