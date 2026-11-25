import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const Color primaryBlue = Color(0xFF0756C9);
  static const Color cyanAccent = Color(0xFF3BD1F5);
  static const Color pageBackground = Color(0xFFF5F6FC);
  static const Color darkText = Color(0xFF172337);
  static const Color secondaryText = Color(0xFF596273);

  static const String baseUrl = 'http://localhost:5001/api';

  static const double _depotLat = -6.2350;
  static const double _depotLng = 106.7985;
  static const double _destLat = -6.2295;
  static const double _destLng = 106.8045;

  Timer? _liveTrackingTimer;
  double _mapZoomScale = 1.0;
  double _courierProgress = 0.45;

  String _orderId = 'GK-8821';
  String _productSummary = '2× Aqua Galon Isi Ulang 19L';
  String _totalPriceText = 'Rp 42.000';
  String _paymentMethod = 'QRIS';
  String _recipientAddress = 'Kost Sakura, Kamar 204 (Lantai 2)';
  String _recipientStreet = 'Jl. Melati No. 12, Senayan, Jakarta Selatan';
  String _deliveryInstruction = 'Tukar Galon Kosong Siap di Kamar';

  int _currentStatusStep = 2;
  int _selectedBottomIndex = 2;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        if (args['orderId'] != null) _orderId = args['orderId'].toString();
        if (args['productName'] != null) {
          _productSummary = args['productName'].toString();
        }
        if (args['totalPrice'] != null) {
          final rawPrice = args['totalPrice'];
          _totalPriceText =
              rawPrice is int ? _formatPrice(rawPrice) : rawPrice.toString();
        }
        if (args['paymentMethod'] != null) {
          _paymentMethod = args['paymentMethod'].toString();
        }
        if (args['address'] != null) {
          _recipientAddress = args['address'].toString();
        }
      });
    }
    _fetchTrackingFromBackend();
  }

  double get _totalRouteDistanceKm {
    const double earthRadius = 6371.0;
    final double dLat = (_destLat - _depotLat) * (math.pi / 180.0);
    final double dLng = (_destLng - _depotLng) * (math.pi / 180.0);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_depotLat * (math.pi / 180.0)) *
            math.cos(_destLat * (math.pi / 180.0)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return double.parse((earthRadius * c * 1.35).toStringAsFixed(2));
  }

  double get _remainingDistanceKm {
    final rem = _totalRouteDistanceKm * (1.0 - _courierProgress);
    return double.parse(rem.clamp(0.0, _totalRouteDistanceKm).toStringAsFixed(2));
  }

  int get _calculatedEtaMinutes {
    if (_courierProgress >= 1.0) return 0;
    final minutes = (_remainingDistanceKm / 0.12).ceil();
    return minutes.clamp(1, 25);
  }

  void _startLiveTracking() {
    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchTrackingFromBackend();
    });
  }

  Future<void> _fetchTrackingFromBackend() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/orders/$_orderId/tracking'))
          .timeout(const Duration(seconds: 3));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? decoded)
            : null;

        if (data is Map<String, dynamic>) {
          setState(() {
            if (data['progress'] != null) {
              _courierProgress =
                  (double.tryParse(data['progress'].toString()) ??
                          _courierProgress)
                      .clamp(0.0, 1.0);
            }
            if (data['statusStep'] != null) {
              _currentStatusStep =
                  int.tryParse(data['statusStep'].toString()) ??
                      _currentStatusStep;
            }
          });
          return;
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_courierProgress < 1.0) {
          _courierProgress = (_courierProgress + 0.11).clamp(0.0, 1.0);
          if (_courierProgress >= 1.0) {
            _currentStatusStep = 3;
          }
        }
      });
    }
  }

  String _formatPrice(int price) {
    final value = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCallCourierDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.phone_in_talk, color: primaryBlue),
            SizedBox(width: 8),
            Text(
              'Hubungi Kurir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Menghubungkan panggilan suara ke Pak Budi Santoso (0812-8842-9910)...',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditInstructionDialog() {
    final controller = TextEditingController(text: _deliveryInstruction);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ubah Instruksi Antar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Contoh: Titip di pos satpam / naik lantai 2...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = controller.text.trim();
              if (updated.isNotEmpty) {
                setState(() => _deliveryInstruction = updated);
                try {
                  await http.patch(
                    Uri.parse('$baseUrl/orders/$_orderId/instruction'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'instruction': updated}),
                  );
                } catch (_) {}
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnack('Instruksi pengantaran diperbarui.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/kurir_galon.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFFE7EEFF),
                child: Icon(Icons.water_drop, color: primaryBlue, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'GalonKu',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          const Text(
            'Rosi',
            style: TextStyle(
              fontSize: 12,
              color: darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 34,
                  height: 34,
                  color: const Color(0xFFE7EEFF),
                  child: const Icon(Icons.person, color: primaryBlue, size: 19),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/dashboard');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 21, color: darkText),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Tracking Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #$_orderId • Sisa $_remainingDistanceKm km',
                  style: const TextStyle(fontSize: 11, color: secondaryText),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.support_agent,
                color: primaryBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealMapCard() {
    final eta = _calculatedEtaMinutes;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 255,
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1F8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scale: _mapZoomScale,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://tile.openstreetmap.org/15/26103/16958.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEAF0F8),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        final courierPos = _calculateCourierOffset(w, h);

                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(w, h),
                              painter: _DeliveryRoutePainter(),
                            ),
                            Positioned(
                              left: w * 0.22 - 10,
                              top: h * 0.24 - 10,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.67 - 17,
                              top: h * 0.43 - 32,
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFFD92D20),
                                size: 35,
                              ),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              left: courierPos.dx - 20,
                              top: courierPos.dy - 20,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryBlue.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.water_drop,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 9, color: primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      eta == 0
                          ? 'Kurir Sudah Tiba (0 km)'
                          : 'Tiba: $eta Menit ($_remainingDistanceKm km)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed, size: 13, color: Color(0xFF07863D)),
                    SizedBox(width: 4),
                    Text(
                      'Tepat Waktu',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF07863D),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFD92D20),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _recipientAddress.split('(').first.trim(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        Text(
                          'Jarak total $_totalRouteDistanceKm km',
                          style: const TextStyle(
                            fontSize: 9,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                children: [
                  _buildMapControlButton(
                    icon: Icons.add,
                    onTap: () {
                      setState(() {
                        _mapZoomScale = (_mapZoomScale + 0.15).clamp(1.0, 1.75);
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  _buildMapControlButton(
                    icon: Icons.remove,
                    onTap: () {
                      setState(() {
                        _mapZoomScale = (_mapZoomScale - 0.15).clamp(1.0, 1.75);
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  _buildMapControlButton(
                    icon: Icons.my_location,
                    iconColor: primaryBlue,
                    onTap: () {
                      setState(() {
                        _mapZoomScale = 1.0;
                        if (_courierProgress >= 1.0) {
                          _courierProgress = 0.25;
                          _currentStatusStep = 2;
                        }
                      });
                      _fetchTrackingFromBackend();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _calculateCourierOffset(double w, double h) {
    final p0 = Offset(w * 0.22, h * 0.24);
    final p1 = Offset(w * 0.36, h * 0.34);
    final p2 = Offset(w * 0.36, h * 0.61);
    final p3 = Offset(w * 0.67, h * 0.61);
    final p4 = Offset(w * 0.67, h * 0.43);

    if (_courierProgress <= 0.25) {
      return Offset.lerp(p0, p1, _courierProgress / 0.25)!;
    } else if (_courierProgress <= 0.50) {
      return Offset.lerp(p1, p2, (_courierProgress - 0.25) / 0.25)!;
    } else if (_courierProgress <= 0.80) {
      return Offset.lerp(p2, p3, (_courierProgress - 0.50) / 0.30)!;
    } else {
      return Offset.lerp(p3, p4, (_courierProgress - 0.80) / 0.20)!;
    }
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = darkText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _buildCourierCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/kurir_galon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE7EEFF),
                        child: Icon(Icons.person, color: primaryBlue),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07863D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Pak Budi Santoso',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.verified, size: 15, color: primaryBlue),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: 3),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        Text(
                          '  •  1.4k+ antar galon',
                          style: TextStyle(fontSize: 11, color: secondaryText),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.two_wheeler, size: 14, color: primaryBlue),
                        SizedBox(width: 5),
                        Text(
                          'Honda Beat Biru • B 4821 KOP',
                          style: TextStyle(fontSize: 11, color: secondaryText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _showCallCourierDialog,
                    icon: const Icon(Icons.phone_outlined, size: 17),
                    label: const Text(
                      'Hubungi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/dashboard',
                        arguments: {
                          'openChatbot': true,
                          'courierName': 'Pak Budi Santoso',
                          'orderId': _orderId,
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 17),
                    label: const Text(
                      'Chat Kurir',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cyanAccent,
                      foregroundColor: darkText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimelineCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pengiriman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Refill Express',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTimelineStep(
            stepIndex: 0,
            icon: Icons.check,
            title: 'Pesanan Diterima',
            subtitle: 'Pembayaran $_paymentMethod terverifikasi otomatis',
            timeText: '10:15 WIB',
          ),
          _buildTimelineStep(
            stepIndex: 1,
            icon: Icons.verified_user_outlined,
            title: 'Galon Disegel Higienis',
            subtitle: 'Pembersihan tutup & uji segel selesai di Depot',
            timeText: '10:20 WIB',
          ),
          _buildTimelineStep(
            stepIndex: 2,
            icon: Icons.two_wheeler,
            title: 'Kurir Dalam Perjalanan',
            subtitle:
                'Pak Budi membawa galon ($_remainingDistanceKm km lagi)',
            timeText: '10:32 WIB',
            highlightTime: true,
          ),
          _buildTimelineStep(
            stepIndex: 3,
            icon: Icons.location_on_outlined,
            title: 'Sampai di Lokasi',
            subtitle: 'Harap siapkan galon kosong untuk ditukar',
            timeText: 'Est. 10:45 WIB',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepIndex,
    required IconData icon,
    required String title,
    required String subtitle,
    required String timeText,
    bool highlightTime = false,
    bool isLast = false,
  }) {
    final bool isCompleted = stepIndex < _currentStatusStep;
    final bool isCurrent = stepIndex == _currentStatusStep;

    Color circleBg;
    Color iconColor;
    if (isCompleted) {
      circleBg = const Color(0xFF07863D);
      iconColor = Colors.white;
    } else if (isCurrent) {
      circleBg = primaryBlue;
      iconColor = Colors.white;
    } else {
      circleBg = const Color(0xFFF0F2F8);
      iconColor = secondaryText;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? const Color(0xFF07863D)
                        : const Color(0xFFE2E6F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? primaryBlue : darkText,
                        ),
                      ),
                      if (highlightTime && isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EEFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        )
                      else
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: secondaryText,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rincian Pengiriman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Lunas',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07863D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/aqua_19l.png',
                  width: 44,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.water_drop,
                    color: primaryBlue,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _productSummary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _deliveryInstruction,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _totalPriceText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: primaryBlue,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Penerima',
                      style: TextStyle(fontSize: 10, color: secondaryText),
                    ),
                    Text(
                      _recipientAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    Text(
                      _recipientStreet,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: primaryBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 11, color: secondaryText),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.circle, size: 7, color: cyanAccent),
                  const SizedBox(width: 5),
                  Text(
                    _paymentMethod,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: InkWell(
              onTap: _showEditInstructionDialog,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline, size: 15, color: primaryBlue),
                  SizedBox(width: 5),
                  Text(
                    'Butuh bantuan atau ubah instruksi antar?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const labels = ['Beranda', 'Produk', 'Riwayat', 'Profil'];
    const icons = [
      Icons.water_drop_outlined,
      Icons.storefront_outlined,
      Icons.receipt_long_outlined,
      Icons.person_outline,
    ];
    const routes = ['/dashboard', '/products', '/history', '/profile'];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E9F0))),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final active = _selectedBottomIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedBottomIndex = index);
                Navigator.pushReplacementNamed(context, routes[index]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 20,
                    color: active ? primaryBlue : Colors.black54,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 9.5,
                      color: active ? primaryBlue : Colors.black54,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _liveTrackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildTrackingHeader(),
                    _buildRealMapCard(),
                    _buildCourierCard(),
                    _buildStatusTimelineCard(),
                    _buildOrderDetailsCard(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _DeliveryRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.36, h * 0.34)
      ..lineTo(w * 0.36, h * 0.61)
      ..lineTo(w * 0.67, h * 0.61)
      ..lineTo(w * 0.67, h * 0.43);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePaint = Paint()
      ..color = const Color(0xFF0756C9)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}