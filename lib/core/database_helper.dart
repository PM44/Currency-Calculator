import 'dart:async';

import 'package:currency_converter/data/model/currency.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static String currencyTable = 'currency_table';
  static String key = 'currencyCode';
  static String value = 'currencyName';
  static String conversionRate = 'conversionRate';

  static Future<Database> initDB() async {
    var dbPath = await getDatabasesPath();
    String path = '${dbPath}currencyDatabase.db';
    return await openDatabase(path, version: 2, onCreate: _createDb);
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $currencyTable($key STRING PRIMARY KEY, $value STRING,$conversionRate DOUBLE )');
  }

  static Future<List<Currency>> getCurrencyList() async {
    Database db = await DatabaseHelper.initDB();
    var result = await db.query(currencyTable);
    List<Currency> currencyList = result.isNotEmpty
        ? result.map((details) => Currency.fromJson(details)).toList()
        : [];
    return currencyList;
  }

  static Future<num?> getConversionRate(String countryCode) async {
    Database db = await DatabaseHelper.initDB();
    var result = await db.query(currencyTable);
    for (int i = 0; i < result.length; i++) {
      Currency detail = Currency.fromJson(result[i]);
      if (detail.currencyCode == countryCode) {
        return detail.conversionRate;
      }
    }
    return -1;
  }

  static Future<int> insertCurrencyList(List<Currency> currency) async {
    Database db = await DatabaseHelper.initDB();
    int result = -1;
    for (int i = 0; i < currency.length; i++) {
      result = await db.insert(currencyTable, currency[i].toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return result;
  }
}
