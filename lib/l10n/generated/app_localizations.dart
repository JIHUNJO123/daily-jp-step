import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('zh'),
    Locale('es'),
    Locale('vi'),
  ];

  String get appTitle;
  String get todayWord;
  String get learning;
  String get categories;
  String get allWords;
  String get viewAllWords;
  String get favorites;
  String get savedWords;
  String get flashcard;
  String get cardLearning;
  String get quiz;
  String get testYourself;
  String get settings;
  String get language;
  String get displayLanguage;
  String get selectLanguage;
  String get display;
  String get darkMode;
  String get fontSize;
  String get notifications;
  String get dailyReminder;
  String get dailyReminderDesc;
  String get removeAds;
  String get adsRemoved;
  String get thankYou;
  String get buy;
  String get restorePurchase;
  String get restoring;
  String get purchaseSuccess;
  String get loading;
  String get notAvailable;
  String get info;
  String get version;
  String get disclaimer;
  String get disclaimerText;
  String get privacyPolicy;
  String get cannotLoadWords;
  String get noFavoritesYet;
  String get tapHeartToSave;
  String get addedToFavorites;
  String get removedFromFavorites;
  String get wordDetail;
  String get definition;
  String get example;
  String categoryWords(String category);
  String wordsCount(int count);
  String get greeting;
  String get restaurant;
  String get shopping;
  String get transport;
  String get hotel;
  String get emergency;
  String get daily;
  String get emotion;
  String get alphabetical;
  String get random;
  String get tapToFlip;
  String get previous;
  String get next;
  String get question;
  String get score;
  String get quizComplete;
  String get finish;
  String get tryAgain;
  String get showResult;
  String get wordToMeaning;
  String get meaningToWord;
  String get excellent;
  String get great;
  String get good;
  String get keepPracticing;
  String get privacyPolicyContent;
  String get restorePurchaseDesc;
  String get restoreComplete;
  String get noPurchaseFound;
  String get furiganaDisplayMode;
  String get parenthesesMode;
  String get furiganaMode;
  String get parenthesesExample;
  String get furiganaExample;
  String get showFuriganaInList;
  String get showFuriganaInListDesc;
  String get search;
  String get searchHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko', 'zh', 'es', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
    case 'es':
      return AppLocalizationsEs();
    case 'vi':
      return AppLocalizationsVi();
    default:
      return AppLocalizationsEn();
  }
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily JP Step';
  @override
  String get todayWord => "Today's Word";
  @override
  String get learning => 'Learning';
  @override
  String get categories => 'Categories';
  @override
  String get allWords => 'All Words';
  @override
  String get viewAllWords => 'View all vocabulary';
  @override
  String get favorites => 'Favorites';
  @override
  String get savedWords => 'Saved words';
  @override
  String get flashcard => 'Flashcard';
  @override
  String get cardLearning => 'Card learning';
  @override
  String get quiz => 'Quiz';
  @override
  String get testYourself => 'Test yourself';
  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get displayLanguage => 'Display Language';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get display => 'Display';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get fontSize => 'Font Size';
  @override
  String get notifications => 'Notifications';
  @override
  String get dailyReminder => 'Daily Reminder';
  @override
  String get dailyReminderDesc => 'Get reminded to study every day';
  @override
  String get removeAds => 'Remove Ads';
  @override
  String get adsRemoved => 'Ads Removed';
  @override
  String get thankYou => 'Thank you for your support!';
  @override
  String get buy => 'Buy';
  @override
  String get restorePurchase => 'Restore Purchase';
  @override
  String get restoring => 'Restoring...';
  @override
  String get purchaseSuccess => 'Purchase successful!';
  @override
  String get loading => 'Loading...';
  @override
  String get notAvailable => 'Not available';
  @override
  String get info => 'Info';
  @override
  String get version => 'Version';
  @override
  String get disclaimer => 'Disclaimer';
  @override
  String get disclaimerText =>
      'This app provides practical Japanese phrases for daily use and travel. Content is for educational purposes.';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get cannotLoadWords => 'Cannot load words';
  @override
  String get noFavoritesYet => 'No favorites yet';
  @override
  String get tapHeartToSave => 'Tap the heart icon to save words';
  @override
  String get addedToFavorites => 'Added to favorites';
  @override
  String get removedFromFavorites => 'Removed from favorites';
  @override
  String get wordDetail => 'Word Detail';
  @override
  String get definition => 'Definition';
  @override
  String get example => 'Example';
  @override
  String categoryWords(String category) => category;
  @override
  String wordsCount(int count) => '$count words';
  @override
  String get greeting => 'Greetings & Basics';
  @override
  String get restaurant => 'Restaurant & Food';
  @override
  String get shopping => 'Shopping & Price';
  @override
  String get transport => 'Transport & Directions';
  @override
  String get hotel => 'Hotel & Accommodation';
  @override
  String get emergency => 'Emergency & Health';
  @override
  String get daily => 'Daily Life';
  @override
  String get emotion => 'Emotions & Expressions';
  @override
  String get alphabetical => 'Alphabetical';
  @override
  String get random => 'Random';
  @override
  String get tapToFlip => 'Tap to flip';
  @override
  String get previous => 'Previous';
  @override
  String get next => 'Next';
  @override
  String get question => 'Question';
  @override
  String get score => 'Score';
  @override
  String get quizComplete => 'Quiz Complete!';
  @override
  String get finish => 'Finish';
  @override
  String get tryAgain => 'Try Again';
  @override
  String get showResult => 'Show Result';
  @override
  String get wordToMeaning => 'Word to Meaning';
  @override
  String get meaningToWord => 'Meaning to Word';
  @override
  String get excellent => 'Excellent! Perfect score!';
  @override
  String get great => 'Great job! Keep it up!';
  @override
  String get good => 'Good effort! Keep practicing!';
  @override
  String get keepPracticing => 'Keep practicing! You will improve!';
  @override
  String get privacyPolicyContent =>
      'This app does not collect, store, or share any personal information. Your learning progress and favorites are stored only on your device. No data is transmitted to external servers.';
  @override
  String get restorePurchaseDesc =>
      'If you have previously purchased ad removal on another device or after reinstalling the app, tap here to restore your purchase.';
  @override
  String get restoreComplete => 'Restore complete';
  @override
  String get noPurchaseFound => 'No previous purchase found';
  @override
  String get furiganaDisplayMode => 'Reading Display';
  @override
  String get parenthesesMode => 'Parentheses';
  @override
  String get furiganaMode => 'Ruby Style';
  @override
  String get parenthesesExample => 'e.g. 食べ物 (たべもの)';
  @override
  String get furiganaExample => 'Reading above kanji';
  @override
  String get showFuriganaInList => 'Show Furigana in Word List';
  @override
  String get showFuriganaInListDesc =>
      'Display reading above kanji in word list';
  @override
  String get search => 'Search';
  @override
  String get searchHint => 'Search words...';
}

