import 'dart:developer' as developer;
import 'package:ecard_app/modals/card_modal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  DatabaseHelper._init();

  Future<Database?> get database async{
    if(_database != null) return _database;
    _database = await _initDB('ecard.db');
    return _database;
  }

  Future<Database?> _initDB(String filePath) async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
        path,
        onCreate: _createDB,
        version: 1,
    );
  }

  // create database
  Future _createDB(Database db , int version) async {
    const idType = "TEXT PRIMARY KEY";
    const textType = "TEXT" ;
    const boolType = "INTEGER" ;

    await db.execute('''
    CREATE TABLE cards (
      id $idType,
      uuid $textType,
      createdAt $textType,
      updatedAt $textType,
      createdBy $textType,
      deleted $boolType,
      active $boolType,
      company $textType,
      organization $textType,
      publishCard $boolType,
      cardLogo $textType,
      profilePhoto $textType,
      address $textType,
      cardDescription $textType,
      phoneNumber $textType,
      department $textType,
      email $textType,
      linkedIn $textType,
      websiteUrl $textType,
      backgroundColor $textType,
      fontColor $textType
    )
    ''');
  }

  // insert card
  Future<int?> insertCard(CustomCard card) async {
    final db = await instance.database;

    try {
      return await db?.insert(
        'cards',
        _cardToMap(card),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      developer.log('Error inserting card========>: $e');
      return -1;
    }
  }

  // insert multiple cards
  Future<int> insertCards(List<CustomCard> cards) async {
    final db = await instance.database;
    int result = 0;

    try{
      await db?.transaction((txn) async{
        for(var card in cards){
          result += await txn.insert(
              'cards',
              _cardToMap(card),
              conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
      });
      return result;

    }catch(error) {
      developer.log("Error inserting cards: =======> $error");
      return -1;
    }
  }

  // method to get all cards
  Future<List<CustomCard>?> getAllCards() async{
    final db = await instance.database;
    try {
      final result = await db?.query('cards', where: 'deleted = ?', whereArgs: [0]);
      return result?.map((json)=>CustomCard.fromJson(json)).toList();
    }catch(error){
      developer.log("Error fetching cards: ======>$error");
    }
    return [];
  }

  // fetch cards by user uuid
  Future<List<CustomCard>?> getCardsByUser(String userUuid) async {
    final db = await instance.database;

    try{
      final result = await db?.query('cards' , where: 'created = ? AND deleted = ?', whereArgs: [userUuid, 0]);
      return result?.map((json)=>CustomCard.fromJson(json)).toList();
    }catch(error){
      developer.log("Error fetching cards=======>: $error");
      return [];
    }
  }

  Future<int?> updateCard(CustomCard card) async {
    final db = await instance.database;

    try {
      return await db?.update(
        'cards',
        _cardToMap(card),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } catch (e) {
      developer.log('Error updating card: $e');
      return -1;
    }
  }

  Future<int?> deleteCard(String id) async {
    final db = await instance.database;

    try {
      return await db?.update(
        'cards',
        {'deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error marking card as deleted: $e');
      return -1;
    }
  }

  Future<int?> clearAllCards() async {
    final db = await instance.database;

    try {
      return await db?.delete('cards');
    } catch (e) {
      developer.log('Error clearing cards: $e');
      return -1;
    }
  }

  // Helper method to convert CustomCard to Map for database operations
  Map<String, dynamic> _cardToMap(CustomCard card) {
    return {
      'id': card.id,
      'uuid': card.uuid,
      'createdAt': card.createdAt?.toIso8601String(),
      'updatedAt': card.updatedAt?.toIso8601String(),
      'createdBy': card.createdBy,
      'deleted': card.deleted ? 1 : 0,
      'active': card.active ? 1 : 0,
      'company': card.company,
      'organization': card.organization,
      'publishCard': card.publishCard ? 1 : 0,
      'cardLogo': card.cardLogo,
      'profilePhoto': card.profilePhoto,
      'address': card.address,
      'cardDescription': card.cardDescription,
      'phoneNumber': card.phoneNumber,
      'department': card.department,
      'email': card.email,
      'linkedIn': card.linkedIn,
      'websiteUrl': card.websiteUrl,
      'backgroundColor': card.backgroundColor,
      'fontColor': card.fontColor,
    };
  }
}