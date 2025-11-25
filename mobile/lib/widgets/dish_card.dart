import 'package:flutter/material.dart';
import '../models/dish_analysis.dart';

class DishCard extends StatelessWidget {
  final DishAnalysis result;

  const DishCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.dishName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Portion: ${result.estimatedPortionGrams.toStringAsFixed(0)} g'),
            Text('Calories: ${result.calories.toStringAsFixed(0)} kcal'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: result.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