class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Daily JP Step';
  @override
  String get todayWord => '오늘의 단어';
  @override
  String get learning => '학습';
  @override
  String get categories => '카테고리';
  @override
  String get allWords => '모든 단어';
  @override
  String get viewAllWords => '모든 단어 보기';
  @override
  String get favorites => '즐겨찾기';
  @override
  String get savedWords => '저장된 단어';
  @override
  String get flashcard => '플래시카드';
  @override
  String get cardLearning => '카드 학습';
  @override
  String get quiz => '퀴즈';
  @override
  String get testYourself => '실력 테스트';
  @override
  String get settings => '설정';
  @override
  String get language => '언어';
  @override
  String get displayLanguage => '표시 언어';
  @override
  String get selectLanguage => '언어 선택';
  @override
  String get display => '표시';
  @override
  String get darkMode => '다크 모드';
  @override
  String get fontSize => '글꼴 크기';
  @override
  String get notifications => '알림';
  @override
  String get dailyReminder => '일일 알림';
  @override
  String get dailyReminderDesc => '매일 학습 알림 받기';
  @override
  String get removeAds => '광고 제거';
  @override
  String get adsRemoved => '광고 제거됨';
  @override
  String get thankYou => '지원해 주셔서 감사합니다!';
  @override
  String get buy => '구매';
  @override
  String get restorePurchase => '구매 복원';
  @override
  String get restoring => '복원 중...';
  @override
  String get purchaseSuccess => '구매 성공!';
  @override
  String get loading => '로딩 중...';
  @override
  String get notAvailable => '사용 불가';
  @override
  String get info => '정보';
  @override
  String get version => '버전';
  @override
  String get disclaimer => '면책 조항';
  @override
  String get disclaimerText =>
      '이 앱은 일상 생활과 여행을 위한 실용적인 일본어 표현을 제공합니다. 콘텐츠는 교육 목적입니다.';
  @override
  String get privacyPolicy => '개인정보 처리방침';
  @override
  String get cannotLoadWords => '단어를 불러올 수 없습니다';
  @override
  String get noFavoritesYet => '아직 즐겨찾기가 없습니다';
  @override
  String get tapHeartToSave => '하트 아이콘을 눌러 단어를 저장하세요';
  @override
  String get addedToFavorites => '즐겨찾기에 추가됨';
  @override
  String get removedFromFavorites => '즐겨찾기에서 제거됨';
  @override
  String get wordDetail => '단어 상세';
  @override
  String get definition => '정의';
  @override
  String get example => '예문';
  @override
  String categoryWords(String category) => category;
  @override
  String wordsCount(int count) => '$count 단어';
  @override
  String get greeting => '인사/기본 표현';
  @override
  String get restaurant => '식당/음식';
  @override
  String get shopping => '쇼핑/가격';
  @override
  String get transport => '교통/길찾기';
  @override
  String get hotel => '호텔/숙박';
  @override
  String get emergency => '응급/건강';
  @override
  String get daily => '일상생활';
  @override
  String get emotion => '감정/표현';
  @override
  String get alphabetical => '가나다순';
  @override
  String get random => '랜덤';
  @override
  String get tapToFlip => '눌러서 뒤집기';
  @override
  String get previous => '이전';
  @override
  String get next => '다음';
  @override
  String get question => '문제';
  @override
  String get score => '점수';
  @override
  String get quizComplete => '퀴즈 완료!';
  @override
  String get finish => '완료';
  @override
  String get tryAgain => '다시 시도';
  @override
  String get showResult => '결과 보기';
  @override
  String get wordToMeaning => '단어 → 뜻';
  @override
  String get meaningToWord => '뜻 → 단어';
  @override
  String get excellent => '완벽해요! 만점입니다!';
  @override
  String get great => '잘했어요! 계속 화이팅!';
  @override
  String get good => '좋아요! 계속 연습하세요!';
  @override
  String get keepPracticing => '계속 연습하면 실력이 늘어요!';
  @override
  String get privacyPolicyContent =>
      '이 앱은 개인 정보를 수집, 저장 또는 공유하지 않습니다. 학습 진행 상황과 즐겨찾기는 기기에만 저장됩니다. 외부 서버로 데이터가 전송되지 않습니다.';
  @override
  String get restorePurchaseDesc =>
      '다른 기기에서 광고 제거를 구매했거나 앱을 다시 설치한 경우 여기를 눌러 구매를 복원하세요.';
  @override
  String get restoreComplete => '복원 완료';
  @override
  String get noPurchaseFound => '이전 구매 내역 없음';
  @override
  String get furiganaDisplayMode => '읽기 표시 방식';
  @override
  String get parenthesesMode => '괄호 표시';
  @override
  String get furiganaMode => '후리가나 스타일';
  @override
  String get parenthesesExample => '예: 食べ物 (たべもの)';
  @override
  String get furiganaExample => '한자 위에 읽기 표시';
  @override
  String get showFuriganaInList => '단어 목록에 후리가나 표시';
  @override
  String get showFuriganaInListDesc => '단어 목록에서 한자 위에 읽기 표시';
  @override
  String get search => '검색';
  @override
  String get searchHint => '단어 검색...';
}

