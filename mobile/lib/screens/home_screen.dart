import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/dish_analysis.dart';
import '../widgets/dish_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _apiClient = ApiClient();
  DishAnalysis? _lastResult;
  bool _loading = false;

  Future<void> _simulateAnalyze() async {
    setState(() => _loading = true);
    final result = await _apiClient.mockAnalyze();
    setState(() {
      _lastResult = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EIXO Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture and analyze your Brazilian meals with AI.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _simulateAnalyze,
              icon: const Icon(Icons.camera_alt),
              label: Text(_loading ? 'Analyzing...' : 'Simulate Analysis'),
            ),
            const SizedBox(height: 16),
            if (_lastResult != null) DishCard(result: _lastResult!),
          ],
        ),
      ),
    );
  }
}
