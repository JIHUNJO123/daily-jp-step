import 'dart:convert';

/// 단어 모델 (일상/여행 일본어 - 카테고리별)
class Word {
  final int id;
  final String word; // 일본어 단어 (한자+히라가나 혼합)
  final String? kanji; // 한자 부분
  final String? hiragana; // 히라가나 읽기
  final String category; // 카테고리
  final String partOfSpeech; // 품사
  final String definition; // 영어 정의
  final String example; // 영어 예문
  final String? exampleJp; // 일본어 예문
  final String? exampleReading; // 예문 읽기
  bool isFavorite;

  // 내장 번역 데이터 (words.json에서 로드)
  final Map<String, Map<String, String>>? translations;

  // 번역된 텍스트 (런타임에 설정됨)
  String? translatedDefinition;
  String? translatedExample;

  Word({
    required this.id,
    required this.word,
    this.kanji,
    this.hiragana,
    required this.category,
    this.partOfSpeech = '',
    required this.definition,
    this.example = '',
    this.exampleJp,
    this.exampleReading,
    this.isFavorite = false,
    this.translations,
    this.translatedDefinition,
    this.translatedExample,
  });

  /// 내장 번역 가져오기
  String? getEmbeddedTranslation(String langCode, String fieldType) {
    if (translations == null) return null;
    final langData = translations![langCode];
    if (langData == null) return null;
    return langData[fieldType];
  }

  /// JSON에서 생성
  factory Word.fromJson(Map<String, dynamic> json) {
    // translations 파싱
    Map<String, Map<String, String>>? translations = {};

    // 다국어 번역 필드 처리
    final langCodes = ['ko', 'zh', 'es', 'vi'];
    for (final lang in langCodes) {
      String? def;
      String? ex;

      // 직접 필드 (korean, chinese 등)
      if (lang == 'ko' && json['korean'] != null) {
        def = json['korean']?.toString();
      } else if (lang == 'zh' && json['chinese'] != null) {
        def = json['chinese']?.toString();
      } else if (lang == 'es' && json['spanish'] != null) {
        def = json['spanish']?.toString();
      } else if (lang == 'vi' && json['vietnamese'] != null) {
        def = json['vietnamese']?.toString();
      }

      // 예문 번역 - example_ko, example_zh, example_es, example_vi
      final exKey = 'example_$lang';
      if (json[exKey] != null && json[exKey].toString().isNotEmpty) {
        ex = json[exKey].toString();
      }

      // 번역 데이터가 있으면 저장
      if ((def != null && def.isNotEmpty) || (ex != null && ex.isNotEmpty)) {
        translations[lang] = {'definition': def ?? '', 'example': ex ?? ''};
      }
    }

    // translations 객체가 있으면 사용
    if (json['translations'] != null && json['translations'] is Map) {
      (json['translations'] as Map<String, dynamic>).forEach((langCode, data) {
        if (data is Map<String, dynamic>) {
          translations[langCode] = {
            'definition': data['definition']?.toString() ?? '',
            'example': data['example']?.toString() ?? '',
          };
        }
      });
    }

    return Word(
      id: json['id'] ?? 0,
      word: json['word'] ?? '',
      kanji: json['kanji'] ?? json['word'],
      hiragana: json['reading'] ?? json['hiragana'],
      category: json['category'] ?? 'daily',
      partOfSpeech: json['part_of_speech'] ?? json['partOfSpeech'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example_en'] ?? json['example'] ?? '',
      exampleJp: json['example_jp'] ?? json['exampleJapanese'],
      exampleReading: json['example_reading'] ?? json['exampleReading'],
      isFavorite: json['is_favorite'] == 1 || json['isFavorite'] == true,
      translations: translations.isNotEmpty ? translations : null,
    );
  }

  /// DB에서 생성
  factory Word.fromDb(Map<String, dynamic> json) {
    Map<String, Map<String, String>>? translations;
    if (json['translations'] != null && json['translations'] is String) {
      try {
        final decoded = jsonDecode(json['translations'] as String);
        if (decoded is Map<String, dynamic>) {
          translations = {};
          decoded.forEach((langCode, data) {
            if (data is Map<String, dynamic>) {
              translations![langCode] = {
                'definition': data['definition']?.toString() ?? '',
                'example': data['example']?.toString() ?? '',
              };
            }
          });
        }
      } catch (e) {
        print('Error parsing translations JSON: $e');
      }
    }

    return Word(
      id: json['id'] as int,
      word: json['word'] as String,
      kanji: json['kanji'] as String?,
      hiragana: json['hiragana'] as String?,
      category: json['category'] as String? ?? 'daily',
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definition: json['definition'] as String,
      example: json['example'] as String? ?? '',
      exampleJp: json['example_jp'] as String?,
      exampleReading: json['example_reading'] as String?,
      isFavorite: (json['isFavorite'] as int?) == 1,
      translations: translations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'kanji': kanji,
      'hiragana': hiragana,
      'category': category,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'example_jp': exampleJp,
      'example_reading': exampleReading,
      'isFavorite': isFavorite ? 1 : 0,
      'translations': translations,
    };
  }

  /// 번역된 정의 가져오기
  String getDefinition(bool useTranslation) {
    if (useTranslation &&
        translatedDefinition != null &&
        translatedDefinition!.isNotEmpty) {
      return translatedDefinition!;
    }
    return definition;
  }

  /// 번역된 예문 가져오기
  String getExample(bool useTranslation) {
    if (useTranslation &&
        translatedExample != null &&
        translatedExample!.isNotEmpty) {
      return translatedExample!;
    }
    return example;
  }

  /// 단어 표시 (한자 + 히라가나)
  String getDisplayWord({String displayMode = 'parentheses'}) {
    if (kanji != null &&
        hiragana != null &&
        kanji!.isNotEmpty &&
        hiragana!.isNotEmpty &&
        kanji != hiragana &&
        word != hiragana) {
      if (displayMode == 'furigana') {
        return '$kanji [$hiragana]';
      } else {
        return '$kanji ($hiragana)';
      }
    }
    return word;
  }

  Word copyWith({
    int? id,
    String? word,
    String? kanji,
    String? hiragana,
    String? category,
    String? partOfSpeech,
    String? definition,
    String? example,
    String? exampleJp,
    String? exampleReading,
    bool? isFavorite,
    Map<String, Map<String, String>>? translations,
    String? translatedDefinition,
    String? translatedExample,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      kanji: kanji ?? this.kanji,
      hiragana: hiragana ?? this.hiragana,
      category: category ?? this.category,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      exampleJp: exampleJp ?? this.exampleJp,
      exampleReading: exampleReading ?? this.exampleReading,
      isFavorite: isFavorite ?? this.isFavorite,
      translations: translations ?? this.translations,
      translatedDefinition: translatedDefinition ?? this.translatedDefinition,
      translatedExample: translatedExample ?? this.translatedExample,
    );
  }
}

/// 카테고리 모델
class Category {
  final String id;
  final String nameEn;
  final String nameKo;
  final String nameZh;
  final String nameEs;
  final String nameVi;
  final int wordCount;
  final String icon;