class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Daily JP Step';
  @override
  String get todayWord => '今日单词';
  @override
  String get learning => '学习';
  @override
  String get categories => '分类';
  @override
  String get allWords => '所有单词';
  @override
  String get viewAllWords => '查看所有单词';
  @override
  String get favorites => '收藏';
  @override
  String get savedWords => '已保存的单词';
  @override
  String get flashcard => '闪卡';
  @override
  String get cardLearning => '卡片学习';
  @override
  String get quiz => '测验';
  @override
  String get testYourself => '自我测试';
  @override
  String get settings => '设置';
  @override
  String get language => '语言';
  @override
  String get displayLanguage => '显示语言';
  @override
  String get selectLanguage => '选择语言';
  @override
  String get display => '显示';
  @override
  String get darkMode => '深色模式';
  @override
  String get fontSize => '字体大小';
  @override
  String get notifications => '通知';
  @override
  String get dailyReminder => '每日提醒';
  @override
  String get dailyReminderDesc => '每天收到学习提醒';
  @override
  String get removeAds => '去除广告';
  @override
  String get adsRemoved => '广告已去除';
  @override
  String get thankYou => '感谢您的支持！';
  @override
  String get buy => '购买';
  @override
  String get restorePurchase => '恢复购买';
  @override
  String get restoring => '恢复中...';
  @override
  String get purchaseSuccess => '购买成功！';
  @override
  String get loading => '加载中...';
  @override
  String get notAvailable => '不可用';
  @override
  String get info => '信息';
  @override
  String get version => '版本';
  @override
  String get disclaimer => '免责声明';
  @override
  String get disclaimerText => '本应用提供日常生活和旅行实用日语短语。内容仅供教育目的。';
  @override
  String get privacyPolicy => '隐私政策';
  @override
  String get cannotLoadWords => '无法加载单词';
  @override
  String get noFavoritesYet => '还没有收藏';
  @override
  String get tapHeartToSave => '点击心形图标保存单词';
  @override
  String get addedToFavorites => '已添加到收藏';
  @override
  String get removedFromFavorites => '已从收藏中移除';
  @override
  String get wordDetail => '单词详情';
  @override
  String get definition => '定义';
  @override
  String get example => '例句';
  @override
  String categoryWords(String category) => category;
  @override
  String wordsCount(int count) => '$count 个单词';
  @override
  String get greeting => '问候/基本表达';
  @override
  String get restaurant => '餐厅/美食';
  @override
  String get shopping => '购物/价格';
  @override
  String get transport => '交通/问路';
  @override
  String get hotel => '酒店/住宿';
  @override
  String get emergency => '紧急/健康';
  @override
  String get daily => '日常生活';
  @override
  String get emotion => '情感/表达';
  @override
  String get alphabetical => '字母顺序';
  @override
  String get random => '随机';
  @override
  String get tapToFlip => '点击翻转';
  @override
  String get previous => '上一个';
  @override
  String get next => '下一个';
  @override
  String get question => '问题';
  @override
  String get score => '分数';
  @override
  String get quizComplete => '测验完成！';
  @override
  String get finish => '完成';
  @override
  String get tryAgain => '再试一次';
  @override
  String get showResult => '查看结果';
  @override
  String get wordToMeaning => '单词→意思';
  @override
  String get meaningToWord => '意思→单词';
  @override
  String get excellent => '太棒了！满分！';
  @override
  String get great => '做得好！继续加油！';
  @override
  String get good => '不错！继续练习！';
  @override
  String get keepPracticing => '继续练习！你会进步的！';
  @override
  String get privacyPolicyContent =>
      '本应用不收集、存储或分享任何个人信息。您的学习进度和收藏仅存储在您的设备上。没有数据传输到外部服务器。';
  @override
  String get restorePurchaseDesc => '如果您之前在其他设备上购买了去除广告功能，或重新安装了应用，请点击此处恢复购买。';
  @override
  String get restoreComplete => '恢复完成';
  @override
  String get noPurchaseFound => '未找到之前的购买记录';
  @override
  String get furiganaDisplayMode => '读音显示';
  @override
  String get parenthesesMode => '括号显示';
  @override
  String get furiganaMode => '假名注音';
  @override
  String get parenthesesExample => '例：食べ物（たべもの）';
  @override
  String get furiganaExample => '汉字上方显示读音';
  @override
  String get showFuriganaInList => '单词列表显示假名';
  @override
  String get showFuriganaInListDesc => '在单词列表中汉字上方显示读音';
  @override
  String get search => '搜索';
  @override
  String get searchHint => '搜索单词...';
}

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Daily JP Step';
  @override
  String get todayWord => 'Palabra del Día';
  @override
  String get learning => 'Aprendizaje';
  @override
  String get categories => 'Categorías';
  @override
  String get allWords => 'Todas las Palabras';
  @override
  String get viewAllWords => 'Ver todo el vocabulario';
  @override
  String get favorites => 'Favoritos';
  @override
  String get savedWords => 'Palabras guardadas';
  @override
  String get flashcard => 'Tarjeta';
  @override
  String get cardLearning => 'Aprendizaje con tarjetas';
  @override
  String get quiz => 'Prueba';
  @override
  String get testYourself => 'Evalúate';
  @override
  String get settings => 'Ajustes';
  @override
  String get language => 'Idioma';
  @override
  String get displayLanguage => 'Idioma de Visualización';
  @override
  String get selectLanguage => 'Seleccionar Idioma';
  @override
  String get display => 'Pantalla';
  @override
  String get darkMode => 'Modo Oscuro';
  @override
  String get fontSize => 'Tamaño de Fuente';
  @override
  String get notifications => 'Notificaciones';
  @override
  String get dailyReminder => 'Recordatorio Diario';
  @override
  String get dailyReminderDesc => 'Recibe recordatorios para estudiar cada día';
  @override
  String get removeAds => 'Eliminar Anuncios';
  @override
  String get adsRemoved => 'Anuncios Eliminados';
  @override
  String get thankYou => '¡Gracias por tu apoyo!';
  @override
  String get buy => 'Comprar';
  @override
  String get restorePurchase => 'Restaurar Compra';
  @override
  String get restoring => 'Restaurando...';
  @override
  String get purchaseSuccess => '¡Compra exitosa!';
  @override
  String get loading => 'Cargando...';
  @override
  String get notAvailable => 'No disponible';
  @override
  String get info => 'Info';
  @override
  String get version => 'Versión';
  @override
  String get disclaimer => 'Aviso Legal';
  @override
  String get disclaimerText =>
      'Esta app proporciona frases prácticas en japonés para uso diario y viajes. El contenido es solo para fines educativos.';
  @override
  String get privacyPolicy => 'Política de Privacidad';
  @override
  String get cannotLoadWords => 'No se pueden cargar las palabras';
  @override
  String get noFavoritesYet => 'Aún no hay favoritos';
  @override
  String get tapHeartToSave => 'Toca el corazón para guardar palabras';
  @override
  String get addedToFavorites => 'Añadido a favoritos';
  @override
  String get removedFromFavorites => 'Eliminado de favoritos';
  @override
  String get wordDetail => 'Detalle de Palabra';
  @override
  String get definition => 'Definición';
  @override
  String get example => 'Ejemplo';
  @override
  String categoryWords(String category) => category;
  @override
  String wordsCount(int count) => '$count palabras';
  @override
  String get greeting => 'Saludos y Básicos';
  @override
  String get restaurant => 'Restaurante y Comida';
  @override
  String get shopping => 'Compras y Precios';
  @override
  String get transport => 'Transporte y Direcciones';
  @override
  String get hotel => 'Hotel y Alojamiento';
  @override
  String get emergency => 'Emergencia y Salud';
  @override
  String get daily => 'Vida Diaria';
  @override
  String get emotion => 'Emociones y Expresiones';
  @override
  String get alphabetical => 'Alfabético';
  @override
  String get random => 'Aleatorio';
  @override
  String get tapToFlip => 'Toca para voltear';
  @override
  String get previous => 'Anterior';
  @override
  String get next => 'Siguiente';
  @override
  String get question => 'Pregunta';
  @override
  String get score => 'Puntuación';
  @override
  String get quizComplete => '¡Prueba Completada!';
  @override
  String get finish => 'Finalizar';
  @override
  String get tryAgain => 'Intentar de nuevo';
  @override
  String get showResult => 'Ver Resultado';
  @override
  String get wordToMeaning => 'Palabra → Significado';
  @override
  String get meaningToWord => 'Significado → Palabra';
  @override
  String get excellent => '¡Excelente! ¡Puntuación perfecta!';
  @override
  String get great => '¡Buen trabajo! ¡Sigue así!';
  @override
  String get good => '¡Buen esfuerzo! ¡Sigue practicando!';
  @override
  String get keepPracticing => '¡Sigue practicando! ¡Mejorarás!';
  @override
  String get privacyPolicyContent =>
      'Esta app no recopila, almacena ni comparte información personal. Tu progreso y favoritos se guardan solo en tu dispositivo. No se transmiten datos a servidores externos.';
  @override
  String get restorePurchaseDesc =>
      'Si compraste la eliminación de anuncios en otro dispositivo o reinstalaste la app, toca aquí para restaurar tu compra.';
  @override
  String get restoreComplete => 'Restauración completada';
  @override
  String get noPurchaseFound => 'No se encontró compra anterior';
  @override
  String get furiganaDisplayMode => 'Modo de Lectura';
  @override
  String get parenthesesMode => 'Paréntesis';
  @override
  String get furiganaMode => 'Estilo Ruby';
  @override
  String get parenthesesExample => 'ej. 食べ物 (たべもの)';
  @override
  String get furiganaExample => 'Lectura sobre kanji';
  @override
  String get showFuriganaInList => 'Mostrar Furigana en Lista';
  @override
  String get showFuriganaInListDesc => 'Mostrar lectura sobre kanji en lista';
  @override
  String get search => 'Buscar';
  @override
  String get searchHint => 'Buscar palabras...';
}

