import 'dart:convert';
import 'dart:io';

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
}
