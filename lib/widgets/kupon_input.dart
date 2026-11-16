import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import '../core/format_rupiah.dart';
import '../models/kupon_dummy.dart';
import '../features/user/pilih_kupon_screens.dart';

class KuponInput extends StatefulWidget {
  final int subtotal;
  final Kupon? kupon;
  final ValueChanged<Kupon?> onChanged;

  const KuponInput({
    super.key,
    required this.subtotal,
    required this.kupon,
    required this.onChanged,
  });

  @override
  State<KuponInput> createState() => _KuponInputState();
}

class _KuponInputState extends State<KuponInput> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _pakai() {
    final kode = _c.text.trim();

    if (kode.isEmpty) {
      setState(() => _error = 'Masukkan kode kupon dulu');
      return;
    }

    final hasil = KuponDummy.cari(kode);

    if (hasil == null) {
      setState(() => _error = 'Kode kupon tidak ditemukan');
      return;
    }

    if (!hasil.layak(widget.subtotal)) {
      setState(() {
        _error =
            'Minimal transaksi ${formatRupiah(hasil.minTransaksi)}';
      });
      return;
    }

    setState(() => _error = null);
    _c.clear();
    widget.onChanged(hasil);
  }

  Future<void> _pilihDaftar() async {
    final hasil = await Navigator.push<KuponHasil>(
      context,
      MaterialPageRoute(
        builder: (_) => PilihKuponScreens(
          subtotal: widget.subtotal,
          terpilih: widget.kupon,
        ),
      ),
    );

    if (hasil != null) {
      setState(() => _error = null);
      widget.onChanged(hasil.kupon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kupon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: AppColor.kuning,
              ),
              const SizedBox(width: 10),
              Text(
                'Kupon & Promo',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // kupon terpasang
          if (k != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.ungu.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.ungu.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColor.ungu,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.kode,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.ungu,
                          ),
                        ),
                        Text(
                          'Hemat ${formatRupiah(k.hitung(widget.subtotal))}',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.hitam,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onChanged(null),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.kuning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ketik kode
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColor.latar,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _c,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _pakai(),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode kupon',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColor.abu,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pakai,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pakai',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // pilih dari daftar
          InkWell(
            onTap: _pilihDaftar,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.ungu.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 16,
                    color: AppColor.ungu,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      k == null
                          ? 'Pilih dari daftar kupon'
                          : 'Ganti kupon',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.ungu,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColor.ungu,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}