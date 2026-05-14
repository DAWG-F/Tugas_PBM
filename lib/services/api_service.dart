import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // Simpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Hapus token (logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Header dengan Bearer Token
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['token'] as String;
      final user = UserModel.fromJson(data['data']['user']);
      await saveToken(token);
      return {'success': true, 'token': token, 'user': user};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    }
  }

  // Ambil daftar produk
  static Future<Map<String, dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.get(url, headers: await authHeaders());
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> list = data['data']['products'];
      final products = list.map((e) => ProductModel.fromJson(e)).toList();
      return {'success': true, 'products': products};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal memuat produk'};
    }
  }

  // Simpan produk
  static Future<Map<String, dynamic>> saveProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal menyimpan'};
    }
  }

  // Hapus produk
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(url, headers: await authHeaders());
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal menghapus'};
    }
  }

  // Submit tugas
  static Future<Map<String, dynamic>> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final response = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal submit'};
    }
  }
}