class Maintenance {
  final int? id;
  final int vehicleId;
  final String serviceType;
  final String description;
  final DateTime serviceDate;
  final double cost;
  final int mileage;
  final String? notes;
  final String createdAt;

  Maintenance({
    this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.description,
    required this.serviceDate,
    required this.cost,
    required this.mileage,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'serviceDate': serviceDate.toIso8601String(),
      'cost': cost,
      'mileage': mileage,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      vehicleId: map['vehicleId'],
      serviceType: map['serviceType'],
      description: map['description'],
      serviceDate: DateTime.parse(map['serviceDate']),
      cost: map['cost'].toDouble(),
      mileage: map['mileage'],
      notes: map['notes'],
      createdAt: map['createdAt'],
    );
  }

  Maintenance copyWith({
    int? id,
    int? vehicleId,
    String? serviceType,
    String? description,
    DateTime? serviceDate,
    double? cost,
    int? mileage,
    String? notes,
    String? createdAt,
  }) {
    return Maintenance(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      cost: cost ?? this.cost,
      mileage: mileage ?? this.mileage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
