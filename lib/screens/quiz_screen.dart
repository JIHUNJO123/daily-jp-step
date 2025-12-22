import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/translation_service.dart';

class QuizScreen extends StatefulWidget {
  final String? category;

  const QuizScreen({super.key, this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Word> _words = [];
  List<Word> _allWords = []; // 전체 단어 (오답 옵션용)
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  List<Word> _currentOptions = [];
  bool _isWordToMeaning = true;
  Map<int, String> _translatedDefinitions = {};

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    // 먼저 전체 단어를 로드 (오답 옵션용)
    final allWords = await DatabaseHelper.instance.getAllWords();

    List<Word> words;
    if (widget.category != null) {
      words = await DatabaseHelper.instance.getWordsByCategory(
        widget.category!,
      );
    } else {
      words = allWords;
    }

    // Load translations
    final translationService = TranslationService.instance;
    await translationService.init();

    if (translationService.needsTranslation) {
      for (var word in allWords) {
        final embeddedDef = word.getEmbeddedTranslation(
          translationService.currentLanguage,
          'definition',
        );
        if (embeddedDef != null && embeddedDef.isNotEmpty) {
          _translatedDefinitions[word.id] = embeddedDef;
        }
      }
    }

    // Shuffle and limit to 10 questions
    words.shuffle();
    words = words.take(10).toList();

    setState(() {
      _allWords = allWords;
      _words = words;
      _isLoading = false;
      _generateOptions();
    });
  }

  void _generateOptions() {
    if (_words.isEmpty || _currentQuestionIndex >= _words.length) return;

    final currentWord = _words[_currentQuestionIndex];

    // 전체 단어에서 오답 옵션 선택 (현재 단어 제외)
    // definition이 있거나 번역된 definition이 있는 것만
    final availableWords =
        _allWords.where((w) {
          if (w.id == currentWord.id) return false;
          if (w.word.isEmpty) return false;

          // definition 또는 번역된 definition이 있어야 함
          final hasDefinition =
              w.definition.isNotEmpty && w.definition.trim().isNotEmpty;
          final hasTranslation =
              _translatedDefinitions[w.id]?.isNotEmpty == true;

          return hasDefinition || hasTranslation;
        }).toList();

    availableWords.shuffle();

    // 최소 3개의 오답 옵션
    final wrongOptions = availableWords.take(3).toList();

    _currentOptions = [currentWord, ...wrongOptions];
    _currentOptions.shuffle();
  }

  void _checkAnswer(int index) {
    if (_answered) return;

    final currentWord = _words[_currentQuestionIndex];
    final selectedWord = _currentOptions[index];

    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (selectedWord.id == currentWord.id) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _words.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
        _generateOptions();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_score / _words.length * 100).round();
    String message;

    if (percentage == 100) {
      message = l10n.excellent;
    } else if (percentage >= 80) {
      message = l10n.great;
    } else if (percentage >= 60) {
      message = l10n.good;
    } else {
      message = l10n.keepPracticing;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.quizComplete),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_score / ${_words.length}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(l10n.finish),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _answered = false;
                    _selectedAnswer = null;
                    _words.shuffle();
                    _generateOptions();
                  });
                },
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: Center(child: Text(l10n.cannotLoadWords)),
      );
    }

    final currentWord = _words[_currentQuestionIndex];
    final translatedDef = _translatedDefinitions[currentWord.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${l10n.score}: $_score',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _words.length,
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.question} ${_currentQuestionIndex + 1} / ${_words.length}',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // Question
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_isWordToMeaning) ...[
                      Text(
                        currentWord.word,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentWord.hiragana != null &&
                          currentWord.hiragana!.isNotEmpty &&
                          currentWord.hiragana != currentWord.word)
                        Text(
                          currentWord.hiragana!,
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ] else ...[
                      Text(
                        translatedDef ?? currentWord.definition,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: _currentOptions.length,
                itemBuilder: (context, index) {
                  final option = _currentOptions[index];
                  final optionTranslated = _translatedDefinitions[option.id];
                  final isCorrect = option.id == currentWord.id;
                  final isSelected = _selectedAnswer == index;

                  Color? cardColor;
                  if (_answered) {
                    if (isCorrect) {
                      cardColor = Colors.green.withOpacity(0.3);
                    } else if (isSelected) {
                      cardColor = Colors.red.withOpacity(0.3);
                    }
                  }

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _checkAnswer(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _isWordToMeaning
                                    ? (optionTranslated ?? option.definition)
                                    : option.word,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next button
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    _currentQuestionIndex < _words.length - 1
                        ? l10n.next
                        : l10n.showResult,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
