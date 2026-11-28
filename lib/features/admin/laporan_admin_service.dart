import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LaporanPeriode { minggu, bulan, tahun }

class LaporanPembayaranRingkas {
  const LaporanPembayaranRingkas({
    required this.kodePesan,
    required this.metode,
    required this.jumlah,
    required this.waktu,
  });

  final String kodePesan;
  final String metode;
  final int jumlah;
  final DateTime waktu;
}

class LaporanAdminData {
  const LaporanAdminData({
    required this.start,
    required this.end,
    required this.totalMitra,
    required this.wisataAktif,
    required this.totalDokumen,
    required this.izinAktif,
    required this.izinMenunggu,
    required this.izinHampirHabis,
    required this.izinKedaluwarsa,
    required this.pesananLunas,
    required this.tiketTerjual,
    required this.nilaiTransaksi,
    required this.keuntungan,
    required this.keuntunganSebelumnya,
    required this.chartLabels,
    required this.chartOrders,
    required this.pembayaranTerbaru,
    required this.midtransChecked,
    required this.midtransSettled,
    required this.midtransSyncWarning,
    required this.midtransLatestStatus,
    required this.midtransLatestOrderCode,
  });

  final DateTime start, end;
  final int totalMitra, wisataAktif, totalDokumen, izinAktif, izinMenunggu;
  final int izinHampirHabis, izinKedaluwarsa, pesananLunas;
  final int tiketTerjual, nilaiTransaksi, keuntungan;
  final int keuntunganSebelumnya;
  final List<String> chartLabels;
  final List<double> chartOrders;
  final List<LaporanPembayaranRingkas> pembayaranTerbaru;
  final int midtransChecked, midtransSettled;
  final String? midtransSyncWarning;
  final String? midtransLatestStatus, midtransLatestOrderCode;

  String get range {
    final first = _date(start);
    final last = _date(end.subtract(const Duration(days: 1)));
    if (start.year == end.subtract(const Duration(days: 1)).year &&
        start.month == end.subtract(const Duration(days: 1)).month) {
      return '${start.day}–${end.subtract(const Duration(days: 1)).day} ${_month(start.month)} ${start.year}';
    }
    return '$first – $last';
  }

