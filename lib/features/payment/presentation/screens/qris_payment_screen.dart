import 'dart:async';
import 'package:flutter/material.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  // Countdown timer 14 menit 59 detik (899 detik)
  int _remainingSeconds = 14 * 60 + 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // 1. Top App Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF111827),
                          size: 22,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Pembayaran QRIS',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF374151),
                          size: 22,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Scan QRIS menggunakan m-Banking atau e-Wallet (GoPay, OVO, DANA, ShopeePay).',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 2. Konten Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      children: [
                        // Banner Countdown Merah
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: Colors.white,
                                size: 17,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selesaikan pembayaran dalam ${_formatDuration(_remainingSeconds)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Card Utama QRIS
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Baris Total Pembayaran & No. Pesanan
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Pembayaran',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Rp 68.000',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: Color(0xFF0057D9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'No. Pesanan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        '#GK-882190',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 14),

                              // Baris Logo QRIS Standar Nasional & GPN
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'QRIS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Standar Nasional',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF4B5563),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.contactless_outlined,
                                    size: 18,
                                    color: Color(0xFF0369A1),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'GPN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Nama Merchant & NMID
                              const Text(
                                'GalonKu Kebayoran',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'NMID: ID2023948192841',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Kotak Bingkai QR Code Custom Persis Figma
                              Container(
                                width: 224,
                                height: 224,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _GalonKuQrisPainter(),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Tombol Unduh QR Code
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('QR Code berhasil disimpan ke galeri!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 18,
                                    color: Color(0xFF0F172A),
                                  ),
                                  label: const Text(
                                    'Unduh QR Code',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0057D9),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE8EDFF),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Teks Instruksi Scan
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Buka aplikasi mobile banking atau e-wallet pilihan Anda, lalu scan kode QR di atas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badge Gembok Pembayaran Aman
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: Color(0xFF15803D),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pembayaran Aman & Terverifikasi Otomatis',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Action Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mengecek status pembayaran #GK-882190...'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          label: const Text(
                            'Cek Status Pembayaran',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0057D9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Membuka pilihan metode pembayaran lain...'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ganti Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Color(0xFF374151),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar QR Code dengan 3 kotak finder biru & ikon tetesan air di tengah
class _GalonKuQrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / 21;
    final Paint darkPaint = Paint()..color = const Color(0xFF0F172A);
    final Paint bluePaint = Paint()..color = const Color(0xFF0057D9);
    final Paint whitePaint = Paint()..color = Colors.white;

    // 1. Gambar modul-modul data QR di luar area finder & logo tengah
    final List<String> matrix = [
      '000000001011000000000',
      '000000000101100000000',
      '000000001110100000000',
      '000000001001000000000',
      '000000000110100000000',
      '000000001101000000000',
      '000000001010100000000',
      '000000000101000000000',
      '101101011000101101011',
      '010110100000010110101',
      '111010110000011011010',
      '001101000000001010111',
      '110101101011011101001',
      '000000001010110010110',
      '000000000110101101001',
      '000000001101001011101',
      '000000001011010100110',
      '000000000100111011001',
      '000000001110100101101',
      '000000001001011010010',
      '000000000110101101111',
    ];

    for (int row = 0; row < 21; row++) {
      for (int col = 0; col < 21; col++) {
        // Lewati area 3 kotak sudut & kotak logo tengah
        if ((row < 8 && col < 8) ||
            (row < 8 && col > 12) ||
            (row > 12 && col < 8) ||
            (row >= 8 && row <= 12 && col >= 8 && col <= 12)) {
          continue;
        }
        if (matrix[row][col] == '1') {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                col * cell + 0.8,
                row * cell + 0.8,
                cell - 1.6,
                cell - 1.6,
              ),
              const Radius.circular(2.2),
            ),
            darkPaint,
          );
        }
      }
    }

    // 2. Helper untuk menggambar 3 kotak sudut (Finder Patterns)
    void drawFinder(double x, double y) {
      // Bingkai luar biru gelap
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 7 * cell, 7 * cell),
          const Radius.circular(10),
        ),
        darkPaint,
      );
      // Lapisan putih tengah
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + cell, y + cell, 5 * cell, 5 * cell),
          const Radius.circular(6),
        ),
        whitePaint,
      );
      // Kotak inti biru GalonKu
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell),
          const Radius.circular(4),
        ),
        bluePaint,
      );
    }

    drawFinder(0, 0); // Kiri Atas
    drawFinder(14 * cell, 0); // Kanan Atas
    drawFinder(0, 14 * cell); // Kiri Bawah

    // 3. Kotak Ikon Tetesan Air Biru di Tengah QR
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double boxSize = 3.4 * cell;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: boxSize,
          height: boxSize,
        ),
        const Radius.circular(9),
      ),
      bluePaint,
    );

    // Gambar tetesan air putih/biru muda di dalam kotak tengah
    final Path dropPath = Path();
    final double dropTop = centerY - boxSize * 0.28;
    final double dropBottom = centerY + boxSize * 0.28;
    final double dropWidth = boxSize * 0.22;

    dropPath.moveTo(centerX, dropTop);
    dropPath.cubicTo(
      centerX + dropWidth * 1.4,
      centerY,
      centerX + dropWidth,
      dropBottom,
      centerX,
      dropBottom,
    );
    dropPath.cubicTo(
      centerX - dropWidth,
      dropBottom,
      centerX - dropWidth * 1.4,
      centerY,
      centerX,
      dropTop,
    );
    dropPath.close();

    canvas.drawPath(
      dropPath,
      Paint()..color = const Color(0xFF93C5FD),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}