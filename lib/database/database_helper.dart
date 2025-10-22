import 'package:path/path.dart';		
import 'package:sqflite/sqflite.dart';	
import 'models/vehicle.dart';
import 'models/maintenance.dart';
import 'models/reminder.dart';

class DatabaseHelper {	
  static const _databaseName = "VehicleDatabase.db";	
  static const _databaseVersion = 3;	

  static const table = 'vehicles';
  static const maintenanceTable = 'maintenance';
  static const reminderTable = 'reminders';

  static const columnId = 'id';	
  static const columnVin = 'vin';	
  static const columnMake = 'make';
  static const columnModel = 'model';
  static const columnYear = 'year';
  static const columnCar = 'car';
  static const columnMileage = 'mileage';
  static const columnLastMaintenanceService = 'lastMaintenanceService';
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
      onUpgrade: _onUpgrade,
    );	
  }	

  // SQL code to create the database table	
  Future _onCreate(Database db, int version) async {	
    // Create vehicles table
    await db.execute('''	
          CREATE TABLE $table (	
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,	
            $columnVin TEXT UNIQUE NOT NULL,	
            $columnMake TEXT NOT NULL,
            $columnModel TEXT NOT NULL,
            $columnYear TEXT NOT NULL,
            $columnCar TEXT NOT NULL,
            $columnMileage TEXT,
            $columnLastMaintenanceService TEXT,
            $columnCreatedAt TEXT NOT NULL
          )	
          ''');
    
    // Create maintenance table
    await db.execute('''
          CREATE TABLE $maintenanceTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicleId INTEGER NOT NULL,
            serviceType TEXT NOT NULL,
            description TEXT NOT NULL,
            serviceDate TEXT NOT NULL,
            cost REAL NOT NULL,
            mileage INTEGER NOT NULL,
            notes TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (vehicleId) REFERENCES $table (id)
          )
          ''');
    
    // Create reminders table
    await db.execute('''
          CREATE TABLE $reminderTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicleId INTEGER NOT NULL,
            serviceType TEXT NOT NULL,
            description TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            mileageInterval INTEGER NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            notes TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (vehicleId) REFERENCES $table (id)
          )
          ''');	
  }	

  // Database migration when version changes
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for mileage and lastMaintenanceService
      await db.execute('ALTER TABLE $table ADD COLUMN $columnMileage TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnLastMaintenanceService TEXT');
    }
    if (oldVersion < 3) {
      // Create maintenance table
      await db.execute('''
            CREATE TABLE $maintenanceTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicleId INTEGER NOT NULL,
              serviceType TEXT NOT NULL,
              description TEXT NOT NULL,
              serviceDate TEXT NOT NULL,
              cost REAL NOT NULL,
              mileage INTEGER NOT NULL,
              notes TEXT,
              createdAt TEXT NOT NULL,
              FOREIGN KEY (vehicleId) REFERENCES $table (id)
            )
            ''');
      
      // Create reminders table
      await db.execute('''
            CREATE TABLE $reminderTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicleId INTEGER NOT NULL,
              serviceType TEXT NOT NULL,
              description TEXT NOT NULL,
              dueDate TEXT NOT NULL,
              mileageInterval INTEGER NOT NULL,
              isCompleted INTEGER NOT NULL DEFAULT 0,
              notes TEXT,
              createdAt TEXT NOT NULL,
              FOREIGN KEY (vehicleId) REFERENCES $table (id)
            )
            ''');
    }
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

  // Deletes a vehicle by id and all associated maintenance records and reminders
  Future<int> deleteVehicle(int id) async {
    // Delete associated maintenance records first
    await _db.delete(
      maintenanceTable,
      where: 'vehicleId = ?',
      whereArgs: [id],
    );
    
    // Delete associated reminders
    await _db.delete(
      reminderTable,
      where: 'vehicleId = ?',
      whereArgs: [id],
    );
    
    // Finally delete the vehicle
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

  // MAINTENANCE METHODS

  // Insert maintenance record
  Future<int> insertMaintenance(Maintenance maintenance) async {
    return await _db.insert(maintenanceTable, maintenance.toMap());
  }

  // Get all maintenance records for a vehicle
  Future<List<Maintenance>> getMaintenanceByVehicleId(int vehicleId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      maintenanceTable,
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'serviceDate DESC',
    );
    return List.generate(maps.length, (i) => Maintenance.fromMap(maps[i]));
  }

  // Get all maintenance records
  Future<List<Maintenance>> getAllMaintenance() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      maintenanceTable,
      orderBy: 'serviceDate DESC',
    );
    return List.generate(maps.length, (i) => Maintenance.fromMap(maps[i]));
  }

  // Update maintenance record
  Future<int> updateMaintenance(Maintenance maintenance) async {
    return await _db.update(
      maintenanceTable,
      maintenance.toMap(),
      where: 'id = ?',
      whereArgs: [maintenance.id],
    );
  }

  // Delete maintenance record
  Future<int> deleteMaintenance(int id) async {
    return await _db.delete(
      maintenanceTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total maintenance cost for a vehicle
  Future<double> getTotalMaintenanceCost(int vehicleId) async {
    final result = await _db.rawQuery(
      'SELECT SUM(cost) as total FROM $maintenanceTable WHERE vehicleId = ?',
      [vehicleId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // REMINDER METHODS

  // Insert reminder
  Future<int> insertReminder(Reminder reminder) async {
    return await _db.insert(reminderTable, reminder.toMap());
  }

  // Get all reminders for a vehicle
  Future<List<Reminder>> getRemindersByVehicleId(int vehicleId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      reminderTable,
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  // Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      reminderTable,
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  // Get overdue reminders
  Future<List<Reminder>> getOverdueReminders() async {
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await _db.query(
      reminderTable,
      where: 'dueDate < ? AND isCompleted = 0',
      whereArgs: [now],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  // Get upcoming reminders (next 7 days)
  Future<List<Reminder>> getUpcomingReminders() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final List<Map<String, dynamic>> maps = await _db.query(
      reminderTable,
      where: 'dueDate BETWEEN ? AND ? AND isCompleted = 0',
      whereArgs: [now.toIso8601String(), nextWeek.toIso8601String()],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  // Update reminder
  Future<int> updateReminder(Reminder reminder) async {
    return await _db.update(
      reminderTable,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Delete reminder
  Future<int> deleteReminder(int id) async {
    return await _db.delete(
      reminderTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark reminder as completed
  Future<int> markReminderCompleted(int id) async {
    return await _db.update(
      reminderTable,
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}	