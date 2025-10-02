import '../../../../core/services/time_service.dart';

class SeasonalIngredient {
  final String id;
  final String name;
  final String imageUrl;
  final List<int>? seasonalMonths;
  final String? peakSeason;
  final Map<String, String> localizedNames;
  final Map<String, String> localizedDescriptions;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String>? culinaryUses;
  final List<String>? availabilityRegions;

  const SeasonalIngredient({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.localizedNames,
    required this.localizedDescriptions,
    this.seasonalMonths,
    this.peakSeason,
    this.nutritionalInfo,
    this.culinaryUses,
    this.availabilityRegions,
  });

  SeasonalIngredient copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<int>? seasonalMonths,
    String? peakSeason,
    Map<String, String>? localizedNames,
    Map<String, String>? localizedDescriptions,
    Map<String, dynamic>? nutritionalInfo,
    List<String>? culinaryUses,
    List<String>? availabilityRegions,
  }) {
    return SeasonalIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      seasonalMonths: seasonalMonths ?? this.seasonalMonths,
      peakSeason: peakSeason ?? this.peakSeason,
      localizedNames: localizedNames ?? this.localizedNames,
      localizedDescriptions: localizedDescriptions ?? this.localizedDescriptions,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      culinaryUses: culinaryUses ?? this.culinaryUses,
      availabilityRegions: availabilityRegions ?? this.availabilityRegions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localizedNames': localizedNames,
      'localizedDescriptions': localizedDescriptions,
      if (seasonalMonths != null) 'seasonalMonths': seasonalMonths,
      if (peakSeason != null) 'peakSeason': peakSeason,
      if (nutritionalInfo != null) 'nutritionalInfo': nutritionalInfo,
      if (culinaryUses != null) 'culinaryUses': culinaryUses,
      if (availabilityRegions != null) 'availabilityRegions': availabilityRegions,
    };
  }

  factory SeasonalIngredient.fromJson(Map<String, dynamic> json) {
    return SeasonalIngredient(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['localizedNames']?['en'] ?? 'Unknown',
      imageUrl: json['imageUrl'] as String,
      localizedNames: Map<String, String>.from(json['localizedNames'] ?? {}),
      localizedDescriptions: Map<String, String>.from(json['localizedDescriptions'] ?? {}),
      seasonalMonths: json['seasonalMonths'] != null 
          ? List<int>.from(json['seasonalMonths']) 
          : null,
      peakSeason: json['peakSeason'] as String?,
      nutritionalInfo: json['nutritionalInfo'] as Map<String, dynamic>?,
      culinaryUses: json['culinaryUses'] != null 
          ? List<String>.from(json['culinaryUses']) 
          : null,
      availabilityRegions: json['availabilityRegions'] != null 
          ? List<String>.from(json['availabilityRegions']) 
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonalIngredient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Check if the ingredient is currently in season using device timezone
  @Deprecated('Use isCurrentlyInSeasonWithTimeService instead')
  bool get isCurrentlyInSeason {
    if (seasonalMonths == null || seasonalMonths!.isEmpty) {
      return true; // If no seasonal data, assume it's always available
    }
    final currentMonth = DateTime.now().month;
    return seasonalMonths!.contains(currentMonth);
  }

  /// Check if the ingredient is currently in season using Sri Lankan timezone
  bool isCurrentlyInSeasonWithTimeService(TimeService timeService) {
    if (seasonalMonths == null || seasonalMonths!.isEmpty) {
      return true; // If no seasonal data, assume it's always available
    }
    final currentMonth = timeService.getCurrentSriLankanMonth();
    return seasonalMonths!.contains(currentMonth);
  }

  /// Check if the ingredient is in peak season using Sri Lankan timezone
  bool isInPeakSeasonWithTimeService(TimeService timeService) {
    if (peakSeason == null || peakSeason!.isEmpty) {
      return false;
    }
    
    final currentMonth = timeService.getCurrentSriLankanMonth();
    final peakSeasonLower = peakSeason!.toLowerCase();
    
    final monthNames = {
      1: 'january',
      2: 'february', 
      3: 'march',
      4: 'april',
      5: 'may',
      6: 'june',
      7: 'july',
      8: 'august',
      9: 'september',
      10: 'october',
      11: 'november',
      12: 'december'
    };

    final currentMonthName = monthNames[currentMonth] ?? '';
    return peakSeasonLower.contains(currentMonthName);
  }

  /// Get seasonality status using Sri Lankan timezone
  SeasonalityStatus getSeasonalityStatus(TimeService timeService) {
    if (!isCurrentlyInSeasonWithTimeService(timeService)) {
      return SeasonalityStatus.outOfSeason;
    }
    
    if (isInPeakSeasonWithTimeService(timeService)) {
      return SeasonalityStatus.peakSeason;
    }
    
    return SeasonalityStatus.inSeason;
  }

  /// Get localized name based on language code with English fallback
  String getLocalizedName(String languageCode) {
    return localizedNames[languageCode] ?? localizedNames['en'] ?? 'Unknown';
  }

  /// Get localized description based on language code with English fallback
  String getLocalizedDescription(String languageCode) {
    return localizedDescriptions[languageCode] ?? localizedDescriptions['en'] ?? 'No description available';
  }

  @override
  String toString() {
    return 'SeasonalIngredient(id: $id, name: $name, inSeason: $isCurrentlyInSeason)';
  }
}

enum SeasonalityStatus {
  outOfSeason,
  inSeason,
  peakSeason,
}