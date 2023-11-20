// import 'dart:io';
//
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class QualityFoodsDBCursor {
//   // List<Map> getAllData(List<Map> thelist){
//   //   return thelist;
//   // }
//
//   Future<List<Map>> getAllData() async {
//     var databasePath = await getDatabasesPath();
//     print(databasePath);
//     var dbPath = join(databasePath, "testa.db");
//     var db = await openDatabase(dbPath);
//     List<Map> list = await db.rawQuery('SELECT * FROM cart');
//     // list.forEach((item){
//     //   print(item);
//     // });
//
//     return list;
//   }
//
//   void insertCart(String name, String image, String variant_array, int qty,
//       int price) async {
//     var databasePath = await getDatabasesPath();
//     print(databasePath);
//     var dbPath = join(databasePath, "testa.db");
//     var db = await openDatabase(dbPath);
//
//     var jsonValue = {'name': 'something', 'age': 'something'};
//
//     String encodeJson = jsonValue.toString();
//
//     var insertop = db.rawInsert(
//         """INSERT INTO cart('name' , 'image' , 'variant_array', 'qty', 'price') VALUES('$name', '$image', '$encodeJson', $qty, $price)""");
//     print("Data inserted...");
//   }
//
//   void dropCartTable() async {
//     var databasePath = await getDatabasesPath();
//     print(databasePath);
//     var dbPath = join(databasePath, "testa.db");
//     var db = await openDatabase(dbPath);
//
//     // db.rawQuery("DROP TABLE Test");
//
//     databaseFactory.deleteDatabase(dbPath);
//     print("Table and Database Deleted");
//   }
// }
//
// class DatabaseHelper {
//   static final _databaseName = "MainDatabase.db";
//   static final _databaseVersion = 3;
//   static final table = 'cart';
//   static final columnId = 'id';
//   static final columnProductUniqueId = 'product_id';
//   static final columnVarientUniqueId = 'variant_id';
//   static final columnName = 'name';
//   static final columnImage = 'image';
//   static final columnVariantArray = 'variant_array';
//   static final columnVariant = 'variant';
//   static final columnQuantity = 'quantity';
//   static final columnPrice = 'price';
//   static final columnTotalAmount = 'total_amount';
//   static final columnProductQty = "product_quantity";
//
//   // make this a singleton class
//   DatabaseHelper._privateConstructor();
//
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//   // only have a single app-wide reference to the database
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     // lazily instantiate the db the first time it is accessed
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   // this opens the database (and creates it if it doesn't exist)
//   _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, _databaseName);
//     print("Database connected!");
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }
//
//   // SQL code to create the database table
//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//           CREATE TABLE $table (
//             $columnId INTEGER PRIMARY KEY NOT NULL,
//             $columnProductUniqueId INTEGER NOT NULL,
//             $columnVarientUniqueId INTEGER,
//             $columnName TEXT NOT NULL,
//             $columnImage TEXT NOT NULL,
//             $columnVariantArray TEXT,
//             $columnVariant TEXT,
//             $columnQuantity INTEGER NOT NULL,
//             $columnPrice INTEGER NOT NULL,
//             $columnTotalAmount INTEGER NOT NULL,
//             $columnProductQty INTEGER NOT NULL)''');
//     print("Table $table created...");
//   }
//
//   // Helper methods
//
//   // Inserts a row in the database where each key in the Map is a column name
//   // and the value is the column value. The return value is the id of the
//   // inserted row.
//   Future<int> insert(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     String id = row[columnProductUniqueId].toString();
//     // print(await db.query(table, where: '$columnProductUniqueId = ?', whereArgs: [id]));
//     List<Map> data = await db
//         .query(table, where: '$columnProductUniqueId = ?', whereArgs: [id]);
//     print("Number of already same value found? : " + data.length.toString());
//     if (data.length > 0) {
//       // Data
//       return 0;
//     } else {
//       return await db.insert(table, row);
//     }
//   }
//
//   // All of the rows are returned as a list of maps, where each map is
//   // a key-value list of columns.
//   Future<List<Map>> queryAllRows() async {
//     Database db = await instance.database;
//     return await db.query(table);
//   }
//   Future<List<Map>> getIds() async {
//     Database db = await instance.database;
//     return await db.query(table,columns: [columnProductUniqueId]);
//   }
//   Future<Map<String, dynamic>> getSingleProduct(int id) async {
//     Database db = await instance.database;
//     final maps = await db.query(table, where: '_id = ?', whereArgs: [id]);
//     return maps[0];
//   }
//
//   // Future<int> tableCount() async {
//   //   Database db = await instance.database;
//   //   final rowcount = await this.queryAllRows();
//   //   return rowcount.length;
//   // }
//
//   // All of the methods (insert, query, update, delete) can also be done using
//   // raw SQL commands. This method uses a raw query to give the row count.
//   // Future<int> queryRowCount() async {
//   //   Database db = await instance.database;
//   //   return await db.query('SELECT COUNT(*) FROM $table');
//   // }
//
//   // Future<List<Map>> deleteDb() async {
//   //   Database db = await instance.database;
//   //   return db.query("DROP DATABASE $_databaseName");
//   // }
//
//   Future<bool> isProductExist(int id) async {
//     Database db = await instance.database;
//     var result = await db
//         .rawQuery('SELECT EXISTS(SELECT 1 FROM cart WHERE product_id="$id")');
//     int? exists = Sqflite.firstIntValue(result);
//     return exists == 1;
//   }
//
//   Future<String> getQty(int id) async {
//     Database db = await instance.database;
//     var result =
//         await db.rawQuery("SELECT quantity FROM cart WHERE product_id='$id'");
//     return result[0]['quantity'].toString();
//   }
//
//   // We are assuming here that the id column in the map is set. The other
//   // column values will be used to update the row.
//   Future<int> update(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     int id = row[columnProductUniqueId];
//     print(id);
//     return await db.update(table, row,
//         where: '$columnProductUniqueId = ?', whereArgs: [id]);
//   }
//
//   // update item
//
//   static Future<int> updateItem(int idd, String name, String brand,
//       String image, String price, String actualPrice, int counter) async {
//     var db = await instance.database;
//     var data = {
//       'idd': idd,
//       'name': name,
//       'brand': brand,
//       'image': image,
//       'price': price,
//       'actualPrice': actualPrice,
//       'counter': counter,
//     };
//     var result =
//         await db.update('items', data, where: "idd = ?", whereArgs: [idd]);
//     return result;
//   }
//
//   //insert data into databse
//
//   // Deletes the row specified by the id. The number of affected rows is
//   // returned. This should be 1 as l // static Future<int> createItem(int idd, String name, String brand,
//   //   //     String image, String price, String actualPrice, int counter) async {
//   //   //   var db = await instance.database;
//   //   //   var data = {
//   //   //     'idd': idd,
//   //   //     'name': name,
//   //   //     'brand': brand,
//   //   //     'image': image,
//   //   //     'price': price,
//   //   //     'actualPrice': actualPrice,
//   //   //     'counter': counter,
//   //   //   };
//   //   //   var id = await db.insert('items', data,
//   //   //       conflictAlgorithm: sql.ConflictAlgorithm.replace);
//   //   //   return id;
//   //   // }ong as the row exists.
//   Future<int> deleteWhereProductUniwueId(String id) async {
//     Database db = await instance.database;
//     return await db
//         .delete(table, where: '$columnProductUniqueId = ?', whereArgs: [id]);
//   }
//
//   Future<int> delete(String id) async {
//     Database db = await instance.database;
//     return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   }
//
//   Future<int> clear() async {
//     Database db = await instance.database;
//     return await db.delete(table);
//   }
// }
