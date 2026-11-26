import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/api/product_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color primaryBlue = Color(0xFF0756C9);
  static const Color darkText = Color(0xFF172337);
  static const Color secondaryText = Color(0xFF596273);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isServerOnline = false;
  bool _isCheckingServer = true;

  final List _slides = [
    {
      'badgeTop': '15–30 Menit',
      'badgeTopIcon': Icons.bolt,
      'badgeBottom': '100% Higienis',
      'badgeBottomIcon': Icons.verified_user_outlined,
      'title': 'Air Galon Bersih Langsung\nSampai Pintu',
      'subtitle':
          'Layanan antar galon resmi, higienis, dan terjadwal langsung ke depan pintu kamar atau rumah Anda.',
    },
    {
      'badgeTop': 'Tukar & Baru',
      'badgeTopIcon': Icons.autorenew,
      'badgeBottom': 'Segel Ganda',
      'badgeBottomIcon': Icons.shield_outlined,
      'title': 'Pilih Merek Favorit\nDalam Sekali Klik',
      'subtitle':
          'Tersedia Aqua, Le Minerale, Cleo, Vit, dan Amidis dengan jaminan sterilisasi depot resmi.',
    },
    {
      'badgeTop': 'Live GPS',
      'badgeTopIcon': Icons.my_location,
      'badgeBottom': 'Estimasi Akurat',
      'badgeBottomIcon': Icons.timer_outlined,
      'title': 'Pantau Posisi Kurir\nSecara Real-Time',
      'subtitle':
          'Ketahui jarak dan perkiraan waktu tiba kurir secara langsung dari layar ponsel Anda.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    setState(() => _isCheckingServer = true);
    final isOnline = await ProductService.checkServerStatus();
    if (!mounted) return;
    setState(() {
      _isServerOnline = isOnline;
      _isCheckingServer = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSlide = _slides[_currentPage] as Map;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/kurir_galon.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.water_drop,
                        color: primaryBlue,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GalonKu',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _checkBackendConnection,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _isServerOnline
                            ? const Color(0xFFE6F6EC)
                            : const Color(0xFFE9EEF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: _isCheckingServer
                                ? Colors.orange
                                : (_isServerOnline
                                    ? const Color(0xFF07863D)
                                    : secondaryText),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isCheckingServer
                                ? 'Mengecek...'
                                : (_isServerOnline
                                    ? 'Server Online'
                                    : 'Mode Offline'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isServerOnline
                                  ? const Color(0xFF07863D)
                                  : secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index] as Map;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 205,
                          height: 205,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF3FF),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/kurir_galon.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.delivery_dining,
                                  size: 85,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  slide['badgeTopIcon'] as IconData,
                                  size: 13,
                                  color: const Color(0xFF0095B6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  slide['badgeTop'] as String,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 22,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  slide['badgeBottomIcon'] as IconData,
                                  size: 13,
                                  color: const Color(0xFF07863D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  slide['badgeBottom'] as String,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: isActive ? 22 : 6,
                    decoration: BoxDecoration(
                      color: isActive ? primaryBlue : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              Text(
                activeSlide['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                activeSlide['subtitle'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _buildFeatureBox(Icons.local_shipping_outlined, 'Antar Cepat'),
                  const SizedBox(width: 10),
                  _buildFeatureBox(Icons.clean_hands_outlined, 'Tutup Segel'),
                  const SizedBox(width: 10),
                  _buildFeatureBox(Icons.stairs_outlined, 'Naik Lantai'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mulai Sekarang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(fontSize: 12, color: secondaryText),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBox(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}