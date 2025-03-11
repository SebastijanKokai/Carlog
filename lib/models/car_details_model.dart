import 'package:cloud_firestore/cloud_firestore.dart';

class CarDetails {
  final String id;
  final String ownerName;
  final String? licensePlate;
  final String? city;
  final String? address;
  final String? make;
  final String? model;
  final String? chassisNumber;
  final String? engineDisplacement;
  final String? enginePower;
  final String? typeOfFuel;
  final String? seatNumber;
  final String? repairNotes;
  final String userId;

  CarDetails({
    required this.id,
    required this.ownerName,
    this.licensePlate,
    this.city,
    this.address,
    this.make,
    this.model,
    this.chassisNumber,
    this.engineDisplacement,
    this.enginePower,
    this.typeOfFuel,
    this.seatNumber,
    this.repairNotes,
    required this.userId,
  });

  factory CarDetails.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return CarDetails(
      id: snapshot.id,
      ownerName: data?['ownerName'] ?? '',
      licensePlate: data?['licensePlate'] ?? '',
      city: data?['city'] ?? '',
      address: data?['address'] ?? '',
      make: data?['make'] ?? '',
      model: data?['model'] ?? '',
      chassisNumber: data?['chassisNumber'] ?? '',
      engineDisplacement: data?['engineDisplacement'] ?? '',
      enginePower: data?['enginePower'] ?? '',
      typeOfFuel: data?['typeOfFuel'] ?? '',
      seatNumber: data?['seatNumber'] ?? '',
      repairNotes: data?['repairNotes'] ?? '',
      userId: data?['userId'] ?? '',
    );
  }

  factory CarDetails.fromAzureAnalysis(Map<String, dynamic> json, {String id = ''}) {
    final documents = json['analyzeResult']['documents'] as List;
    if (documents.isEmpty) {
      throw Exception('No documents found in analysis result');
    }

    final fields = documents[0]['fields'] as Map<String, dynamic>;

    // Combine first name and last name for owner name
    final firstName = fields['first_name']?['valueString'] ?? '';
    final lastName = fields['last_name']?['valueString'] ?? '';
    final ownerName = [lastName, firstName].where((s) => s.isNotEmpty).join(' ');

    return CarDetails(
      id: id,
      ownerName: ownerName,
      make: fields['car_make']?['valueString'] ?? '',
      model: fields['car_model']?['valueString'] ?? '',
      chassisNumber: fields['chassis_number']?['valueString'] ?? '',
      engineDisplacement: fields['engine_displacement']?['valueString'] ?? '',
      enginePower: fields['engine_power']?['valueString'] ?? '',
      typeOfFuel: fields['type_of_fuel']?['valueString'] ?? '',
      licensePlate: fields['license_plate']?['valueString'] ?? '',
      city: fields['city']?['valueString'] ?? '',
      address: fields['address']?['valueString'] ?? '',
      userId: '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (ownerName.isNotEmpty) 'ownerName': ownerName,
      if (ownerName.isNotEmpty) 'ownerName_insensitive': ownerName.toLowerCase(),
      if (licensePlate != null) 'licensePlate': licensePlate,
      if (licensePlate != null) 'licensePlate_insensitive': licensePlate!.toLowerCase(),
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (chassisNumber != null) 'chassisNumber': chassisNumber,
      if (engineDisplacement != null) 'engineDisplacement': engineDisplacement,
      if (enginePower != null) 'enginePower': enginePower,
      if (typeOfFuel != null) 'typeOfFuel': typeOfFuel,
      if (seatNumber != null) 'seatNumber': seatNumber,
      if (repairNotes != null) 'repairNotes': repairNotes,
      'userId': userId,
    };
  }

  CarDetails copyWith({
    String? id,
    String? ownerName,
    String? licensePlate,
    String? city,
    String? address,
    String? make,
    String? model,
    String? chassisNumber,
    String? engineDisplacement,
    String? enginePower,
    String? typeOfFuel,
    String? seatNumber,
    String? repairNotes,
    String? userId,
  }) {
    return CarDetails(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      licensePlate: licensePlate ?? this.licensePlate,
      city: city ?? this.city,
      address: address ?? this.address,
      make: make ?? this.make,
      model: model ?? this.model,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineDisplacement: engineDisplacement ?? this.engineDisplacement,
      enginePower: enginePower ?? this.enginePower,
      typeOfFuel: typeOfFuel ?? this.typeOfFuel,
      seatNumber: seatNumber ?? this.seatNumber,
      repairNotes: repairNotes ?? this.repairNotes,
      userId: userId ?? this.userId,
    );
  }
}
