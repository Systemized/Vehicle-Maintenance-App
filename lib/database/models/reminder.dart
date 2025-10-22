class Reminder {
  final int? id;
  final int vehicleId;
  final String serviceType;
  final String description;
  final DateTime dueDate;
  final int mileageInterval;
  final bool isCompleted;
  final String? notes;
  final String createdAt;

  Reminder({
    this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.description,
    required this.dueDate,
    required this.mileageInterval,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'mileageInterval': mileageInterval,
      'isCompleted': isCompleted ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      vehicleId: map['vehicleId'],
      serviceType: map['serviceType'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      mileageInterval: map['mileageInterval'],
      isCompleted: map['isCompleted'] == 1,
      notes: map['notes'],
      createdAt: map['createdAt'],
    );
  }

  Reminder copyWith({
    int? id,
    int? vehicleId,
    String? serviceType,
    String? description,
    DateTime? dueDate,
    int? mileageInterval,
    bool? isCompleted,
    String? notes,
    String? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      mileageInterval: mileageInterval ?? this.mileageInterval,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && !isCompleted;
  }

  bool get isDueSoon {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0 && !isCompleted;
  }
}
