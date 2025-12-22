import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('daily_japanese.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL,
        kanji TEXT,
        hiragana TEXT,
        category TEXT NOT NULL,
        partOfSpeech TEXT,
        definition TEXT NOT NULL,
        example TEXT,
        example_jp TEXT,
        example_reading TEXT,
        isFavorite INTEGER DEFAULT 0,
        translations TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wordId INTEGER NOT NULL,
        languageCode TEXT NOT NULL,
        fieldType TEXT NOT NULL,
        translatedText TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        UNIQUE(wordId, languageCode, fieldType)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_translations_lookup 
      ON translations(wordId, languageCode, fieldType)
    ''');

    await db.execute('''
      CREATE INDEX idx_words_category 
      ON words(category)
    ''');

    await _loadInitialData(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS words');
    await db.execute('DROP TABLE IF EXISTS translations');
    await _createDB(db, newVersion);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/words.json',
      );
      final List<dynamic> data = json.decode(response);

      for (var wordJson in data) {
        Map<String, dynamic>? translationsMap = {};

        // 다국어 번역 필드 처리
        if (wordJson['korean'] != null) {
          translationsMap['ko'] = {
            'definition': wordJson['korean'].toString(),
            'example': wordJson['example_ko']?.toString() ?? '',
          };
        }
        if (wordJson['chinese'] != null) {
          translationsMap['zh'] = {
            'definition': wordJson['chinese'].toString(),
            'example': wordJson['example_zh']?.toString() ?? '',
          };
        }
        if (wordJson['spanish'] != null) {
          translationsMap['es'] = {
            'definition': wordJson['spanish'].toString(),
            'example': wordJson['example_es']?.toString() ?? '',
          };
        }
        if (wordJson['vietnamese'] != null) {
          translationsMap['vi'] = {
            'definition': wordJson['vietnamese'].toString(),
            'example': wordJson['example_vi']?.toString() ?? '',
          };
        }

        String? translationsJson;
        if (translationsMap.isNotEmpty) {
          translationsJson = json.encode(translationsMap);
        }

        await db.insert('words', {
          'id': wordJson['id'],
          'word': wordJson['word'] ?? '',
          'kanji': wordJson['kanji'] ?? wordJson['word'] ?? '',
          'hiragana': wordJson['hiragana'] ?? wordJson['reading'] ?? '',
          'category': wordJson['category'] ?? 'daily',
          'partOfSpeech': wordJson['part_of_speech'] ?? '',
          'definition': wordJson['definition'] ?? '',
          'example': wordJson['example_en'] ?? wordJson['example'] ?? '',
          'example_jp': wordJson['example_jp'] ?? '',
          'example_reading': wordJson['example_reading'] ?? '',
          'isFavorite': 0,
          'translations': translationsJson,
        });
      }
      print('Loaded ${data.length} daily Japanese words successfully');
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  // ============ 번역 캐시 메서드 ============

  Future<String?> getTranslation(
    int wordId,
    String languageCode,
    String fieldType,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'translations',
      columns: ['translatedText'],
      where: 'wordId = ? AND languageCode = ? AND fieldType = ?',
      whereArgs: [wordId, languageCode, fieldType],
    );
    if (result.isNotEmpty) {
      return result.first['translatedText'] as String;
    }
    return null;
  }

  Future<void> saveTranslation(
    int wordId,
    String languageCode,
    String fieldType,
    String translatedText,
  ) async {
    final db = await instance.database;
    await db.insert('translations', {
      'wordId': wordId,
      'languageCode': languageCode,
      'fieldType': fieldType,
      'translatedText': translatedText,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearTranslations(String languageCode) async {
    final db = await instance.database;
    await db.delete(
      'translations',
      where: 'languageCode = ?',
      whereArgs: [languageCode],
    );
  }

  Future<void> clearAllTranslations() async {
    final db = await instance.database;
    await db.delete('translations');
  }

  // ============ 단어 메서드 ============

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final result = await db.query('words', orderBy: 'id ASC');
    return result.map((json) => Word.fromDb(json)).toList();
  }

  Future<List<Word>> getWordsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'words',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id ASC',
    );
    return result.map((json) => Word.fromDb(json)).toList();
  }

  Future<List<String>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM words ORDER BY category ASC',
    );
    return result.map((row) => row['category'] as String).toList();
  }

  Future<Map<String, int>> getWordCountByCategory() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM words GROUP BY category',
    );
    final Map<String, int> counts = {};
    for (var row in result) {
      counts[row['category'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<List<Word>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query(
      'words',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'word ASC',
    );
    return result.map((json) => Word.fromDb(json)).toList();
  }

  Future<List<Word>> searchWords(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'words',
      where: 'word LIKE ? OR definition LIKE ? OR hiragana LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'word ASC',
    );
    return result.map((json) => Word.fromDb(json)).toList();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await instance.database;
    await db.update(
      'words',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Word?> getWordById(int id) async {
    final db = await instance.database;
    final result = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Word.fromDb(result.first);
  }

  Future<Word?> getRandomWord() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM words ORDER BY RANDOM() LIMIT 1',
    );
    if (result.isEmpty) return null;
    return Word.fromDb(result.first);
  }

  Future<Word?> getTodayWord() async {
    try {
      final db = await instance.database;
      final today = DateTime.now();
      final seed = today.year * 10000 + today.month * 100 + today.day;
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM words'),
          ) ??
          0;

      if (count == 0) return null;

      final index = seed % count;
      final result = await db.rawQuery('SELECT * FROM words LIMIT 1 OFFSET ?', [
        index,
      ]);
      if (result.isEmpty) return null;

      return Word.fromDb(result.first);
    } catch (e) {
      print('Error getting today word: $e');
      return null;
    }
  }

  // JSON 파일 캐시
  List<Word>? _jsonWordsCache;

  void clearJsonCache() {
    _jsonWordsCache = null;
  }

  Future<List<Word>> loadWordsFromJson() async {
    if (_jsonWordsCache != null) return _jsonWordsCache!;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/words.json',
      );
      final List<dynamic> data = json.decode(response);
      _jsonWordsCache = data.map((json) => Word.fromJson(json)).toList();
      return _jsonWordsCache!;
    } catch (e) {
      print('Error loading JSON words: $e');
      return [];
    }
  }

  Future<List<Category>> loadCategories() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/categories.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  Future<Word> applyTranslations(Word word, String languageCode) async {
    if (languageCode == 'en') return word;

    final translatedDef = await getTranslation(
      word.id,
      languageCode,
      'definition',
    );
    final translatedEx = await getTranslation(word.id, languageCode, 'example');

    return word.copyWith(
      translatedDefinition: translatedDef,
      translatedExample: translatedEx,
    );
  }

  Future<List<Word>> applyTranslationsToList(
    List<Word> words,
    String languageCode,
  ) async {
    if (languageCode == 'en') return words;

    final result = <Word>[];
    for (final word in words) {
      result.add(await applyTranslations(word, languageCode));
    }
    return result;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
