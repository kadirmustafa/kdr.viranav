import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:viranav/features/logbook/domain/trip.dart';
import 'package:viranav/features/logbook/domain/gps_track_point.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'viranav_marine.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE trips (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT,
            total_distance_nm REAL DEFAULT 0.0,
            max_speed_knots REAL DEFAULT 0.0,
            avg_speed_knots REAL DEFAULT 0.0,
            total_points_count INTEGER DEFAULT 0,
            vessel_name TEXT NOT NULL,
            gpx_cloud_key TEXT,
            is_synced INTEGER DEFAULT 0,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE gps_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            speed_knots REAL NOT NULL,
            course_deg REAL NOT NULL,
            altitude REAL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_gps_trip_id ON gps_points (trip_id)',
        );
      },
    );
  }

  // Trips CRUD
  Future<void> insertTrip(Trip trip) async {
    final db = await database;
    await db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await database;
    await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<Trip?> getTrip(String id) async {
    final db = await database;
    final maps = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Trip.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Trip>> getAllTrips() async {
    final db = await database;
    final maps = await db.query('trips', orderBy: 'start_time DESC');
    return maps.map((m) => Trip.fromMap(m)).toList();
  }

  Future<void> deleteTrip(String id) async {
    final db = await database;
    await db.delete('gps_points', where: 'trip_id = ?', whereArgs: [id]);
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  // GPS Points
  Future<void> insertPoint(GpsTrackPoint point) async {
    final db = await database;
    await db.insert('gps_points', point.toMap());
  }

  Future<List<GpsTrackPoint>> getPointsForTrip(String tripId) async {
    final db = await database;
    final maps = await db.query(
      'gps_points',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => GpsTrackPoint.fromMap(m)).toList();
  }

  Future<int> getPointCountForTrip(String tripId) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM gps_points WHERE trip_id = ?',
      [tripId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }
}
