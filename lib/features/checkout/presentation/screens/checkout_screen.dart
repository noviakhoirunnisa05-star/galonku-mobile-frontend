import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  static const Color lightBgColor = Color(0xFFF4F7FF);

  String _selectedPaymentMethod = 'qris';

  final TextEditingController _noteController = TextEditingController(
    text: 'Taruh di depan pintu kamar 204 lantai 2, ketuk 2x jika galon sudah ditaruh.',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleCreateOrder() {
    const String orderId = 'GK-882199';
    const int totalAmount = 68000;

    if (_selectedPaymentMethod == 'qris') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const QrisPaymentScreen(
            orderId: orderId,
            totalAmount: 'Rp 68.000',
          ),
        ),
      );
    } else if (_selectedPaymentMethod == 'bca_va') {
      _showBcaVaPopupDialog(
        context,
        orderId: orderId,
        vaNumber: '8801081234567890',
        totalAmount: totalAmount,
      );
    } else if (_selectedPaymentMethod == 'gopay') {
      _showOrderSuccessDialog(
        context,
        title: 'Pembayaran GoPay Berhasil!',
        subtitle:
            'Saldo GoPay terpotong Rp 68.000. Kurir GalonKu sedang menyiapkan pesananmu.',
        paymentLabel: 'GoPay',
        orderId: orderId,
        totalAmount: totalAmount,
      );
    } else {
      _showOrderSuccessDialog(
        context,
        title: 'Pesanan COD Berhasil Dibuat!',
        subtitle:
            'Siapkan uang tunai pas Rp 68.000 saat kurir tiba di Kost Sakura.',
        paymentLabel: 'COD (Tunai)',
        orderId: orderId,
        totalAmount: totalAmount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/products');
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {
              _showNotification('Bantuan Checkout & Pembayaran');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent,
                    primaryBlue,
                    Colors.redAccent,
                    primaryBlue,
                  ],
                  stops: [0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddressCard(context),
                    const SizedBox(height: 16),
                    _buildOrderItemsCard(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 16),
                    _buildPaymentSummaryCard(),
                    const SizedBox(height: 16),
                    _buildGuaranteeBanner(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              _showNotification('Pilih Alamat Pengiriman Lain');
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 97, 213, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_outlined, color: primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Kost Sakura, Kamar 204',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 97, 213, 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Utama',
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Budi • 0812-3456-7890',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jl. Melati No. 12, RT 04 / RW 02, Kebayoran Baru, Jakarta Selatan 12160',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showEditNoteDialog(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(0, 97, 213, 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: primaryBlue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan: "${_noteController.text}"',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined, color: primaryBlue, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 97, 213, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront, color: primaryBlue, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Row(
                  children: [
                    Text(
                      'Depot GalonKu Resmi - Malang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle, color: Colors.teal, size: 14),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Resmi',
                  style: TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildItemTile(
            title: 'Aqua Galon Isi Ulang 19L',
            subtitle: 'Refill / Tukar Galon Kosong',
            qtyPrice: '2x @ Rp 20.000',
            totalPrice: 'Rp 40.000',
            imagePath: 'assets/Aqua.png',
            fallbackIcon: Icons.water_drop,
          ),
          const SizedBox(height: 12),
          _buildItemTile(
            title: 'Le Minerale 15L',
            subtitle: 'Galon Sekali Pakai (Tanpa Tukar)',
            qtyPrice: '1x @ Rp 22.000',
            totalPrice: 'Rp 22.000',
            imagePath: 'assets/leminerale.png',
            fallbackIcon: Icons.water_drop_outlined,
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () {
              _showNotification('Ubah Opsi Pengiriman');
            },
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.teal.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opsi Pengiriman: Kurir GalonKu Reguler',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tiba Hari Ini, 14:30 - 15:30 WIB',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp 5.000',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile({
    required String title,
    required String subtitle,
    required String qtyPrice,
    required String totalPrice,
    required String imagePath,
    required IconData fallbackIcon,
  }) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(fallbackIcon, color: primaryBlue, size: 26);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.teal.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                qtyPrice,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(
          totalPrice,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.payment_outlined, color: primaryBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _showNotification('Lihat Semua Metode Pembayaran');
              },
              child: const Text(
                'Pilih Metode Lain>',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPaymentOptionTile(
          id: 'qris',
          customIconWidget: _buildIconContainer(
            child: const Icon(Icons.qr_code_scanner, color: primaryBlue, size: 20),
          ),
          title: 'QRIS',
          subtitle: 'GoPay, OVO, Dana, BCA, dll • Scan QR Instan',
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          id: 'gopay',
          customIconWidget: _buildIconContainer(
            child: const Icon(Icons.account_balance_wallet_outlined, color: primaryBlue, size: 20),
          ),
          title: 'GoPay',
          subtitle: 'Saldo Rp 145.000',
          badgeText: 'Instan',
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          id: 'bca_va',
          customIconWidget: _buildIconContainer(
            child: const Text(
              'BCA',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          title: 'BCA Virtual Account',
          subtitle: 'Konfirmasi instan otomatis',
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          id: 'cod',
          customIconWidget: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.payments_outlined, color: Color(0xFFE65100), size: 20),
            ),
          ),
          title: 'Bayar di Tempat (COD Kurir)',
          subtitle: 'Siapkan uang pas saat kurir tiba',
        ),
      ],
    );
  }

  Widget _buildIconContainer({required Widget child}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPaymentOptionTile({
    required String id,
    required Widget customIconWidget,
    required String title,
    required String subtitle,
    String? badgeText,
  }) {
    final bool isSelected = _selectedPaymentMethod == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Color.fromRGBO(0, 97, 213, 0.08),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            customIconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow('Subtotal untuk Produk (3 Galon)', 'Rp 62.000'),
          const SizedBox(height: 8),
          _buildSummaryRow('Biaya Pengiriman', 'Rp 5.000'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Biaya Layanan Higienis',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      _showNotification('Biaya untuk sanitasi tutup galon & segel ganda');
                    },
                    child: Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const Text(
                'Rp 1.000',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Rp 68.000',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildGuaranteeBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(0, 97, 213, 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'GalonKu menjamin galon resmi bersegel asli, steril, dan diantar langsung oleh kurir terverifikasi.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              const Text(
                'Rp 68.000',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _handleCreateOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Text(
                  'Buat Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Catatan Pengiriman', style: TextStyle(fontSize: 16)),
          content: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Contoh: Taruh di depan pagar...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
                _showNotification('Catatan pengiriman berhasil diperbarui!');
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showBcaVaPopupDialog(
    BuildContext context, {
    required String orderId,
    required String vaNumber,
    required int totalAmount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.account_balance, color: primaryBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'BCA Virtual Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nomor Virtual Account:',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vaNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryBlue,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: vaNumber));
                        _showNotification('Nomor VA disalin!');
                      },
                      child: const Icon(Icons.copy, size: 17, color: primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Total Tagihan: Rp 68.000',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showOrderSuccessDialog(
                  context,
                  title: 'Transfer BCA VA Berhasil!',
                  subtitle: 'Pembayaran Rp 68.000 telah terverifikasi.',
                  paymentLabel: 'BCA Virtual Account',
                  orderId: orderId,
                  totalAmount: totalAmount,
                );
              },
              child: const Text('Saya Sudah Bayar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  static void _showOrderSuccessDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String paymentLabel,
    required String orderId,
    required int totalAmount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(
                      context,
                      '/tracking',
                      arguments: {
                        'orderId': orderId,
                        'productName': '2× Aqua 19L, 1× Le Minerale 15L',
                        'totalPrice': totalAmount,
                        'paymentMethod': paymentLabel,
                        'address': 'Kost Sakura, Kamar 204 (Lantai 2)',
                      },
                    );
                  },
                  child: const Text('Lacak Pesanan', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QrisPaymentScreen extends StatefulWidget {
  final String orderId;
  final String totalAmount;

  const QrisPaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  int _remainingSeconds = 14 * 60 + 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0 && mounted) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m : $s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD92D20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Selesaikan pembayaran dalam $_formattedTimer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.totalAmount,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'No. Pesanan',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${widget.orderId}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD92D20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'QRIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Text(
                        'Standar Nasional • GPN',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'GalonKu Kebayoran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'NMID : ID2023948192841',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 185, color: Color(0xFF172337)),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryBlue,
                          child: Icon(Icons.water_drop, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kode QR berhasil disimpan ke galeri')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 17, color: primaryBlue),
                      label: const Text(
                        'Unduh QR Code',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F6FF),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Buka aplikasi mobile banking atau e-wallet pilihan Anda, lalu scan kode QR di atas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  _CheckoutScreenState._showOrderSuccessDialog(
                    context,
                    title: 'Pembayaran QRIS Berhasil!',
                    subtitle: 'Pembayaran Rp 68.000 terverifikasi otomatis.',
                    paymentLabel: 'QRIS',
                    orderId: widget.orderId,
                    totalAmount: 68000,
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Cek Status Pembayaran',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: const Text(
                  'Ganti Metode Pembayaran >',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}