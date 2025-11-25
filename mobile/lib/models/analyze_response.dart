class Macros {
  final double protein;
  final double carbs;
  final double fat;

  Macros({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MealItem {
  final String label;
  final double confidence;
  final double gramsEstimated;
  final double kcal;
  final Macros macros;

  MealItem({
    required this.label,
    required this.confidence,
    required this.gramsEstimated,
    required this.kcal,
    required this.macros,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      label: json['label'] as String? ?? 'Unknown item',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      gramsEstimated: (json['grams_estimated'] as num?)?.toDouble() ?? 0,
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0,
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ReferenceObject {
  final String type;
  final double scale;

  ReferenceObject({
    required this.type,
    required this.scale,
  });

  factory ReferenceObject.fromJson(Map<String, dynamic> json) {
    return ReferenceObject(
      type: json['type'] as String? ?? 'unknown',
      scale: (json['scale'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AnalyzeResponse {
  final List<MealItem> items;
  final ReferenceObject? referenceObject;

  AnalyzeResponse({
    required this.items,
    this.referenceObject,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] as List<dynamic>? ?? [];
    return AnalyzeResponse(
      items: rawItems
          .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      referenceObject: json['reference_object'] != null
          ? ReferenceObject.fromJson(
              json['reference_object'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  double get totalKcal => items.fold(0, (sum, item) => sum + item.kcal);
  double get totalGrams =>
      items.fold(0, (sum, item) => sum + item.gramsEstimated);

  Macros get totalMacros => Macros(
        protein: items.fold(0, (sum, item) => sum + item.macros.protein),
        carbs: items.fold(0, (sum, item) => sum + item.macros.carbs),
        fat: items.fold(0, (sum, item) => sum + item.macros.fat),
      );
}
