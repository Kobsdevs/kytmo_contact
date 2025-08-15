import '../models/contact.dart';
import 'db_helper.dart';

class ContactRepository {
  Future<int> create(Contact c) async {
    final db = await DBHelper.database;
    return db.insert('contacts', c.toMap());
  }

  Future<List<Contact>> all({String? q}) async {
    final db = await DBHelper.database;
    List<Map<String, dynamic>> rows;
    if (q != null && q.trim().isNotEmpty) {
      rows = await db.query('contacts',
          where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
          whereArgs: ['%$q%', '%$q%', '%$q%'],
          orderBy: 'name COLLATE NOCASE ASC');
    } else {
      rows = await db.query('contacts', orderBy: 'name COLLATE NOCASE ASC');
    }
    return rows.map(Contact.fromMap).toList();
  }

  Future<int> update(Contact c) async {
    final db = await DBHelper.database;
    return db.update('contacts', c.toMap(), where: 'id=?', whereArgs: [c.id]);
  }

  Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('contacts', where: 'id=?', whereArgs: [id]);
  }
}
