class Macros {
  final double protein;
  final double carbs;
  final double fat;

  const Macros({
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

  Macros copyWith({
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return Macros(
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}

class FitnessDiagnostics {
  final bool proteinOk;
  final bool carbOk;
  final bool fatOk;
  final List<String> messages;

  FitnessDiagnostics({
    required this.proteinOk,
    required this.carbOk,
    required this.fatOk,
    required this.messages,
  });

  factory FitnessDiagnostics.fromJson(Map<String, dynamic> json) {
    return FitnessDiagnostics(
      proteinOk: json['protein_ok'] ?? false,
      carbOk: json['carb_ok'] ?? false,
      fatOk: json['fat_ok'] ?? false,
      messages: (json['messages'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

class Fitness {
  final double fitnessScore;
  final String mode;
  final FitnessDiagnostics diagnostics;

  Fitness({
    required this.fitnessScore,
    required this.mode,
    required this.diagnostics,
  });

  factory Fitness.fromJson(Map<String, dynamic> json) {
    return Fitness(
      fitnessScore: (json['fitness_score'] ?? 0).toDouble(),
      mode: json['mode'] ?? 'desconhecido',
      diagnostics: FitnessDiagnostics.fromJson(
        json['diagnostics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CorrectionChange {
  final String label;
  final double gramsCurrent;
  final double gramsSuggested;
  final double? approxSpoonsRemove;
  final double? approxLadlesRemove;

  CorrectionChange({
    required this.label,
    required this.gramsCurrent,
    required this.gramsSuggested,
    this.approxSpoonsRemove,
    this.approxLadlesRemove,
  });

  factory CorrectionChange.fromJson(Map<String, dynamic> json) {
    return CorrectionChange(
      label: json['label'] ?? '',
      gramsCurrent: (json['grams_current'] ?? 0).toDouble(),
      gramsSuggested: (json['grams_suggested'] ?? 0).toDouble(),
      approxSpoonsRemove: json['approx_spoons_remove'] != null
          ? (json['approx_spoons_remove'] as num).toDouble()
          : null,
      approxLadlesRemove: json['approx_ladles_remove'] != null
          ? (json['approx_ladles_remove'] as num).toDouble()
          : null,
    );
  }
}

class CorrectionPlan {
  final double currentTotalKcal;
  final double targetKcal;
  final double neededDeltaKcal;
  final List<CorrectionChange> suggestedChanges;
  final String summaryText;

  CorrectionPlan({
    required this.currentTotalKcal,
    required this.targetKcal,
    required this.neededDeltaKcal,
    required this.suggestedChanges,
    required this.summaryText,
  });

  factory CorrectionPlan.fromJson(Map<String, dynamic> json) {
    return CorrectionPlan(
      currentTotalKcal: (json['current_total_kcal'] ?? 0).toDouble(),
      targetKcal: (json['target_kcal'] ?? 0).toDouble(),
      neededDeltaKcal: (json['needed_delta_kcal'] ?? 0).toDouble(),
      suggestedChanges: (json['suggested_changes'] as List<dynamic>? ?? [])
          .map((e) => CorrectionChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      summaryText: json['summary_text'] ?? '',
    );
  }
}

class MealItem {
  final String label;
  final double confidence;
  final double gramsEstimated;
  final double kcal;
  final Macros macros;
  final double? gramsUser;

  const MealItem({
    required this.label,
    required this.confidence,
    required this.gramsEstimated,
    required this.kcal,
    required this.macros,
    this.gramsUser,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      label: json['label'] as String? ?? 'Unknown item',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      gramsEstimated: (json['grams_estimated'] as num?)?.toDouble() ?? 0,
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0,
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
      gramsUser: (json['grams_user'] as num?)?.toDouble(),
    );
  }

  MealItem copyWith({
    String? label,
    double? confidence,
    double? gramsEstimated,
    double? kcal,
    Macros? macros,
    double? gramsUser,
  }) {
    return MealItem(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      gramsEstimated: gramsEstimated ?? this.gramsEstimated,
      kcal: kcal ?? this.kcal,
      macros: macros ?? this.macros,
      gramsUser: gramsUser ?? this.gramsUser,
    );
  }

  double get effectiveGrams => gramsUser ?? gramsEstimated;
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
  final Fitness? fitness;
  final CorrectionPlan? correctionPlan;

  AnalyzeResponse({
    required this.items,
    this.referenceObject,
    this.fitness,
    this.correctionPlan,
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
      fitness: json['fitness'] != null
          ? Fitness.fromJson(json['fitness'] as Map<String, dynamic>)
          : null,
      correctionPlan: json['correction_plan'] != null
          ? CorrectionPlan.fromJson(
              json['correction_plan'] as Map<String, dynamic>,
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
