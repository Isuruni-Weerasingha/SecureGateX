class DoorStatusModel {
  final bool isLocked;
  final DateTime? lastChanged;
  final String? changedBy;

  DoorStatusModel({
    required this.isLocked,
    this.lastChanged,
    this.changedBy,
  });

  DoorStatusModel copyWith({
    bool? isLocked,
    DateTime? lastChanged,
    String? changedBy,
  }) {
    return DoorStatusModel(
      isLocked: isLocked ?? this.isLocked,
      lastChanged: lastChanged ?? this.lastChanged,
      changedBy: changedBy ?? this.changedBy,
    );
  }
}

