import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedTab = 'Semua';
  int _selectedNavIndex = 2;

  final List _orders = [
    {
      'date': '10 Okt 2023',
      'orderId': '#GK-882190',
      'status': 'SEDANG DIANTAR',
      'category': 'Dalam Proses',
      'isOngoing': true,
      'items': [
        {
          'image': 'assets/aqua.png',
          'name': 'Aqua Galon Isi Ulang 19L',
          'desc': 'Isi ulang higienis sterilisasi',
          'price': 'Rp 40.000',
          'qty': '2x',
        },
        {
          'image': 'assets/leminerale.png',
          'name': 'Le Minerale 15L',
          'desc': 'Galon sekali pakai higienis',
          'price': 'Rp 28.000',
          'qty': '1x',
        },
      ],
      'totalLabel': 'Total Pesanan (3 Galon)',
      'totalPrice': 'Rp 68.000',
    },
    {
      'date': '03 Okt 2023',
      'orderId': '#GK-871032',
      'status': 'SELESAI',
      'category': 'Selesai',
      'isOngoing': false,
      'items': [
        {
          'image': 'assets/aqua.png',
          'name': 'Aqua Galon Isi Ulang 19L',
          'desc': 'Diterima oleh Pak Rahmat (Satpam)',
          'price': 'Rp 40.000',
          'qty': '2x',
        },
      ],
      'totalLabel': 'Total Belanja',
      'totalPrice': 'Rp 40.000',
    },
    {
      'date': '25 Sep 2023',
      'orderId': '#GK-859421',
      'status': 'SELESAI',
      'category': 'Selesai',
      'isOngoing': false,
      'items': [
        {
          'image': 'assets/leminerale.png',
          'name': 'Le Minerale 15L',
          'desc': 'Diterima langsung di depan pintu',
          'price': 'Rp 22.000',
          'qty': '1x',
        },
      ],
      'totalLabel': 'Total Belanja',
      'totalPrice': 'Rp 22.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _selectedTab == 'Semua'
        ? _orders
        : _orders.where((o) => o['category'] == _selectedTab).toList();

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

                // 2. Filter Tabs
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFAFBFF),
                  padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Semua',
                        'Dalam Proses',
                        'Selesai',
                        'Dibatalkan',
                      ].map((tab) {
                        final isSelected = _selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0057D9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0057D9)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 13,
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
                ),

                // 3. Sub-header Riwayat & Status Pengiriman
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Color(0xFF0057D9),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Riwayat & Status Pengiriman',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filteredOrders.length} Pesanan Terakhir',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Daftar Kartu Pesanan
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada pesanan pada kategori ini',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildOrderCard(filteredOrders[index]);
                          },
                        ),
                ),

                // 5. Bottom Navigation Bar
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

  Widget _buildOrderCard(Map order) {
    final bool isOngoing = order['isOngoing'];
    final List items = order['items'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        order['date'],
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['orderId'],
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOngoing
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOngoing
                          ? Icons.circle
                          : Icons.check_circle_outline_rounded,
                      size: isOngoing ? 8 : 13,
                      color: isOngoing
                          ? const Color(0xFF0057D9)
                          : const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order['status'],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: isOngoing
                            ? const Color(0xFF0057D9)
                            : const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(items.length, (idx) {
                final item = items[idx];
                return Padding(
                  padding: EdgeInsets.only(bottom: idx == items.length - 1 ? 0 : 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['desc'],
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['price'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['qty'],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0057D9),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          if (isOngoing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['totalLabel'],
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['totalPrice'],
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0057D9),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: Color(0xFF15803D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Bebas Ongkir',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.receipt_outlined,
                        size: 17,
                        color: Color(0xFF1F2937),
                      ),
                      label: const Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.two_wheeler_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Lacak Kurir',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0057D9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['totalLabel'],
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['totalPrice'],
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pesan Lagi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057D9),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}