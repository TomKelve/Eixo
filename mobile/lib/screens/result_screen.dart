import 'package:flutter/material.dart';

import '../models/analyze_response.dart';
import '../services/api_service.dart';
import '../widgets/meal_item_card.dart';

class ResultScreen extends StatefulWidget {
  final AnalyzeResponse response;

  const ResultScreen({super.key, required this.response});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<MealItem> editableItems;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    editableItems = widget.response.items
        .map((item) => item.copyWith(gramsUser: item.gramsUser ?? item.gramsEstimated))
        .toList();
  }

  double _itemScale(MealItem item) {
    final base = item.gramsEstimated;
    final user = item.gramsUser ?? base;
    if (base <= 0) return 1;
    return (user <= 0 ? 0 : user) / base;
  }

  double _itemKcal(MealItem item) {
    final scale = _itemScale(item);
    return item.kcal * scale;
  }

  Macros _itemMacros(MealItem item) {
    final scale = _itemScale(item);
    return Macros(
      protein: item.macros.protein * scale,
      carbs: item.macros.carbs * scale,
      fat: item.macros.fat * scale,
    );
  }

  double get totalKcal =>
      editableItems.fold(0, (sum, item) => sum + _itemKcal(item));

  double get totalGrams =>
      editableItems.fold(0, (sum, item) => sum + (item.gramsUser ?? item.gramsEstimated));

  Macros get totalMacros => Macros(
        protein: editableItems.fold(0, (sum, item) => sum + _itemMacros(item).protein),
        carbs: editableItems.fold(0, (sum, item) => sum + _itemMacros(item).carbs),
        fat: editableItems.fold(0, (sum, item) => sum + _itemMacros(item).fat),
      );

  Future<void> _saveAdjustments() async {
    setState(() {
      isSaving = true;
    });
    try {
      await ApiService().sendFeedback(editableItems);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajustes salvos!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar ajustes: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalsCard = Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('Calories: ${totalKcal.toStringAsFixed(1)} kcal'),
            Text('Grams: ${totalGrams.toStringAsFixed(1)} g'),
            Text(
              'Macros (P/C/F): ${totalMacros.protein.toStringAsFixed(1)}g / ${totalMacros.carbs.toStringAsFixed(1)}g / ${totalMacros.fat.toStringAsFixed(1)}g',
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            totalsCard,
            if (widget.response.referenceObject != null) ...[
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Reference Object Detected'),
                  subtitle: Text(
                    '${widget.response.referenceObject!.type} — scale: ${widget.response.referenceObject!.scale.toStringAsFixed(2)}',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: editableItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = editableItems[index];
                  return MealItemCard(
                    item: item,
                    editable: true,
                    onChanged: (updated) {
                      setState(() {
                        editableItems[index] = updated;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveAdjustments,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Saving...' : 'Salvar Ajustes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
