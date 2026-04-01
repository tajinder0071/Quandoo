import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/booking.dart';

class DatabaseHelper {
  static const _dbName    = 'tablelux.db';
  static const _dbVersion = 1;

  // Table names
  static const tUsers      = 'users';
  static const tBookings   = 'bookings';
  static const tFavourites = 'favourites';
  static const tSessions   = 'sessions';

  static Database? _db;

  // ── Singleton ──────────────────────────────────────────────────────────────
  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ── Users ──────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE $tUsers (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        password_hash TEXT    NOT NULL,
        created_at    TEXT    NOT NULL
      )
    ''');

    // ── Bookings ───────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE $tBookings (
        id              TEXT    PRIMARY KEY,
        user_id         INTEGER NOT NULL,
        restaurant_id   TEXT    NOT NULL,
        restaurant_name TEXT    NOT NULL,
        restaurant_image TEXT   NOT NULL,
        date            TEXT    NOT NULL,
        time_slot       TEXT    NOT NULL,
        guests          INTEGER NOT NULL,
        table_type      TEXT    NOT NULL,
        status          TEXT    NOT NULL DEFAULT 'active',
        guest_name      TEXT    NOT NULL,
        total_amount    REAL    NOT NULL,
        special_request TEXT,
        booked_at       TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tUsers(id) ON DELETE CASCADE
      )
    ''');

    // ── Favourites ─────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE $tFavourites (
        user_id         INTEGER NOT NULL,
        restaurant_id   TEXT    NOT NULL,
        added_at        TEXT    NOT NULL,
        PRIMARY KEY (user_id, restaurant_id),
        FOREIGN KEY (user_id) REFERENCES $tUsers(id) ON DELETE CASCADE
      )
    ''');

    // ── Sessions (persists login across app restarts) ──────────────
    await db.execute('''
      CREATE TABLE $tSessions (
        id         INTEGER PRIMARY KEY CHECK (id = 1),
        user_id    INTEGER NOT NULL,
        created_at TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tUsers(id) ON DELETE CASCADE
      )
    ''');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Auth helpers
  // ────────────────────────────────────────────────────────────────────────────

  static String _hashPassword(String password) {
    final bytes  = utf8.encode(password + 'tablelux_salt_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new user. Returns the created [UserModel] or null if
  /// the email is already taken.
  static Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;

    // Check duplicate email
    final existing = await db.query(
      tUsers,
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existing.isNotEmpty) return null;

    final user = UserModel(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    final id = await db.insert(tUsers, user.toMap());
    return user.copyWith(id: id);
  }

  /// Sign in. Returns the [UserModel] on success or null on bad credentials.
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final db   = await database;
    final hash = _hashPassword(password);

    final rows = await db.query(
      tUsers,
      where: 'LOWER(email) = ? AND password_hash = ?',
      whereArgs: [email.toLowerCase().trim(), hash],
    );

    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Booking helpers
  // ────────────────────────────────────────────────────────────────────────────

  static Future<void> insertBooking(Booking b, int userId) async {
    final db = await database;
    await db.insert(
      tBookings,
      {
        'id'               : b.id,
        'user_id'          : userId,
        'restaurant_id'    : b.restaurantId,
        'restaurant_name'  : b.restaurantName,
        'restaurant_image' : b.restaurantImage,
        'date'             : b.date.toIso8601String(),
        'time_slot'        : b.timeSlot,
        'guests'           : b.guests,
        'table_type'       : b.tableType,
        'status'           : b.status.name,
        'guest_name'       : b.guestName,
        'total_amount'     : b.totalAmount,
        'special_request'  : b.specialRequest,
        'booked_at'        : b.bookedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Booking>> getBookingsForUser(int userId) async {
    final db   = await database;
    final rows = await db.query(
      tBookings,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'booked_at DESC',
    );
    return rows.map(_bookingFromMap).toList();
  }

  static Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    final db = await database;
    await db.update(
      tBookings,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  static Booking _bookingFromMap(Map<String, dynamic> m) => Booking(
    id              : m['id']               as String,
    restaurantId    : m['restaurant_id']    as String,
    restaurantName  : m['restaurant_name']  as String,
    restaurantImage : m['restaurant_image'] as String,
    date            : DateTime.parse(m['date'] as String),
    timeSlot        : m['time_slot']        as String,
    guests          : m['guests']           as int,
    tableType       : m['table_type']       as String,
    status          : BookingStatus.values.firstWhere(
            (s) => s.name == m['status']),
    guestName       : m['guest_name']       as String,
    totalAmount     : (m['total_amount'] as num).toDouble(),
    specialRequest  : m['special_request']  as String?,
    bookedAt        : DateTime.parse(m['booked_at'] as String),
  );

  // ────────────────────────────────────────────────────────────────────────────
  // Favourites helpers
  // ────────────────────────────────────────────────────────────────────────────

  static Future<void> addFavourite(int userId, String restaurantId) async {
    final db = await database;
    await db.insert(
      tFavourites,
      {
        'user_id'       : userId,
        'restaurant_id' : restaurantId,
        'added_at'      : DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> removeFavourite(int userId, String restaurantId) async {
    final db = await database;
    await db.delete(
      tFavourites,
      where: 'user_id = ? AND restaurant_id = ?',
      whereArgs: [userId, restaurantId],
    );
  }

  static Future<Set<String>> getFavouriteIds(int userId) async {
    final db   = await database;
    final rows = await db.query(
      tFavourites,
      columns: ['restaurant_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['restaurant_id'] as String).toSet();
  }

  // ── Session persistence ────────────────────────────────────────────────────

  /// Save the logged-in user's ID so the app remembers it on restart.
  static Future<void> saveSession(int userId) async {
    final db = await database;
    // id = 1 constraint means only one row ever exists (INSERT OR REPLACE)
    await db.insert(
      tSessions,
      {'id': 1, 'user_id': userId, 'created_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns the full [UserModel] for the saved session, or null if none.
  static Future<UserModel?> getActiveSession() async {
    final db   = await database;
    final sess = await db.query(tSessions, where: 'id = 1');
    if (sess.isEmpty) return null;

    final userId = sess.first['user_id'] as int;
    final rows   = await db.query(tUsers, where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// Clears the saved session (called on logout).
  static Future<void> clearSession() async {
    final db = await database;
    await db.delete(tSessions, where: 'id = 1');
  }

  // ── Utility ────────────────────────────────────────────────────────────────
  static Future<void> close() async => (await database).close();
}