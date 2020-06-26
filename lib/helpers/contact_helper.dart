import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String contactTable = "contactTable";
final String idCol = "idCol";
final String nomeCol = "nomeCol";
final String emailCol = "emailCol";
final String telefoneCol = "telefoneCol";
final String imagemCol = "imagemCol";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idCol INTEGER PRIMARY KEY, $nomeCol TEXT, $emailCol TEXT,"
          "$telefoneCol TEXT, $imagemCol TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idCol, nomeCol, emailCol, telefoneCol, imagemCol],
        where: "$idCol = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idCol = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idCol = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String nome;
  String email;
  String telefone;
  String imagem;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idCol];
    nome = map[nomeCol];
    email = map[emailCol];
    telefone = map[telefoneCol];
    imagem = map[imagemCol];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeCol: nome,
      emailCol: email,
      telefoneCol: telefone,
      imagemCol: imagem
    };
    if (id != null) {
      map[idCol] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $nome, email: $email, phone: $telefone, img: $imagem)";
  }
}
