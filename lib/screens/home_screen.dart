import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/translation_service.dart';
import '../services/ad_service.dart';
import 'word_list_screen.dart';
import 'word_detail_screen.dart';
import 'favorites_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Word? _todayWord;
  String? _translatedDefinition;
  bool _isLoading = true;
  String? _lastLanguage;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    AdService.instance.loadRewardedAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLanguage = TranslationService.instance.currentLanguage;
    if (_lastLanguage != null && _lastLanguage != currentLanguage) {
      _loadData();
    }
    _lastLanguage = currentLanguage;
  }

  Future<void> _loadData() async {
    try {
      // Load today's word
      final word = await DatabaseHelper.instance.getTodayWord();

      // Load categories
      final categories = await DatabaseHelper.instance.loadCategories();

      if (word != null) {
        final translationService = TranslationService.instance;
        await translationService.init();

        if (translationService.needsTranslation) {
          final embeddedTranslation = word.getEmbeddedTranslation(
            translationService.currentLanguage,
            'definition',
          );

          if (mounted) {
            setState(() {
              _todayWord = word;
              _translatedDefinition = embeddedTranslation;
              _categories = categories;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _todayWord = word;
              _translatedDefinition = null;
              _categories = categories;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _todayWord = null;
            _categories = categories;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _todayWord = null;
          _isLoading = false;
        });
      }
    }
  }

  void _showLevelSelectionDialog({required bool isQuiz}) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = TranslationService.instance.currentLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isQuiz ? l10n.quiz : l10n.flashcard),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // All Words
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: Text(l10n.allWords),
                onTap: () {
                  Navigator.pop(context);
                  if (isQuiz) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WordListScreen(isFlashcardMode: true),
                      ),
                    );
                  }
                },
              ),
              // Favorites
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(l10n.favorites),
                onTap: () {
                  Navigator.pop(context);
                  if (isQuiz) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const QuizScreen(favoritesOnly: true),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WordListScreen(
                          isFlashcardMode: true,
                          favoritesOnly: true,
                        ),
                      ),
                    );
                  }
                },
              ),
              if (_categories.isNotEmpty) ...[
                const Divider(),
                // Categories
                ..._categories.map(
                  (category) => ListTile(
                    leading: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(category.getName(langCode)),
                    onTap: () {
                      Navigator.pop(context);
                      if (isQuiz) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(category: category.id),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordListScreen(
                              isFlashcardMode: true,
                              category: category.id,
                              categoryName: category.getName(langCode),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Word Card
                  _buildTodayWordCard(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    l10n.learning,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuGrid(),

                  const SizedBox(height: 24),

                  // Categories
                  Text(
                    l10n.categories,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryCards(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWordCard() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Card(
        child: Container(
          height: 150,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_todayWord == null) {
      return Card(
        child: Container(
          height: 150,
          alignment: Alignment.center,
          child: Text(l10n.cannotLoadWords),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(word: _todayWord!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.todayWord,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _todayWord!.word,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              if (_todayWord!.hiragana != null &&
                  _todayWord!.hiragana!.isNotEmpty &&
                  _todayWord!.hiragana != _todayWord!.word)
                Text(
                  _todayWord!.hiragana!,
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _translatedDefinition ?? _todayWord!.definition,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final menuItems = [
      {
        'icon': Icons.list_alt,
        'title': l10n.allWords,
        'subtitle': l10n.viewAllWords,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordListScreen()),
            ),
      },
      {
        'icon': Icons.favorite,
        'title': l10n.favorites,
        'subtitle': l10n.savedWords,
        'color': Colors.red,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
      },
      {
        'icon': Icons.style,
        'title': l10n.flashcard,
        'subtitle': l10n.cardLearning,
        'color': Colors.orange,
        'onTap': () => _showLevelSelectionDialog(isQuiz: false),
      },
      {
        'icon': Icons.quiz,
        'title': l10n.quiz,
        'subtitle': l10n.testYourself,
        'color': Colors.green,
        'onTap': () => _showLevelSelectionDialog(isQuiz: true),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          child: InkWell(
            onTap: item['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCards() {
    final langCode = TranslationService.instance.currentLanguage;

    if (_categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(category.icon, style: const TextStyle(fontSize: 28)),
            title: Text(
              category.getName(langCode),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${category.wordCount} words'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordListScreen(
                    category: category.id,
                    categoryName: category.getName(langCode),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
