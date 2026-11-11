import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UbahDataMitraScreen extends StatefulWidget {
  const UbahDataMitraScreen({super.key});

  @override
  State<UbahDataMitraScreen> createState() => _UbahDataMitraScreenState();
}

class _UbahDataMitraScreenState extends State<UbahDataMitraScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers Data Badan Usaha
  String _bentukEntitas = 'Commanditaire Vennootschap (CV)';
  late final TextEditingController _namaBadanUsahaController;
  late final TextEditingController _nibController;
  late final TextEditingController _namaPublikController;
  String _namaFileDokumen = 'NIB_CV_Pesona_2024.pdf';
  String _ukuranFileDokumen = '3.4 MB • Terverifikasi Otomatis';

  // Controllers PIC
  late final TextEditingController _picNamaController;
  late final TextEditingController _picJabatanController;
  late final TextEditingController _picNikController;
  late final TextEditingController _picWaController;
  late final TextEditingController _picEmailController;

  // Controllers Alamat & Basecamp
  late final TextEditingController _alamatController;
  late final TextEditingController _gpsController;

  @override
  void initState() {
    super.initState();
    _namaBadanUsahaController =
        TextEditingController(text: 'CV Pesona Nusantara');
    _nibController = TextEditingController(text: '8220168921827');
    _namaPublikController =
        TextEditingController(text: 'Pengelola Wisata Bromo Adventure');

    _picNamaController = TextEditingController(text: 'Hendra Wijaya');
    _picJabatanController = TextEditingController(text: 'Direktur Operasional');
    _picNikController = TextEditingController(text: '3513082901840003');
    _picWaController = TextEditingController(text: '+62 811-2345-6789');
    _picEmailController =
        TextEditingController(text: 'hendra@pesonanusantara.id');

    _alamatController = TextEditingController(
      text:
          'Jl. Raya Bromo No. 45, Sukapura, Kab. Probolinggo, Jawa Timur 67254',
    );
    _gpsController = TextEditingController(
      text: '-7.923412, 112.951239 (Pintu Masuk Sukapura)',
    );
  }

  @override
  void dispose() {
    _namaBadanUsahaController.dispose();
    _nibController.dispose();
    _namaPublikController.dispose();
    _picNamaController.dispose();
    _picJabatanController.dispose();
    _picNikController.dispose();
    _picWaController.dispose();
    _picEmailController.dispose();
    _alamatController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  Future<void> _pickNewDocument() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Dokumen Legalitas',
            extensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
        ],
      );
      if (file == null) return;
      final sizeInMb = ((await file.length()) / (1024 * 1024)).toStringAsFixed(
        1,
      );
      if (!mounted) return;
      setState(() {
        _namaFileDokumen = file.name;
        _ukuranFileDokumen = '$sizeInMb MB • Menunggu Verifikasi';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dokumen ${file.name} berhasil dipilih.')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih file dokumen baru.')),
      );
    }
  }

  void _detectGps() {
    setState(() {
      _gpsController.text = '-7.923412, 112.951239 (Pintu Masuk Sukapura)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi GPS berhasil diperbarui secara presisi.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perubahan data berhasil disimpan dan dikirim untuk validasi!',
          ),
          backgroundColor: Color(0xFF059669),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Pengajuan',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Informasi Perubahan Data',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  content: Text(
                    'Data legalitas yang diubah akan melalui verifikasi tim kepatuhan LokaTrip dalam 1x24 jam.',
                    style: GoogleFonts.manrope(fontSize: 12),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Mengerti'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info_outline, color: Color(0xFF0F172A)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0F47D1),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSubHeader(),
                    const SizedBox(height: 14),
                    _buildPeriodicValidationNotice(),
                    const SizedBox(height: 16),
                    _buildDataBadanUsahaCard(),
                    const SizedBox(height: 16),
                    _buildDataPicCard(),
                    const SizedBox(height: 16),
                    _buildAlamatBasecampCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildSecurityFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Subheader: MITRA ID & Terverifikasi NIB
  Widget _buildSubHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'MITRA ID: MIT-00128',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF334155),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 12, color: Color(0xFF15803D)),
              const SizedBox(width: 4),
              Text(
                'Terverifikasi NIB',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Notice: Validasi Legalitas Berkala
  Widget _buildPeriodicValidationNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: Color(0xFF1748D1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validasi Legalitas Berkala',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Perubahan nama entitas bisnis atau NIB membutuhkan verifikasi audit dalam 1x24 jam oleh tim kepatuhan LokaTrip.',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 1: Data Badan Usaha
  Widget _buildDataBadanUsahaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      size: 18,
                      color: Color(0xFF1748D1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Data Badan Usaha',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kemenkumham & OSS',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1748D1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Field 1: Bentuk Entitas Usaha *
          _fieldLabel('Bentuk Entitas Usaha', required: true),
          DropdownButtonFormField<String>(
            initialValue: _bentukEntitas,
            decoration: _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF475569),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Commanditaire Vennootschap (CV)',
                child: Text('Commanditaire Vennootschap (CV)'),
              ),
              DropdownMenuItem(
                value: 'Perseroan Terbatas (PT)',
                child: Text('Perseroan Terbatas (PT)'),
              ),
              DropdownMenuItem(
                value: 'Koperasi Pariwisata',
                child: Text('Koperasi Pariwisata'),
              ),
              DropdownMenuItem(
                value: 'Perorangan / Usaha Dagang (UD)',
                child: Text('Perorangan / Usaha Dagang (UD)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _bentukEntitas = val);
            },
          ),
          const SizedBox(height: 14),

          // Field 2: Nama Resmi Badan Usaha *
          _fieldLabel('Nama Resmi Badan Usaha', required: true),
          TextFormField(
            controller: _namaBadanUsahaController,
            decoration: _inputDecoration(
              suffixIcon: const Icon(
                Icons.verified_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 3: Nomor Induk Berusaha (NIB) * with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('Nomor Induk Berusaha (NIB)', required: true),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Terdaftar OSS RBA',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _nibController,
            decoration: _inputDecoration(),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 4: Nama Publik / Merek Wisata *
          _fieldLabel('Nama Publik / Merek Wisata', required: true),
          TextFormField(
            controller: _namaPublikController,
            decoration: _inputDecoration(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 5: Dokumen Bukti Legalitas (NIB / SIUP)
          _fieldLabel('Dokumen Bukti Legalitas (NIB / SIUP)'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _namaFileDokumen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _ukuranFileDokumen,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2FF),
                    foregroundColor: const Color(0xFF1748D1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _pickNewDocument,
                  child: Text(
                    'Ganti File',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Data PIC Penanggung Jawab
  Widget _buildDataPicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: Color(0xFF1748D1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Data PIC Penanggung\nJawab',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                'Pemberitahuan\nResmi',
                textAlign: TextAlign.right,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Field 1: Nama Lengkap (Sesuai KTP) *
          _fieldLabel('Nama Lengkap (Sesuai KTP)', required: true),
          TextFormField(
            controller: _picNamaController,
            decoration: _inputDecoration(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 2: Jabatan Manajerial *
          _fieldLabel('Jabatan Manajerial', required: true),
          TextFormField(
            controller: _picJabatanController,
            decoration: _inputDecoration(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 3: Nomor Induk Kependudukan (NIK) *
          _fieldLabel('Nomor Induk Kependudukan (NIK)', required: true),
          TextFormField(
            controller: _picNikController,
            decoration: _inputDecoration(),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 4: WhatsApp Operasional * with 2FA badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('WhatsApp Operasional', required: true),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Terhubung 2FA',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _picWaController,
            decoration: _inputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: Color(0xFF1748D1),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _picWaController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor WhatsApp berhasil disalin.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 5: Email Perusahaan *
          _fieldLabel('Email Perusahaan', required: true),
          TextFormField(
            controller: _picEmailController,
            decoration: _inputDecoration(),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  // Card 3: Alamat Kantor & Basecamp
  Widget _buildAlamatBasecampCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF1748D1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Alamat Kantor &\nBasecamp',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                'Titik Kumpul\nWisatawan',
                textAlign: TextAlign.right,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Field 1: Alamat Lengkap Kantor / Pos Tiket *
          _fieldLabel('Alamat Lengkap Kantor / Pos Tiket', required: true),
          TextFormField(
            controller: _alamatController,
            maxLines: 3,
            decoration: _inputDecoration(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Field 2: Titik Presisi Peta GPS with action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('Titik Presisi Peta GPS (Latitude, Longitude)'),
              InkWell(
                onTap: _detectGps,
                child: Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      size: 13,
                      color: Color(0xFF1748D1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deteksi GPS',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1748D1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _gpsController,
            style: GoogleFonts.sourceCodePro(
              fontSize: 12,
              color: const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 14),

          // Map Graphic Preview Container
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              gradient: const LinearGradient(
                colors: [Color(0xFFBAE6FD), Color(0xFFD1FAE5), Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Topography contour decorative lines
                CustomPaint(
                  size: const Size(double.infinity, 130),
                  painter: _MapContourPainter(),
                ),
                // Center Pin Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sukapura Basecamp Hub',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: Color(0xFF1748D1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Buttons: Simpan & Batal
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F47D1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveChanges,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(
            'Simpan Perubahan Data',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEEF2FF),
            foregroundColor: const Color(0xFF1748D1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFDBEAFE)),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal & Kembali',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // Security Note
  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 12, color: Color(0xFF64748B)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'Data mitra dienkripsi 256-bit standar ISO/IEC 27001 LokaTrip',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1748D1), width: 1.5),
      ),
    );
  }
}

// Decorative Map Painter for the background of the map container
class _MapContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.8,
        size.width,
        size.height * 0.6,
      );
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.9,
        size.width * 0.7,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.1,
        size.width,
        size.height * 0.4,
      );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
