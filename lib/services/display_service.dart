import 'package:shared_preferences/shared_preferences.dart';

/// 단어 표시 방식 관리 서비스
class DisplayService {
  static final DisplayService instance = DisplayService._internal();
  factory DisplayService() => instance;
  DisplayService._internal();

  static const String _keyFuriganaDisplayMode = 'furiganaDisplayMode';
  static const String _keyShowFuriganaInList = 'showFuriganaInList';
  String _displayMode = 'parentheses';
  bool _showFuriganaInList = false;

  /// 표시 방식 초기화
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _displayMode = prefs.getString(_keyFuriganaDisplayMode) ?? 'parentheses';
    _showFuriganaInList = prefs.getBool(_keyShowFuriganaInList) ?? false;
  }

  /// 현재 표시 방식 가져오기
  String get displayMode => _displayMode;

  /// 단어 목록에서 후리가나 표시 여부
  bool get showFuriganaInList => _showFuriganaInList;

  /// 표시 방식 설정
  Future<void> setDisplayMode(String mode) async {
    _displayMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFuriganaDisplayMode, mode);
  }

  /// 단어 목록 후리가나 표시 설정
  Future<void> setShowFuriganaInList(bool value) async {
    _showFuriganaInList = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFuriganaInList, value);
  }

  /// 괄호 병기 방식인지 확인
  bool get isParenthesesMode => _displayMode == 'parentheses';

  /// 후리가나 방식인지 확인
  bool get isFuriganaMode => _displayMode == 'furigana';
}
