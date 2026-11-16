import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';

/// Satu sumber data profil untuk semua halaman user.
class ProfilStore {
  ProfilStore._();
  static final ProfilStore instance = ProfilStore._();

  final ValueNotifier<Map<String, dynamic>?> profil = ValueNotifier(null);
  bool _sedangMuat = false;

  /// Ambil dari database. Kalau sudah ada datanya, dilewati kecuali paksa = true.
  Future<void> muat({bool paksa = false}) async {
    if (_sedangMuat) return;
    if (profil.value != null && !paksa) return;
    _sedangMuat = true;
    try {
      profil.value = await ProfileService().getProfile();
    } catch (e) {
      debugPrint('ProfilStore gagal memuat: $e');
    } finally {
      _sedangMuat = false;
    }
  }

  /// Panggil saat logout supaya akun berikutnya tidak melihat data lama.
  void bersihkan() => profil.value = null;

  String get nama => (profil.value?['nama_lengkap_user'] as String?) ?? '';
  String get username => (profil.value?['username'] as String?) ?? '';
  String get email => Supabase.instance.client.auth.currentUser?.email ?? '';
  String get telepon => ProfileService.keFormatLokal(
        (profil.value?['no_telephone'] as String?) ?? '',
      );
  String? get fotoUrl => profil.value?['foto_profil'] as String?;
  int get totalPoin => (profil.value?['total_poin'] as num?)?.toInt() ?? 0;
}