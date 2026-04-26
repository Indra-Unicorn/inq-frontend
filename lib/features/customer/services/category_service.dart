import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/constants/api_endpoints.dart';
import '../models/category.dart';

class CategoryService {
  Future<List<Category>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllCategories}'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final list = data['data'] as List<dynamic>;
      final categories = list
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
      // API returns categories sorted by rank, but sort locally to be safe
      categories.sort((a, b) => a.rank.compareTo(b.rank));
      return categories;
    }

    throw Exception(data['message'] ?? 'Failed to load categories');
  }
}
