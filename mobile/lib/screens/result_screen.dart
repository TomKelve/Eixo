import 'package:flutter/material.dart';

import '../models/analyze_response.dart';

class ResultScreen extends StatelessWidget {
  final AnalyzeResponse response;

  const ResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final totalMacros = response.totalMacros;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (response.referenceObject != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Reference Object Detected'),
                  subtitle: Text(
                    '${response.referenceObject!.type} — scale: ${response.referenceObject!.scale.toStringAsFixed(2)}',
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: response.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = response.items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text('${(item.confidence * 100).toStringAsFixed(1)}%'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Grams estimated: ${item.gramsEstimated.toStringAsFixed(1)} g'),
                          Text('Calories: ${item.kcal.toStringAsFixed(1)} kcal'),
                          const SizedBox(height: 6),
                          Text(
                            'Macros (P/C/F): ${item.macros.protein.toStringAsFixed(1)}g / ${item.macros.carbs.toStringAsFixed(1)}g / ${item.macros.fat.toStringAsFixed(1)}g',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Totals',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Total grams: ${response.totalGrams.toStringAsFixed(1)} g'),
                    Text('Total calories: ${response.totalKcal.toStringAsFixed(1)} kcal'),
                    const SizedBox(height: 6),
                    Text(
                      'Macros (P/C/F): ${totalMacros.protein.toStringAsFixed(1)}g / ${totalMacros.carbs.toStringAsFixed(1)}g / ${totalMacros.fat.toStringAsFixed(1)}g',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
