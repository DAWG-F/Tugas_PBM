import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _githubController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _submitTugas() async {
    if (!_formKey.currentState!.validate()) return;

    // Konfirmasi sebelum submit
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Submit'),
        content: const Text(
          'Data yang sudah disubmit TIDAK DAPAT diubah.\n\nYakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final result = await ApiService.submitTugas(
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      description: _descController.text.trim(),
      githubUrl: _githubController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal submit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Kumpulkan Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _submitted ? _buildSuccessView() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tugas Berhasil Dikumpulkan!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Waktu submit telah tercatat otomatis oleh sistem.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke Beranda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
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
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data submit TIDAK DAPAT diubah. Pastikan nama produk, harga, deskripsi, dan GitHub URL sudah benar!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.w500,
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
                      hint: 'Nama produk yang dikumpulkan',
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
                      hint: 'Harga dalam satuan Rupiah',
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
                    maxLines: 3,
                    decoration: _inputDecoration(
                      label: 'Deskripsi Produk',
                      hint: 'Deskripsi lengkap produk Anda',
                      icon: Icons.description_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Deskripsi wajib diisi'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // GitHub URL
                  TextFormField(
                    controller: _githubController,
                    decoration: _inputDecoration(
                      label: 'GitHub Repository URL',
                      hint: 'https://github.com/username/nama-repo',
                      icon: Icons.link_rounded,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'GitHub URL wajib diisi';
                      }
                      if (!v.trim().startsWith('https://github.com/')) {
                        return 'URL harus dimulai https://github.com/';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol submit
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitTugas,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isLoading ? 'Mengumpulkan...' : 'Kumpulkan Tugas',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
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