  static String _date(DateTime date) =>
      '${date.day} ${_month(date.month)} ${date.year}';
  static String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];

  static Future<List<Map<String, dynamic>>> _allRows(
    String table,
    String columns,
    String orderColumn,
  ) async {
    final client = Supabase.instance.client;
    const pageSize = 1000;
    final rows = <Map<String, dynamic>>[];
    for (var start = 0; ; start += pageSize) {
      final page = await client
          .from(table)
          .select(columns)
          .order(orderColumn)
          .range(start, start + pageSize - 1);
      final batch = (page as List).whereType<Map<String, dynamic>>();
      rows.addAll(batch);
      if (batch.length < pageSize) break;
    }
    return rows;
  }

  static Future<List<Map<String, dynamic>>> _paymentRows(
    DateTime start,
    DateTime end,
  ) async {
    final client = Supabase.instance.client;
    const pageSize = 1000;
    final rows = <Map<String, dynamic>>[];
    for (var offset = 0; ; offset += pageSize) {
      final page = await client
          .from('pembayaran')
          .select(
            'id_pemesanan, status_bayar, metode_bayar, jumlah_bayar, waktu_bayar, pemesanan(kode_pesan, biaya_layanan, detail_pemesanan(jumlah))',
          )
          .gte('waktu_bayar', start.toUtc().toIso8601String())
          .lt('waktu_bayar', end.toUtc().toIso8601String())
          .order('waktu_bayar')
          .order('id_pemesanan')
          .range(offset, offset + pageSize - 1);
      final batch = (page as List).whereType<Map<String, dynamic>>();
      rows.addAll(batch);
      if (batch.length < pageSize) break;
    }
    return rows;
  }

  static Future<LaporanAdminData> load(
    LaporanPeriode period, {
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    late DateTime start, end, comparisonStart, comparisonEnd;
    switch (period) {
      case LaporanPeriode.minggu:
        start = midnight.subtract(Duration(days: midnight.weekday - 1));
        end = start.add(const Duration(days: 7));
        comparisonStart = start.subtract(const Duration(days: 7));
        comparisonEnd = start;
        break;
      case LaporanPeriode.bulan:
        start = DateTime(today.year, today.month);
        end = DateTime(today.year, today.month + 1);
        comparisonStart = DateTime(today.year, today.month - 1);
        comparisonEnd = start;
        break;
      case LaporanPeriode.tahun:
        start = DateTime(today.year, 1);
        end = DateTime(today.year + 1, 1);
        comparisonStart = DateTime(today.year - 1, 1);
        comparisonEnd = start;
        break;
    }

    final client = Supabase.instance.client;
    var midtransChecked = 0;
    var midtransSettled = 0;
    String? midtransSyncWarning;
    String? midtransLatestStatus;
    String? midtransLatestOrderCode;
    try {
      final response = await client.functions.invoke(
        'midtrans-payment',
        body: {'action': 'admin_reconcile'},
      );
      if (response.data is Map) {
        midtransChecked = (response.data['checked'] as num?)?.toInt() ?? 0;
        midtransSettled = (response.data['settled'] as num?)?.toInt() ?? 0;
        midtransLatestStatus = response.data['latest_status'] as String?;
        midtransLatestOrderCode = response.data['latest_order_code'] as String?;
      }
    } catch (error) {
      debugPrint('Midtrans admin reconciliation unavailable: $error');
      midtransSyncWarning =
          'Sinkronisasi Midtrans gagal. Periksa deployment Edge Function.';
    }

    final results = await Future.wait([
      _paymentRows(comparisonStart, end),
      _allRows('admin_wisata', 'id_mitra', 'id_mitra'),
      _allRows('wisata', 'id_wisata, status_approve', 'id_wisata'),
      _allRows(
        'dokumen',
        'id_dokumen, status_approve, masa_berlaku_sampai',
        'id_dokumen',
      ),
    ]);
    final orders = results[0];
    final docs = results[3];
    bool paid(Map<String, dynamic> payment) => const {
      'berhasil',
      'dibayar',
      'lunas',
      'paid',
    }.contains('${payment['status_bayar']}'.toLowerCase());

    DateTime? paymentDate(Map<String, dynamic> row) =>
        DateTime.tryParse('${row['waktu_bayar'] ?? ''}')?.toLocal();
    final periodOrders = orders.where((row) {
      final date = paymentDate(row);
      return date != null && !date.isBefore(start) && date.isBefore(end);
    }).toList();
    final previousOrders = orders.where((row) {
      final date = paymentDate(row);
      return date != null &&
          !date.isBefore(comparisonStart) &&
          date.isBefore(comparisonEnd);
    }).toList();
    int sumPayments(List<Map<String, dynamic>> rows) => rows
        .where(paid)
        .fold(
          0,
          (total, row) => total + ((row['jumlah_bayar'] as num?)?.round() ?? 0),
        );
    int sumProfit(List<Map<String, dynamic>> rows) =>
        rows.where(paid).fold(0, (total, row) {
          final order = row['pemesanan'];
          final orderRow = order is List
              ? (order.isEmpty ? null : order.first)
              : order;
          if (orderRow is! Map) return total;
          return total + ((orderRow['biaya_layanan'] as num?)?.round() ?? 0);
        });
    int tickets(List<Map<String, dynamic>> rows) =>
        rows.where(paid).fold(0, (total, row) {
          final order = row['pemesanan'];
          final orderRow = order is List
              ? (order.isEmpty ? null : order.first)
              : order;
          if (orderRow is! Map) return total;
          final details = orderRow['detail_pemesanan'];
          if (details is! List) return total;
          return total +
              details.whereType<Map>().fold<int>(
                0,
                (subtotal, detail) =>
                    subtotal + ((detail['jumlah'] as num?)?.toInt() ?? 0),
              );
        });
    List<int> chartBuckets(
      List<Map<String, dynamic>> source,
      int count,
      LaporanPeriode kind,
    ) {
      final result = List<int>.filled(count, 0);
      for (final row in source) {
        final date = paymentDate(row);
        if (date == null || !paid(row)) continue;
        final index = switch (kind) {
          LaporanPeriode.minggu => date.weekday - 1,
          LaporanPeriode.bulan => (date.day - 1) ~/ 7,
          LaporanPeriode.tahun => date.month - 1,
        };
        if (index >= 0 && index < count) result[index]++;
      }
      return result;
    }

    final buckets = switch (period) {
      LaporanPeriode.minggu => 7,
      LaporanPeriode.bulan => 5,
      LaporanPeriode.tahun => 12,
    };
    final labels = switch (period) {
      LaporanPeriode.minggu => const [
        'Sen',
        'Sel',
        'Rab',
        'Kam',
        'Jum',
        'Sab',
        'Min',
      ],
      LaporanPeriode.bulan => const [
        'Pekan 1',
        'Pekan 2',
        'Pekan 3',
        'Pekan 4',
        'Pekan 5',
      ],
      LaporanPeriode.tahun => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ],
    };
    final latestPayments = periodOrders.where(paid).toList()
      ..sort((a, b) => paymentDate(b)!.compareTo(paymentDate(a)!));
    final paymentRecords = latestPayments
        .take(10)
        .map((payment) {
          final order = payment['pemesanan'];
          final orderRow = order is List
              ? (order.isEmpty ? null : order.first)
              : order;
          final date = paymentDate(payment)!;
          return LaporanPembayaranRingkas(
            kodePesan: orderRow is Map && orderRow['kode_pesan'] is String
                ? orderRow['kode_pesan'] as String
                : 'Pesanan #${payment['id_pemesanan']}',
            metode: '${payment['metode_bayar'] ?? 'Pembayaran'}'.replaceAll(
              '_',
              ' ',
            ),
            jumlah: (payment['jumlah_bayar'] as num?)?.round() ?? 0,
            waktu: date,
          );
        })
        .toList(growable: false);
    final todayDate = DateTime(today.year, today.month, today.day);
    final docsApproved = docs
        .where((row) => row['status_approve'] == 'Y')
        .toList();
    final wisata = results[2];
    return LaporanAdminData(
      start: start,
      end: end,
      totalMitra: results[1].length,
      wisataAktif: wisata.where((row) => row['status_approve'] == 'Y').length,
      totalDokumen: docs.length,
      izinAktif: docsApproved.where((row) {
        final expiry = DateTime.tryParse('${row['masa_berlaku_sampai'] ?? ''}');
        return expiry == null || !expiry.isBefore(todayDate);
      }).length,
      izinMenunggu: docs.where((row) => row['status_approve'] == 'N').length,
      izinHampirHabis: docsApproved.where((row) {
        final expiry = DateTime.tryParse('${row['masa_berlaku_sampai'] ?? ''}');
        return expiry != null &&
            !expiry.isBefore(todayDate) &&
            expiry.isBefore(todayDate.add(const Duration(days: 31)));
      }).length,
      izinKedaluwarsa: docsApproved.where((row) {
        final expiry = DateTime.tryParse('${row['masa_berlaku_sampai'] ?? ''}');
        return expiry != null && expiry.isBefore(todayDate);
      }).length,
      pesananLunas: periodOrders.where(paid).length,
      tiketTerjual: tickets(periodOrders),
      nilaiTransaksi: sumPayments(periodOrders),
      keuntungan: sumProfit(periodOrders),
      keuntunganSebelumnya: sumProfit(previousOrders),
      chartLabels: labels,
      chartOrders: chartBuckets(
        periodOrders,
        buckets,
        period,
      ).map((value) => value.toDouble()).toList(),
      pembayaranTerbaru: paymentRecords,
      midtransChecked: midtransChecked,
      midtransSettled: midtransSettled,
      midtransSyncWarning: midtransSyncWarning,
      midtransLatestStatus: midtransLatestStatus,
      midtransLatestOrderCode: midtransLatestOrderCode,
    );
  }
}
