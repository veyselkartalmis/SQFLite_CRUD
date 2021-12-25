// ignore_for_file: unused_field, prefer_const_declarations, unnecessary_null_comparison, unused_local_variable

import 'dart:async';
import 'package:flutter_sqflite/models/car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;
  static final table = "cars_table";
  static final columnId = "id";
  static final columnName = "name";
  static final columnMiles = "miles";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database?> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnMiles INTEGER NOT NULL
    )
    ''');
  }

  Future<int> insert(Car car) async {
    Database? db = await instance.database;
    return await db!.insert(table, {"name": car.name, "miles": car.miles});
  }

  Future<int> update(Car car) async {
    Database? db = await instance.database;
    int id = car.toMap()["id"];
    return await db!
        .update(table, car.toMap(), where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryRows(name) async {
    Database? db = await instance.database;
    return await db!.query(table, where: "$columnName LIKE '%$name%'");
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }
}