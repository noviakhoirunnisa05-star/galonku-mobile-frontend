import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String subtitle;
  final int unitPrice;
  final String imagePath;
  final String badgeText;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.unitPrice,
    required this.imagePath,
    required this.badgeText,
    this.quantity = 1,
    this.isSelected = true,
  });

  int get totalPrice => unitPrice * quantity;
}

enum DeliveryMethodType {
  dropOff,
  pickUp,
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  static const Color lightBgColor = Color(0xFFF8FAFF);

  DeliveryMethodType _deliveryMethod = DeliveryMethodType.dropOff;
  String _addressTitle = 'Kost Sakura, Kamar 204';
  String _addressDetail = 'Jl. Melati No. 12, Kebayoran Baru, Jakarta Selatan';

  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Aqua Galon Isi Ulang 19L',
      subtitle: 'Refill / Tukar Galon Kosong',
      unitPrice: 20000,
      imagePath: 'assets/Aqua.png',
      badgeText: '19L',
      quantity: 2,
      isSelected: true,
    ),
    CartItem(
      id: '2',
      title: 'Le Minerale 15L',
      subtitle: 'Galon Sekali Pakai (Tanpa Tukar)',
      unitPrice: 22000,
      imagePath: 'assets/leminerale.png',
      badgeText: '15L',
      quantity: 1,
      isSelected: true,
    ),
  ];

  List<CartItem> get _selectedItems =>
      _cartItems.where((e) => e.isSelected).toList();
  int get _totalPrice =>
      _selectedItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get _totalGalonCount =>
      _selectedItems.fold(0, (sum, item) => sum + item.quantity);
  bool get _isAllSelected =>
      _cartItems.isNotEmpty && _cartItems.every((e) => e.isSelected);

  String get _deliveryTitle => _deliveryMethod == DeliveryMethodType.dropOff
      ? 'Drop Off (Diantar Kurir)'
      : 'Pick Up (Ambil Sendiri)';

  String get _deliverySubtitle => _deliveryMethod == DeliveryMethodType.dropOff
      ? 'Kurir antar langsung ke depan pintu hunian Anda'
      : 'Ambil langsung galon di depot resmi GalonKu terdekat';

  int get _deliveryFee => _deliveryMethod == DeliveryMethodType.dropOff ? 5000 : 0;

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      final bool checkVal = value ?? false;
      for (final item in _cartItems) {
        item.isSelected = checkVal;
      }
    });
  }

  void _deleteSelectedItems() {
    if (_selectedItems.isEmpty) {
      _showNotification('Tidak ada produk yang dipilih', isError: true);
      return;
    }
    setState(() {
      _cartItems.removeWhere((item) => item.isSelected);
    });
    _showNotification('Item berhasil dihapus dari keranjang');
  }

  void _removeItemAt(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _showNotification('Produk berhasil dihapus');
  }

  Future<void> _openDeliveryMethodAndProceed({bool goToCheckoutAfter = false}) async {
    if (_selectedItems.isEmpty) {
      _showNotification('Pilih minimal 1 produk terlebih dahulu', isError: true);
      return;
    }

    final result = await Navigator.push<DeliveryMethodType>(
      context,
      MaterialPageRoute<DeliveryMethodType>(
        builder: (_) => DeliveryMethodScreen(
          initialMethod: _deliveryMethod,
          addressTitle: _addressTitle,
          addressDetail: _addressDetail,
          onChangeAddress: (newTitle, newDetail) {
            setState(() {
              _addressTitle = newTitle;
              _addressDetail = newDetail;
            });
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _deliveryMethod = result;
      });
      _goToCheckout();
    } else if (goToCheckoutAfter && mounted) {
      _goToCheckout();
    }
  }

  void _goToCheckout() {
    if (_selectedItems.isEmpty) {
      _showNotification('Pilih minimal 1 produk terlebih dahulu', isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          items: List<CartItem>.from(_selectedItems),
          deliveryMethod: _deliveryMethod,
          deliveryFee: _deliveryFee,
          addressTitle: _addressTitle,
          addressDetail: _addressDetail,
        ),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Keranjang Galonku',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () => _showNotification('Bantuan Keranjang Belanja'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddressCard(),
                    const SizedBox(height: 16),
                    _buildSelectAllHeader(),
                    const SizedBox(height: 12),
                    if (_cartItems.isEmpty)
                      _buildEmptyCartView()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildCartTile(index),
                      ),
                    const SizedBox(height: 16),
                    _buildDeliveryMethodCard(),
                    const SizedBox(height: 16),
                    _buildPaymentSummaryCard(),
                    const SizedBox(height: 16),
                    _buildQualityBanner(),
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

  Widget _buildAddressCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: primaryBlue, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'ALAMAT PENGANTARAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showNotification('Ubah Alamat Pengantaran'),
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _addressTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _addressDetail,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isAllSelected,
                activeColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: _toggleSelectAll,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pilih Semua (${_cartItems.length} produk)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _deleteSelectedItems,
          child: const Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              SizedBox(width: 4),
              Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartTile(int index) {
    final item = _cartItems[index];
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: item.isSelected,
              activeColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) {
                setState(() {
                  item.isSelected = val ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.water_drop, color: primaryBlue, size: 32);
                    },
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeItemAt(index),
                      child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${_formatRupiah(item.totalPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Rp ${_formatRupiah(item.unitPrice)} / galon',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  _removeItemAt(index);
                                }
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(Icons.remove, size: 14, color: Colors.black54),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                item.quantity++;
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: primaryBlue, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'METODE PENGIRIMAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _openDeliveryMethodAndProceed(goToCheckoutAfter: false),
                child: const Text(
                  'Ubah>',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _deliveryTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _deliverySubtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
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
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Produk (${_selectedItems.length} jenis, $_totalGalonCount galon)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                'Rp ${_formatRupiah(_totalPrice)}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Tagihan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Termasuk biaya layanan',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Text(
                'Rp ${_formatRupiah(_totalPrice)}',
                style: const TextStyle(
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

  Widget _buildQualityBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_outlined, color: Colors.teal, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Tutup galon sanitasi ganda & pengantaran anti-tumpah',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
                'Total Tagihan',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                'Rp ${_formatRupiah(_totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$_totalGalonCount galon dipilih',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _selectedItems.isEmpty ? null : _goToCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Text(
                  'Lanjut Bayar',
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

  Widget _buildEmptyCartView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Keranjang Belanjaan Kosong',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryMethodScreen extends StatefulWidget {
  final DeliveryMethodType initialMethod;
  final String addressTitle;
  final String addressDetail;
  final void Function(String title, String detail)? onChangeAddress;

  const DeliveryMethodScreen({
    super.key,
    required this.initialMethod,
    required this.addressTitle,
    required this.addressDetail,
    this.onChangeAddress,
  });

  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  late DeliveryMethodType _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedLabel = _selectedMethod == DeliveryMethodType.dropOff
        ? 'Drop Off (Diantar Kurir)'
        : 'Pick Up (Ambil Sendiri)';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Metode Pengiriman',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Metode Pengiriman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tentukan cara pengantaran atau pengambilan galon air segar Anda sesuai preferensi.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionTile(
                      type: DeliveryMethodType.dropOff,
                      title: 'Drop Off (Diantar Kurir)',
                      subtitle:
                          'Kurir GalonKu akan mengantar langsung sampai depan pintu kamar atau rumah Anda.',
                      badge: 'Paling Praktis',
                      meta: '15–30 Mnt • Bantu Angkat',
                    ),
                    const SizedBox(height: 12),
                    _buildOptionTile(
                      type: DeliveryMethodType.pickUp,
                      title: 'Pick Up (Ambil Sendiri)',
                      subtitle:
                          'Ambil langsung galon di depot resmi GalonKu terdekat dari lokasi Anda kapan saja.',
                      badge: null,
                      meta: 'Depot Terdekat • Siap 10 Mnt',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ALAMAT PENGANTARAN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.addressTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.addressDetail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metode Terpilih:',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        selectedLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedMethod),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Pilih & Lanjutkan →',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required DeliveryMethodType type,
    required String title,
    required String subtitle,
    required String? badge,
    required String meta,
  }) {
    final bool isSelected = _selectedMethod == type;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedMethod = type),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              type == DeliveryMethodType.dropOff
                  ? Icons.two_wheeler
                  : Icons.storefront_outlined,
              color: primaryBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? primaryBlue : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final DeliveryMethodType deliveryMethod;
  final int deliveryFee;
  final String addressTitle;
  final String addressDetail;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.addressTitle,
    required this.addressDetail,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  String _selectedPayment = 'QRIS';

  int get _subtotal =>
      widget.items.fold(0, (sum, item) => sum + item.totalPrice);
  int get _grandTotal => _subtotal + widget.deliveryFee;

  @override
  Widget build(BuildContext context) {
    final String methodLabel = widget.deliveryMethod == DeliveryMethodType.dropOff
        ? 'Drop Off (Diantar Kurir)'
        : 'Pick Up (Ambil Sendiri)';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.addressTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.addressDetail,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Metode: $methodLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Produk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...widget.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.title}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatRupiah(item.totalPrice)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...['QRIS', 'GoPay', 'BCA Virtual Account', 'COD Kurir']
                            .map(
                          (method) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: method,
                            groupValue: _selectedPayment,
                            activeColor: primaryBlue,
                            title: Text(
                              method,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedPayment = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      children: [
                        _rowPrice('Subtotal Produk', _subtotal),
                        const SizedBox(height: 6),
                        _rowPrice('Biaya Pengiriman', widget.deliveryFee),
                        const Divider(height: 18),
                        _rowPrice('Total Pembayaran', _grandTotal, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        'Rp ${_formatRupiah(_grandTotal)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pesanan dibuat ($methodLabel • $_selectedPayment)',
                          ),
                          backgroundColor: primaryBlue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Buat Pesanan →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _rowPrice(String label, int amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'Rp ${_formatRupiah(amount)}',
          style: TextStyle(
            fontSize: isBold ? 15 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? primaryBlue : Colors.black87,
          ),
        ),
      ],
    );
  }
}

String _formatRupiah(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}