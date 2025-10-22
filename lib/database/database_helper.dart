import 'package:path/path.dart';		
import 'package:sqflite/sqflite.dart';	
import 'models/vehicle.dart';

class DatabaseHelper {	
  static const _databaseName = "VehicleDatabase.db";	
  static const _databaseVersion = 1;	

  static const table = 'vehicles';	

  static const columnId = 'id';	
  static const columnVin = 'vin';	
  static const columnMake = 'make';
  static const columnModel = 'model';
  static const columnYear = 'year';
  static const columnCar = 'car';
  static const columnCreatedAt = 'createdAt';

  late Database _db;	

  // this opens the database (and creates it if it doesn't exist)	
  Future<void> init() async {	
    final databasesPath = await getDatabasesPath();	
    final path = join(databasesPath, _databaseName);	
    _db = await openDatabase(	
      path,	
      version: _databaseVersion,	
      onCreate: _onCreate,	
    );	
  }	

  // SQL code to create the database table	
  Future _onCreate(Database db, int version) async {	
    await db.execute('''	
          CREATE TABLE $table (	
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,	
            $columnVin TEXT UNIQUE NOT NULL,	
            $columnMake TEXT NOT NULL,
            $columnModel TEXT NOT NULL,
            $columnYear TEXT NOT NULL,
            $columnCar TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL
          )	
          ''');	
  }	

  // Helper methods	

  // Inserts a vehicle in the database
  Future<int> insertVehicle(Vehicle vehicle) async {	
    try {
      return await _db.insert(table, vehicle.toMap());	
    } catch (e) {
      throw Exception('Vehicle with this VIN already exists');
    }
  }	

  // Gets all vehicles from the database
  Future<List<Vehicle>> getAllVehicles() async {	
    final List<Map<String, dynamic>> maps = await _db.query(table, orderBy: '$columnCreatedAt DESC');
    return List.generate(maps.length, (i) => Vehicle.fromMap(maps[i]));
  }	

  // Gets a vehicle by VIN
  Future<Vehicle?> getVehicleByVin(String vin) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      table,
      where: '$columnVin = ?',
      whereArgs: [vin],
    );
    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  // Gets the count of vehicles
  Future<int> getVehicleCount() async {	
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');	
    return Sqflite.firstIntValue(results) ?? 0;	
  }	

  // Updates a vehicle
  Future<int> updateVehicle(Vehicle vehicle) async {	
    return await _db.update(	
      table,	
      vehicle.toMap(),	
      where: '$columnId = ?',	
      whereArgs: [vehicle.id],	
    );	
  }	

  // Deletes a vehicle by id
  Future<int> deleteVehicle(int id) async {	
    return await _db.delete(	
      table,	
      where: '$columnId = ?',	
      whereArgs: [id],	
    );	
  }

  // Closes the database
  Future<void> close() async {
    await _db.close();
  }	
}	