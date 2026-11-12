import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'Semua';
  int _selectedNavIndex = 0;
  int _cartCount = 2;
  final TextEditingController _aiChatController = TextEditingController();
  final Set _favoriteIndices = {};

  final List _products = [
    {
      'badge': '• Tersedia',
      'badgeBg': const Color(0xFFDCFCE7),
      'badgeText': const Color(0xFF15803D),
      'size': '19L',
      'image': 'assets/aqua.png',
      'title': 'Aqua Galon 19L',
      'subtitle': 'Refill Air Alami',
      'price': 'Rp 20.000',
      'category': 'Isi Ulang (Refill)',
    },
    {
      'badge': 'Segel Pabrik',
      'badgeBg': const Color(0xFFDBEAFE),
      'badgeText': const Color(0xFF1D4ED8),
      'size': '15L',
      'image': 'assets/leminerale.png',
      'title': 'Le Minerale 15L',
      'subtitle': 'Galon Sekali Pakai',
      'price': 'Rp 22.000',
      'category': 'Galon Baru',
    },
    {
      'badge': 'Bebas BPA',
      'badgeBg': const Color(0xFFE0F2FE),
      'badgeText': const Color(0xFF0369A1),
      'size': '19L',
      'image': 'assets/cleo.png',
      'title': 'Amidis 19L',
      'subtitle': 'Air Murni Oksigen',
      'price': 'Rp 21.000',
      'category': 'Isi Ulang (Refill)',
    },
    {
      'badge': 'Higienis',
      'badgeBg': const Color(0xFFF1F5F9),
      'badgeText': const Color(0xFF475569),
      'size': '19L',
      'image': 'assets/vit.png',
      'title': 'Vit 19L',
      'subtitle': 'Refill Air Alami',
      'price': 'Rp 19.000',
      'category': 'Isi Ulang (Refill)',
    },
  ];

  @override
  void dispose() {
    _aiChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'Semua'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // 1. Top App Bar (Putih)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/login-galonku.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'GalonKu',
                        style: TextStyle(
                          color: Color(0xFF0057D9),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Rosi',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Color(0xFF0057D9),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Konten Utama Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Biru dengan Search & Keranjang
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0057D9),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Cari galon air mineral...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 13,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF6B7280),
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Color(0xFF0057D9),
                                        size: 21,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Keranjang berisi $_cartCount item'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (_cartCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E3A8A),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$_cartCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 3. Banner Tentang GalonKu
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.verified_outlined,
                                                size: 14,
                                                color: Color(0xFF0057D9),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'TENTANG GALONKU',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xFF0057D9),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Layanan Pesan Antar & Isi Ulang Galon Resmi',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              height: 1.25,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Langsung ke rumah Anda. Higienis, terpercaya, dan praktis tanpa repot angkat galon.',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.4,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 78,
                                      height: 78,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Image.asset(
                                        'assets/login-galonku.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 4. Card GalonKu AI
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0057D9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.smart_toy_outlined,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GalonKu AI',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                            Text(
                                              'Asisten Cerdas Pesan Air',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.auto_awesome,
                                                size: 12,
                                                color: Color(0xFF0057D9),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Pesan 24/7',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0057D9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '👋 Mau pesan galon apa hari ini? Ketik pesan atau pilih cepat di bawah:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.35,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildQuickAiChip('💧 Pesan 2 Aqua 19L'),
                                          const SizedBox(width: 6),
                                          _buildQuickAiChip('⚡ Refill Kilat'),
                                          const SizedBox(width: 6),
                                          _buildQuickAiChip('♻️ Tukar Kosong'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 38,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.chat_bubble_outline,
                                                  size: 15,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller: _aiChatController,
                                                    style: const TextStyle(fontSize: 12),
                                                    decoration: const InputDecoration(
                                                      hintText: 'Tanya AI atau ketik pesanan galonmu...',
                                                      hintStyle: TextStyle(
                                                        color: Color(0xFF9CA3AF),
                                                        fontSize: 11.5,
                                                      ),
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0057D9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.send_rounded,
                                              color: Colors.white,
                                              size: 17,
                                            ),
                                            onPressed: () {
                                              if (_aiChatController.text.isNotEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'AI memproses: "${_aiChatController.text}"',
                                                    ),
                                                  ),
                                                );
                                                _aiChatController.clear();
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 5. Kategori Air
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Kategori Air',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedCategory = 'Semua'),
                                    child: const Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0057D9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    'Semua',
                                    'Isi Ulang (Refill)',
                                    'Galon Baru',
                                    'Air Mineral',
                                  ].map((category) {
                                    final isSelected = _selectedCategory == category;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = category;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF0057D9)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF0057D9)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 6. Paling Sering Dipesan Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Paling Sering Dipesan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Siap kirim ekspres dalam 30 menit',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.bolt,
                                          size: 14,
                                          color: Color(0xFF15803D),
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Kilat',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 7. Grid Produk (2 Kolom)
                              GridView.builder(
                                itemCount: filteredProducts.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final item = filteredProducts[index];
                                  final isFav = _favoriteIndices.contains(index);
                                  return _buildProductCard(item, index, isFav);
                                },
                              ),
                              const SizedBox(height: 16),

                              // 8. Banner Pesanan Aktif
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFDBEAFE)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0057D9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_shipping_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PESANAN AKTIF #GK-8821',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0057D9),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Kurir Budi sedang menuju lokasi',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Melacak Kurir Budi (#GK-8821)...'),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF0057D9),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: const BorderSide(color: Color(0xFFDBEAFE)),
                                        ),
                                      ),
                                      child: const Text(
                                        'Lacak',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 9. Bottom Navigation Bar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _selectedNavIndex,
                    onTap: (index) => setState(() => _selectedNavIndex = index),
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    selectedItemColor: const Color(0xFF0057D9),
                    unselectedItemColor: const Color(0xFF6B7280),
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    elevation: 0,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.water_drop_outlined),
                        activeIcon: Icon(Icons.water_drop),
                        label: 'Beranda',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.storefront_outlined),
                        activeIcon: Icon(Icons.storefront),
                        label: 'Produk',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long_outlined),
                        activeIcon: Icon(Icons.receipt_long),
                        label: 'Riwayat',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profil',
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

  Widget _buildQuickAiChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _aiChatController.text = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map item, int index, bool isFav) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: item['badgeBg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['badge'],
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: item['badgeText'],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFav) {
                      _favoriteIndices.remove(index);
                    } else {
                      _favoriteIndices.add(index);
                    }
                  });
                },
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 17,
                  color: isFav ? Colors.red : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.water_drop,
                            size: 46,
                            color: Color(0xFF0057D9),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0057D9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['size'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['size'],
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item['subtitle'],
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            item['price'],
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0057D9),
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _cartCount++;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['title']} ditambahkan ke keranjang'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0057D9),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '+ Tambah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}