import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/mitra_theme.dart';

import '../../core/api_client.dart';
import '../../core/session_manager.dart';

class UbahDataMitraScreen extends StatefulWidget {
  const UbahDataMitraScreen({super.key});

  @override
  State<UbahDataMitraScreen> createState() => _UbahDataMitraScreenState();
}

class _UbahDataMitraScreenState extends State<UbahDataMitraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await SessionManager.currentMitraToken();
      if (token == null)
        throw const ApiException(
          'Sesi mitra tidak ditemukan. Silakan masuk kembali.',
        );
      final result = await MitraApi.profile(token);
      final profile = result['mitra'];
      if (profile is! Map<String, dynamic>)
        throw const ApiException('Data profil mitra tidak valid.');
      _name.text = (profile['nama_lengkap_admin'] as String?) ?? '';
      _username.text = (profile['username'] as String?) ?? '';
      _phone.text = (profile['no_telephone'] as String?) ?? '';
      _email.text = (profile['email'] as String?) ?? '';
    } catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final token = await SessionManager.currentMitraToken();
      if (token == null)
        throw const ApiException(
          'Sesi mitra tidak ditemukan. Silakan masuk kembali.',
        );
      await MitraApi.updateProfile(token, {
        'nama_lengkap_admin': _name.text.trim(),
        'username': _username.text.trim(),
        'no_telephone': _phone.text.trim(),
      });
      if (!mounted) return;
      _showMessage('Profil mitra berhasil diperbarui.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: mitraTheme(Theme.of(context)),
      child: Scaffold(
        backgroundColor: MitraPalette.canvas,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Edit Profil Mitra',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Informasi akun',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Perubahan disimpan langsung ke profil mitra di LokaTrip.',
                        style: GoogleFonts.manrope(color: MitraPalette.muted),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _field(_name, 'Nama lengkap', validator: _required),
                            const SizedBox(height: 14),
                            _field(_username, 'Username', validator: _required),
                            const SizedBox(height: 14),
                            _field(
                              _phone,
                              'Nomor telepon',
                              validator: _required,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 14),
                            _field(_email, 'Email akun', enabled: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: MitraPalette.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Wajib diisi.' : null;

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    bool enabled = true,
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    validator: validator,
    enabled: enabled,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
