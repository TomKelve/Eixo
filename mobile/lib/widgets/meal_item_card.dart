import 'package:flutter/material.dart';

import '../models/analyze_response.dart';

class MealItemCard extends StatelessWidget {
  final MealItem item;
  final bool editable;
  final ValueChanged<MealItem>? onChanged;

  const MealItemCard({
    super.key,
    required this.item,
    this.editable = false,
    this.onChanged,
  });

  double _calculateScale(MealItem item) {
    final baseGrams = item.gramsEstimated <= 0 ? 1 : item.gramsEstimated;
    final userGrams = item.gramsUser ?? item.gramsEstimated;
    if (baseGrams == 0) return 1;
    return (userGrams <= 0 ? 0 : userGrams) / baseGrams;
  }

  double _calculateKcal(MealItem item) {
    final scale = _calculateScale(item);
    return item.kcal * scale;
  }

  Macros _calculateMacros(MealItem item) {
    final scale = _calculateScale(item);
    return Macros(
      protein: item.macros.protein * scale,
      carbs: item.macros.carbs * scale,
      fat: item.macros.fat * scale,
    );
  }

  void _handleDelta(double delta) {
    if (!editable) return;
    final maxRange = item.gramsEstimated > 0 ? item.gramsEstimated * 2 : 300;
    final current = item.gramsUser ?? item.gramsEstimated;
    final updated = (current + delta).clamp(0, maxRange).toDouble();
    onChanged?.call(item.copyWith(gramsUser: updated));
  }

  @override
  Widget build(BuildContext context) {
    final currentGrams = item.gramsUser ?? item.gramsEstimated;
    final maxRange = item.gramsEstimated > 0 ? item.gramsEstimated * 2 : 300;
    final kcal = _calculateKcal(item);
    final macros = _calculateMacros(item);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${(item.confidence * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated: ${item.gramsEstimated.toStringAsFixed(1)} g',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 4),
            Text('Current: ${currentGrams.toStringAsFixed(1)} g'),
            const SizedBox(height: 6),
            Text('Calories: ${kcal.toStringAsFixed(1)} kcal'),
            Text(
              'Macros (P/C/F): ${macros.protein.toStringAsFixed(1)}g / ${macros.carbs.toStringAsFixed(1)}g / ${macros.fat.toStringAsFixed(1)}g',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: editable ? () => _handleDelta(-10.0) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Slider(
                    value: currentGrams.clamp(0, maxRange).toDouble(),
                    min: 0.0,
                    max: (maxRange > 0 ? maxRange : 300).toDouble(),
                    label: '${currentGrams.toStringAsFixed(0)} g',
                    onChanged: editable
                        ? (value) => onChanged?.call(
                              item.copyWith(gramsUser: value),
                            )
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: editable ? () => _handleDelta(10.0) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
