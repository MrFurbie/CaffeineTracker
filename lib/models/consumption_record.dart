class ConsumptionRecord {
  final String id;
  final String drinkId;
  final String servingSizeId;
  final DateTime timestamp;
  final int caffeineAmount;
  final String? notes;

  ConsumptionRecord({
    required this.id,
    required this.drinkId,
    required this.servingSizeId,
    required this.timestamp,
    required this.caffeineAmount,
    this.notes,
  });

  factory ConsumptionRecord.create({
    required String drinkId,
    required String servingSizeId,
    DateTime? timestamp,
    required int caffeineAmount,
    String? notes,
  }) {
    return ConsumptionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      drinkId: drinkId,
      servingSizeId: servingSizeId,
      timestamp: timestamp ?? DateTime.now(),
      caffeineAmount: caffeineAmount,
      notes: notes,
    );
  }

  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateString {
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drinkId': drinkId,
      'servingSizeId': servingSizeId,
      'timestamp': timestamp.toIso8601String(),
      'caffeineAmount': caffeineAmount,
      'notes': notes,
    };
  }

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) {
    return ConsumptionRecord(
      id: json['id'],
      drinkId: json['drinkId'],
      servingSizeId: json['servingSizeId'],
      timestamp: DateTime.parse(json['timestamp']),
      caffeineAmount: json['caffeineAmount'],
      notes: json['notes'],
    );
  }
}