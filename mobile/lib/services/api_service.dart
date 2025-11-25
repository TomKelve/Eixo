import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/analyze_response.dart';
import 'api_config.dart';

class ApiService {
  Future<AnalyzeResponse> analyzeImage(File file) async {
    final uri = Uri.parse('$apiBaseUrl/analyze/image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to analyze image: ${response.statusCode}',
        uri: uri,
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return AnalyzeResponse.fromJson(data);
  }

  Future<AnalyzeResponse> analyzeVideo(File file) async {
    final uri = Uri.parse('$apiBaseUrl/analyze/video');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to analyze video: ${response.statusCode}',
        uri: uri,
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return AnalyzeResponse.fromJson(data);
  }

  Future<void> sendFeedback(List<MealItem> items) async {
    final uri = Uri.parse('$apiBaseUrl/feedback');
    for (final item in items) {
      final payload = {
        'meal_item_id': _generateLocalId(),
        'grams_user': item.gramsUser ?? item.gramsEstimated,
        'accepted_label': item.label,
        'mask_delta': null,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final response = await http.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Failed to send feedback: ${response.statusCode}', uri: uri);
      }
    }
  }

  String _generateLocalId() {
    final random = Random();
    return '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
  }
}
