import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/ad_service.dart';
import '../services/translation_service.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  final List<Word>? wordList;
  final int? currentIndex;

  const WordDetailScreen({
    super.key,
    required this.word,
    this.wordList,
    this.currentIndex,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late Word _word;
  String? _translatedDefinition;
  String? _translatedExample;
  late int _currentIndex;

  bool get _hasNavigation =>
      widget.wordList != null && widget.wordList!.length > 1;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
    _currentIndex = widget.currentIndex ?? 0;
    _loadTranslations();
  }

  // 잠긴 단어인지 확인 (짝수 인덱스 = 2, 4, 6...)
  bool _isWordLocked(int index) {
    if (index % 2 == 0) return false;
    return !AdService.instance.isUnlocked;
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      int newIndex = _currentIndex - 1;
      if (_isWordLocked(newIndex)) return;

      setState(() {
        _currentIndex = newIndex;
        _word = widget.wordList![_currentIndex];
        _translatedDefinition = null;
        _translatedExample = null;
      });
      _loadTranslations();
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.wordList!.length - 1) {
      int newIndex = _currentIndex + 1;
      if (_isWordLocked(newIndex)) return;

      setState(() {
        _currentIndex = newIndex;
        _word = widget.wordList![_currentIndex];
        _translatedDefinition = null;
        _translatedExample = null;
      });
      _loadTranslations();
    }
  }

  Future<void> _loadTranslations() async {
    final translationService = TranslationService.instance;
    await translationService.init();

    if (translationService.needsTranslation) {
      final langCode = translationService.currentLanguage;
      final embeddedDef = _word.getEmbeddedTranslation(langCode, 'definition');
      final embeddedEx = _word.getEmbeddedTranslation(langCode, 'example');

      if (mounted) {
        setState(() {
          _translatedDefinition = embeddedDef;
          _translatedExample = embeddedEx;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper.instance.toggleFavorite(_word.id, !_word.isFavorite);
    setState(() {
      _word = _word.copyWith(isFavorite: !_word.isFavorite);
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _word.isFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_currentIndex);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_currentIndex),
          ),
          title: Text(
            _hasNavigation
                ? '${_currentIndex + 1} / ${widget.wordList!.length}'
                : l10n.wordDetail,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _word.isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word Card
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _word.word,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      if (_word.hiragana != null &&
                          _word.hiragana!.isNotEmpty &&
                          _word.hiragana != _word.word)
                        Text(
                          _word.hiragana!,
                          style: TextStyle(
                            fontSize: 24,
                            color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Definition
              Text(
                l10n.definition,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _word.definition,
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (_translatedDefinition != null &&
                          _translatedDefinition!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          _translatedDefinition!,
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Japanese Example
              if (_word.exampleJp != null && _word.exampleJp!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.example,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _word.exampleJp!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        if (_word.exampleReading != null &&
                            _word.exampleReading!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _word.exampleReading!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                        if (_word.example.isNotEmpty) ...[
                          const Divider(height: 24),
                          Text(
                            _word.example,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                        if (_translatedExample != null &&
                            _translatedExample!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _translatedExample!,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Category badge
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: Text(CategoryList.icons[_word.category] ?? '📚'),
                    label: Text(_word.category),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ],
              ),
              // Navigation buttons at bottom
              if (_hasNavigation) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.previous),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          _currentIndex < widget.wordList!.length - 1
                              ? _goToNext
                              : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.next),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