class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Daily JP Step';
  @override
  String get todayWord => 'Từ Vựng Hôm Nay';
  @override
  String get learning => 'Học Tập';
  @override
  String get categories => 'Danh Mục';
  @override
  String get allWords => 'Tất Cả Từ';
  @override
  String get viewAllWords => 'Xem tất cả từ vựng';
  @override
  String get favorites => 'Yêu Thích';
  @override
  String get savedWords => 'Từ đã lưu';
  @override
  String get flashcard => 'Thẻ Học';
  @override
  String get cardLearning => 'Học bằng thẻ';
  @override
  String get quiz => 'Kiểm Tra';
  @override
  String get testYourself => 'Tự kiểm tra';
  @override
  String get settings => 'Cài Đặt';
  @override
  String get language => 'Ngôn Ngữ';
  @override
  String get displayLanguage => 'Ngôn Ngữ Hiển Thị';
  @override
  String get selectLanguage => 'Chọn Ngôn Ngữ';
  @override
  String get display => 'Hiển Thị';
  @override
  String get darkMode => 'Chế Độ Tối';
  @override
  String get fontSize => 'Cỡ Chữ';
  @override
  String get notifications => 'Thông Báo';
  @override
  String get dailyReminder => 'Nhắc Nhở Hằng Ngày';
  @override
  String get dailyReminderDesc => 'Nhận nhắc nhở học tập mỗi ngày';
  @override
  String get removeAds => 'Xóa Quảng Cáo';
  @override
  String get adsRemoved => 'Đã Xóa Quảng Cáo';
  @override
  String get thankYou => 'Cảm ơn bạn đã ủng hộ!';
  @override
  String get buy => 'Mua';
  @override
  String get restorePurchase => 'Khôi Phục Mua Hàng';
  @override
  String get restoring => 'Đang khôi phục...';
  @override
  String get purchaseSuccess => 'Mua thành công!';
  @override
  String get loading => 'Đang tải...';
  @override
  String get notAvailable => 'Không khả dụng';
  @override
  String get info => 'Thông Tin';
  @override
  String get version => 'Phiên Bản';
  @override
  String get disclaimer => 'Miễn Trừ';
  @override
  String get disclaimerText =>
      'Ứng dụng cung cấp các cụm từ tiếng Nhật thực tế cho cuộc sống hằng ngày và du lịch. Nội dung chỉ mang mục đích giáo dục.';
  @override
  String get privacyPolicy => 'Chính Sách Bảo Mật';
  @override
  String get cannotLoadWords => 'Không thể tải từ vựng';
  @override
  String get noFavoritesYet => 'Chưa có mục yêu thích';
  @override
  String get tapHeartToSave => 'Nhấn biểu tượng trái tim để lưu từ';
  @override
  String get addedToFavorites => 'Đã thêm vào yêu thích';
  @override
  String get removedFromFavorites => 'Đã xóa khỏi yêu thích';
  @override
  String get wordDetail => 'Chi Tiết Từ';
  @override
  String get definition => 'Định Nghĩa';
  @override
  String get example => 'Ví Dụ';
  @override
  String categoryWords(String category) => category;
  @override
  String wordsCount(int count) => '$count từ';
  @override
  String get greeting => 'Chào Hỏi & Cơ Bản';
  @override
  String get restaurant => 'Nhà Hàng & Ẩm Thực';
  @override
  String get shopping => 'Mua Sắm & Giá Cả';
  @override
  String get transport => 'Giao Thông & Chỉ Đường';
  @override
  String get hotel => 'Khách Sạn & Lưu Trú';
  @override
  String get emergency => 'Khẩn Cấp & Sức Khỏe';
  @override
  String get daily => 'Cuộc Sống Hằng Ngày';
  @override
  String get emotion => 'Cảm Xúc & Biểu Đạt';
  @override
  String get alphabetical => 'Theo Thứ Tự';
  @override
  String get random => 'Ngẫu Nhiên';
  @override
  String get tapToFlip => 'Nhấn để lật';
  @override
  String get previous => 'Trước';
  @override
  String get next => 'Tiếp';
  @override
  String get question => 'Câu Hỏi';
  @override
  String get score => 'Điểm';
  @override
  String get quizComplete => 'Hoàn Thành Kiểm Tra!';
  @override
  String get finish => 'Hoàn Tất';
  @override
  String get tryAgain => 'Thử Lại';
  @override
  String get showResult => 'Xem Kết Quả';
  @override
  String get wordToMeaning => 'Từ → Nghĩa';
  @override
  String get meaningToWord => 'Nghĩa → Từ';
  @override
  String get excellent => 'Tuyệt vời! Điểm tuyệt đối!';
  @override
  String get great => 'Làm tốt lắm! Tiếp tục nhé!';
  @override
  String get good => 'Tốt lắm! Tiếp tục luyện tập!';
  @override
  String get keepPracticing => 'Tiếp tục luyện tập! Bạn sẽ tiến bộ!';
  @override
  String get privacyPolicyContent =>
      'Ứng dụng không thu thập, lưu trữ hoặc chia sẻ thông tin cá nhân. Tiến độ học và yêu thích chỉ được lưu trên thiết bị của bạn. Không có dữ liệu được gửi đến máy chủ bên ngoài.';
  @override
  String get restorePurchaseDesc =>
      'Nếu bạn đã mua xóa quảng cáo trên thiết bị khác hoặc sau khi cài lại ứng dụng, nhấn đây để khôi phục.';
  @override
  String get restoreComplete => 'Khôi phục hoàn tất';
  @override
  String get noPurchaseFound => 'Không tìm thấy giao dịch trước';
  @override
  String get furiganaDisplayMode => 'Chế Độ Đọc';
  @override
  String get parenthesesMode => 'Dấu Ngoặc';
  @override
  String get furiganaMode => 'Kiểu Ruby';
  @override
  String get parenthesesExample => 'vd: 食べ物 (たべもの)';
  @override
  String get furiganaExample => 'Phiên âm trên kanji';
  @override
  String get showFuriganaInList => 'Hiện Furigana Trong Danh Sách';
  @override
  String get showFuriganaInListDesc =>
      'Hiển thị phiên âm trên kanji trong danh sách';
  @override
  String get search => 'Tìm Kiếm';
  @override
  String get searchHint => 'Tìm kiếm từ...';
}
