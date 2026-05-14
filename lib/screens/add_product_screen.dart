import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.saveProduct(
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      description: _descController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success'] == true
              ? 'Produk berhasil disimpan!'
              : result['message'] ?? 'Gagal menyimpan',
        ),
        backgroundColor:
            result['success'] == true ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner peringatan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data tidak dapat diubah setelah disimpan. Pastikan sudah benar!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Nama produk
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          label: 'Nama Produk',
                          hint: 'Contoh: Macbook Pro M5 2026',
                          icon: Icons.label_outline_rounded,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Nama produk wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Harga
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: _inputDecoration(
                          label: 'Harga (Rp)',
                          hint: 'Contoh: 32450000',
                          icon: Icons.payments_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          label: 'Deskripsi',
                          hint: 'Deskripsikan produk Anda...',
                          icon: Icons.description_outlined,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Deskripsi wajib diisi'
                                : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol simpan
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveProduct,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isLoading ? 'Menyimpan...' : 'Simpan Produk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}