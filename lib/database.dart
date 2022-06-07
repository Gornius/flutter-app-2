import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

class Phone {
  int id;
  String name;
  String manufacturer;
  String model;
  String softwareVersion;
  String phoneAvatar;

  Phone({
    required this.id,
    required this.name,
    required this.model,
    required this.manufacturer,
    required this.softwareVersion,
    required this.phoneAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'model': model,
      'softwareVersion': softwareVersion,
      'phoneAvatar': phoneAvatar,
    };
  }

  Map<String, dynamic> toMapNoId() {
    var newMap = toMap();
    newMap.remove('id');

    return newMap;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class PhoneDatabase {
  static const dbFileName = 'phone_database.db';
  static const dbVersion = 1;

  static const tableName = 'phones';
  static const idColumn = 'id';
  static const nameColumn = 'name';
  static const manufacturerColumn = 'manufacturer';
  static const modelColumn = 'model';
  static const softwareVersionColumn = 'softwareVersion';
  static const phoneAvatarColumn = 'phoneAvatar';

  static const createDbSql = 'CREATE TABLE $tableName'
      '($idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      '$nameColumn TEXT,'
      '$manufacturerColumn TEXT,'
      '$modelColumn TEXT,'
      '$softwareVersionColumn TEXT,'
      '$phoneAvatarColumn TEXT)';

  static Future<Database> openPhoneDatabase() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), dbFileName),
      onCreate: (db, version) {
        return db.execute(createDbSql);
      },
      version: dbVersion,
    );
  }

  static Future<void> resetDatabase() async {
    databaseFactory.deleteDatabase(dbFileName);
  }

  static Future<List<Phone>> getPhones() async {
    final phoneDatabase = await openPhoneDatabase();

    final List<Map<String, dynamic>> phoneMapList =
        await phoneDatabase.query(tableName);

    return List.generate(phoneMapList.length, (i) {
      return Phone(
          id: phoneMapList[i][idColumn],
          name: phoneMapList[i][nameColumn],
          model: phoneMapList[i][modelColumn],
          manufacturer: phoneMapList[i][manufacturerColumn],
          softwareVersion: phoneMapList[i][softwareVersionColumn],
          phoneAvatar: phoneMapList[i][phoneAvatarColumn]);
    });
  }

  static Future<int> insertPhone(Phone phone) async {
    final phoneDatabase = await openPhoneDatabase();
    final newItemId = await phoneDatabase.insert(tableName, phone.toMapNoId(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return newItemId;
  }

  static Future<int> modifyPhone(Phone phone) async {
    final phoneDatabase = await openPhoneDatabase();

    await phoneDatabase.update(tableName, phone.toMapNoId(),
        where: "id = ${phone.id}");
    return phone.id;
  }
}
