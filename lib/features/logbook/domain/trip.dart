class Trip {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistanceNm;
  final double maxSpeedKnots;
  final double avgSpeedKnots;
  final int totalPointsCount;
  final String vesselName;
  final String? gpxCloudKey;
  final bool isSynced;
  final String? notes;

  const Trip({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.totalDistanceNm = 0.0,
    this.maxSpeedKnots = 0.0,
    this.avgSpeedKnots = 0.0,
    this.totalPointsCount = 0,
    required this.vesselName,
    this.gpxCloudKey,
    this.isSynced = false,
    this.notes,
  });

  bool get isActive => endTime == null;

  Duration get duration {
    final finish = endTime ?? DateTime.now();
    return finish.difference(startTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_distance_nm': totalDistanceNm,
      'max_speed_knots': maxSpeedKnots,
      'avg_speed_knots': avgSpeedKnots,
      'total_points_count': totalPointsCount,
      'vessel_name': vesselName,
      'gpx_cloud_key': gpxCloudKey,
      'is_synced': isSynced ? 1 : 0,
      'notes': notes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      totalDistanceNm: (map['total_distance_nm'] as num?)?.toDouble() ?? 0.0,
      maxSpeedKnots: (map['max_speed_knots'] as num?)?.toDouble() ?? 0.0,
      avgSpeedKnots: (map['avg_speed_knots'] as num?)?.toDouble() ?? 0.0,
      totalPointsCount: (map['total_points_count'] as num?)?.toInt() ?? 0,
      vesselName: map['vessel_name'] as String? ?? 'Bilinmeyen Tekne',
      gpxCloudKey: map['gpx_cloud_key'] as String?,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }

  Trip copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistanceNm,
    double? maxSpeedKnots,
    double? avgSpeedKnots,
    int? totalPointsCount,
    String? vesselName,
    String? gpxCloudKey,
    bool? isSynced,
    String? notes,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistanceNm: totalDistanceNm ?? this.totalDistanceNm,
      maxSpeedKnots: maxSpeedKnots ?? this.maxSpeedKnots,
      avgSpeedKnots: avgSpeedKnots ?? this.avgSpeedKnots,
      totalPointsCount: totalPointsCount ?? this.totalPointsCount,
      vesselName: vesselName ?? this.vesselName,
      gpxCloudKey: gpxCloudKey ?? this.gpxCloudKey,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }
}