  Category({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.nameZh,
    required this.nameEs,
    required this.nameVi,
    required this.wordCount,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameZh: json['name_zh'] ?? '',
      nameEs: json['name_es'] ?? '',
      nameVi: json['name_vi'] ?? '',
      wordCount: json['word_count'] ?? 0,
      icon: _getIconForCategory(json['id'] ?? ''),
    );
  }

  /// 언어 코드에 맞는 이름 반환
  String getName(String langCode) {
    switch (langCode) {
      case 'ko':
        return nameKo;
      case 'zh':
        return nameZh;
      case 'es':
        return nameEs;
      case 'vi':
        return nameVi;
      default:
        return nameEn;
    }
  }

  static String _getIconForCategory(String categoryId) {
    const icons = {
      'greeting': '👋',
      'restaurant': '🍽️',
      'shopping': '🛒',
      'transport': '🚃',
      'hotel': '🏨',
      'emergency': '🚨',
      'daily': '📅',
      'emotion': '😊',
      'hospital': '🏥',
      'school': '🏫',
      'business': '💼',
      'bank': '🏦',
      'salon': '💇',
      'home': '🏠',
      'weather': '🌤️',
      'party': '🎉',
    };
    return icons[categoryId] ?? '📚';
  }
}

/// 카테고리 목록
class CategoryList {
  static const List<String> all = [
    'greeting',
    'restaurant',
    'shopping',
    'transport',
    'hotel',
    'emergency',
    'daily',
    'emotion',
  ];

  static const Map<String, String> icons = {
    'greeting': '👋',
    'restaurant': '🍽️',
    'shopping': '🛒',
    'transport': '🚃',
    'hotel': '🏨',
    'emergency': '🏥',
    'daily': '🏠',
    'emotion': '😊',
  };
}
