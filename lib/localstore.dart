import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class Store {
  int totalPrice = 0;
  int getalltotalprice = 0;

  //create the table
  static Future<void> createTables(sql.Database database) async {
    await database.execute(""" 
    CREATE TABLE items(
    idd INTEGER AUTO_INCREMENT,
    medicine_id INTEGER,
    varientid INTEGER,
    name TEXT,
    image TEXT,
    price TEXT,
    actualPrice TEXT,
    description TEXT,
    counter INTEGER,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }
  // open databse
  static Future<sql.Database> db() async {
    return sql.openDatabase('cart.db', version: 8,
        onCreate: (sql.Database database, int version) async {
          await createTables(database);
        });
  }

  // id exists
  // static Future<bool> isProductExist(int id) async {
  // db = await Store.db();
  //    bool result = db.query('items',where: "id = ?",whereArgs: [id]) as bool;
  //    print(result);
  //    return result;
  // }

  static Future<bool> isProductExist(int id) async {
    var db = await Store.db();
    var result =
    await db.rawQuery('SELECT EXISTS(SELECT 1 FROM items WHERE medicine_id="$id")');
    int? exists = Sqflite.firstIntValue(result);
    return exists == 1;
  }

  //insert data into databse
  static Future<int> createItem(int medicine_id, int varientid, String name,
      String image, String price, String actualPrice,String description, int counter) async {
    var db = await Store.db();
    var data = {
      'medicine_id': medicine_id,
      'varientid': varientid,
      'name': name,
      'image': image,
      'price': price,
      'actualPrice': actualPrice,
      'description': description,
      'counter': counter,
    };
    var id = await db.insert('items', data);
    return id;
  }

  // get the data
  static Future<List<dynamic>> getItems() async {
    var db = await Store.db();
    return db.query('items', orderBy: "medicine_id");
  }

  // get the data
  static Future<List<Map<String, Object?>>> getIds() async {
    var db = await Store.db();
    var result = await db.rawQuery("SELECT medicine_id as data1 FROM items");
    print(result);
    return result;
  }

  // totalprice
  static Future<String> getTotalPrice() async {
    var db = await Store.db();
    var result = await db.rawQuery("SELECT SUM(price) as sum FROM items");
    return result[0]['sum'].toString();
  }

  //get counter id
  static Future<String> getCounterId() async {
    var db = await Store.db();
    var result =
    await db.rawQuery("SELECT * FROM items ORDER BY counter LIMIT 1;");
    print(result);
    return result[0]['sum'].toString();
  }

  // update item

  static Future<int> updateItem(int medicine_id, int varientid, String name,
      String image, String price, String actualPrice,String description, int counter) async {
    var db = await Store.db();
    var data = {
      'medicine_id': medicine_id,
      'varientid': varientid,
      'name': name,
      'image': image,
      'price': price,
      'actualPrice': actualPrice,
      'description': description,
      'counter': counter,
    };
    var result =
    await db.update('items', data, where: varientid != 0 ? "varientid = ?" :"medicine_id = ?", whereArgs: [varientid != 0 ? varientid : medicine_id]);
    return result;
  }

  // delete items
  static Future<void> deleteItem(int medicine_id,int varientid) async {
    var db = await Store.db();
    await db.delete("items", where: varientid != 0 ? "varientid = ?" :"medicine_id = ?", whereArgs: [varientid != 0 ? varientid : medicine_id]);
  }

  // delete items
  static Future<void> deleteAll() async {
    var db = await Store.db();
    await db.delete("items");
  }
}
