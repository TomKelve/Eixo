import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish_analysis.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? 'http://localhost:8000';

  Future<DishAnalysis> analyzeDish(String imagePath) async {
    final uri = Uri.parse('$baseUrl/analyze');
    // TODO: replace with multipart upload once wiring is in place.
    final response = await http.post(uri, body: {'imagePath': imagePath});
    if (response.statusCode != 200) {
      throw Exception('Failed to analyze dish');
    }
    return DishAnalysis.fromJson(jsonDecode(response.body));
  }

  /// Temporary helper to simulate the API while backend is being wired.
  Future<DishAnalysis> mockAnalyze() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return DishAnalysis(
      dishName: 'Feijoada',
      estimatedPortionGrams: 420,
      calories: 780,
      tags: const ['beans', 'pork', 'rice', 'farofa'],
    );
  }
}
