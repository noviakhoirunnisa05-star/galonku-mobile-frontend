import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBlue = Color(0xFF0061D5);
  static const Color lightBgColor = Color(0xFFF4F7FF);

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  String _displayName = 'Budi Santoso';
  final String _avatarAssetPath = 'assets/Profile.png';
  String? _uploadedAvatarPath;
  bool _isPickingPhoto = false;

  final _addresses = [
    {
      'title': 'Kost Sakura (Kamar 204)',
      'recipient': 'Budi Santoso • (+62) 812-3456-7890',
      'detail':
          'Kost Sakura, Kamar 204, Jl. Kemang Timur No. 12, Jakarta Selatan, DKI Jakarta',
      'isPrimary': 'true',
    },
    {
      'title': 'Rumah Keluarga',
      'recipient': 'Rosi • (+62) 812-3456-7890',
      'detail':
          'Jl. Soekarno Hatta No. 45, Lowokwaru, Kota Malang, Jawa Timur',
      'isPrimary': 'false',
    },
  ];

  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Rosi');
    _phoneController = TextEditingController(text: '+62 812-3456-7890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  Map<String, String> get _activeAddress {
    return _addresses.firstWhere(
      (item) => item['isPrimary'] == 'true',
      orElse: () => _addresses.first,
    );
  }

  Widget _buildAvatarContent() {
    if (_uploadedAvatarPath != null && _uploadedAvatarPath!.isNotEmpty) {
      return Image.file(
        File(_uploadedAvatarPath!),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAssetAvatarFallback(),
      );
    }

    return _buildAssetAvatarFallback();
  }

  Widget _buildAssetAvatarFallback() {
    return Image.asset(
      _avatarAssetPath,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.person,
          size: 48,
          color: primaryBlue,
        );
      },
    );
  }

  Future<void> _pickPhotoFromDevice() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);

    try {
      final List<PlatformFile> pickedFiles = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (!mounted) return;
      if (pickedFiles.isNotEmpty) {
        final String? path = pickedFiles.first.path;
        if (path != null && path.isNotEmpty) {
          setState(() {
            _uploadedAvatarPath = path;
          });
          _showNotification('Foto profil berhasil dipilih dari perangkat!');
        } else {
          _showNotification(
            'File foto tidak terbaca. Coba pilih file gambar lain.',
            isError: true,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        _showNotification(
          'Gagal membuka pemilih file.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  Future<void> _openPhotoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF5FF),
                  child: Icon(Icons.folder_open, color: primaryBlue),
                ),
                title: const Text(
                  'Upload Foto dari Perangkat',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Pilih foto baru langsung dari galeri / folder perangkat',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickPhotoFromDevice();
                },
              ),
              if (_uploadedAvatarPath != null)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF1F2),
                    child: Icon(Icons.restore, color: Colors.red),
                  ),
                  title: const Text(
                    'Kembalikan ke Foto Awal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _uploadedAvatarPath = null;
                    });
                    _showNotification('Foto profil dikembalikan ke awal');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isEmpty) {
      _showNotification('Nama lengkap tidak boleh kosong', isError: true);
      return;
    }
    if (newPhone.isEmpty) {
      _showNotification('Nomor WhatsApp / HP tidak boleh kosong', isError: true);
      return;
    }

    setState(() {
      _displayName = newName;
      final primaryIndex =
          _addresses.indexWhere((item) => item['isPrimary'] == 'true');
      if (primaryIndex != -1) {
        _addresses[primaryIndex]['recipient'] = '$newName • $newPhone';
      }
    });

    _showNotification('Perubahan profil berhasil disimpan!');
  }

  Future<void> _editAddressDialog({
    Map<String, String>? existing,
    bool isNew = false,
  }) async {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final recipientCtrl = TextEditingController(
      text: existing?['recipient'] ??
          '${_nameController.text.trim()} • ${_phoneController.text.trim()}',
    );
    final detailCtrl = TextEditingController(text: existing?['detail'] ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            isNew ? 'Tambah Alamat Baru' : 'Ubah Alamat Pengiriman',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Label Tempat (cth: Kost Sakura)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: recipientCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Penerima & No. HP',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty ||
                    detailCtrl.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child:
                  const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (saved == true && mounted) {
      setState(() {
        if (isNew) {
          for (final item in _addresses) {
            item['isPrimary'] = 'false';
          }
          _addresses.insert(0, {
            'title': titleCtrl.text.trim(),
            'recipient': recipientCtrl.text.trim(),
            'detail': detailCtrl.text.trim(),
            'isPrimary': 'true',
          });
        } else if (existing != null) {
          existing['title'] = titleCtrl.text.trim();
          existing['recipient'] = recipientCtrl.text.trim();
          existing['detail'] = detailCtrl.text.trim();
        }
      });
      _showNotification(
        isNew ? 'Alamat baru ditambahkan' : 'Alamat berhasil diperbarui',
      );
    }

    titleCtrl.dispose();
    recipientCtrl.dispose();
    detailCtrl.dispose();
  }

  Future<void> _openAllAddressesSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Semua Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._addresses.map((addr) {
                    final isPrimary = addr['isPrimary'] == 'true';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? const Color(0xFFF2F6FF)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPrimary
                              ? primaryBlue.withValues(alpha: 0.35)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                addr['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
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
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            addr['detail'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            for (final item in _addresses) {
                              item['isPrimary'] = 'false';
                            }
                            addr['isPrimary'] = 'true';
                          });
                          setSheetState(() {});
                          Navigator.pop(sheetContext);
                          _showNotification(
                            'Alamat utama diubah ke ${addr['title']}',
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Keluar Akun'),
          content:
              const Text('Apakah Anda yakin ingin keluar dari akun GalonKu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child:
                  const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryAddr = _activeAddress;

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
              _showNotification('Anda berada di halaman utama profil');
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Profil Akun',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.water_drop_outlined, color: primaryBlue),
            onPressed: () {
              _showNotification('GalonKu • Pengantaran Galon Cepat & Aman');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF5FF),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: _buildAvatarContent(),
                          ),
                        ),
                        InkWell(
                          onTap: _openPhotoSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pengguna GalonKu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nomor WhatsApp / HP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Alamat Pengiriman',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: _openAllAddressesSheet,
                          child: const Text(
                            'Semua Alamat >',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 97, 213, 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: primaryBlue, size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  primaryAddr['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _editAddressDialog(existing: primaryAddr),
                                child: const Text(
                                  'Ubah >',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 97, 213, 0.15),
                              borderRadius: BorderRadius.circular(6),
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
                          const SizedBox(height: 8),
                          Text(
                            primaryAddr['recipient'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            primaryAddr['detail'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _editAddressDialog(isNew: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: Color.fromRGBO(0, 97, 213, 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_circle_outline,
                            color: primaryBlue, size: 18),
                        label: const Text(
                          'Tambah Alamat Baru',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                label: const Text(
                  'Keluar dari Akun',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/products');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/history');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
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
    );
  }
}