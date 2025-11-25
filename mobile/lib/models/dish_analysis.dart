class DishAnalysis {
  final String dishName;
  final double estimatedPortionGrams;
  final double calories;
  final List<String> tags;

  DishAnalysis({
    required this.dishName,
    required this.estimatedPortionGrams,
    required this.calories,
    required this.tags,
  });

  factory DishAnalysis.fromJson(Map<String, dynamic> json) {
    return DishAnalysis(
      dishName: json['dishName'] as String,
      estimatedPortionGrams: (json['estimatedPortionGrams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
