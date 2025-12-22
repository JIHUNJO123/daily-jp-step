import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/translation_service.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Word> _favorites = [];
  bool _isLoading = true;
  Map<int, String> _translatedDefinitions = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavorites();

    final translationService = TranslationService.instance;
    await translationService.init();

    if (translationService.needsTranslation) {
      for (var word in favorites) {
        final embeddedDef = word.getEmbeddedTranslation(
          translationService.currentLanguage,
          'definition',
        );
        if (embeddedDef != null && embeddedDef.isNotEmpty) {
          _translatedDefinitions[word.id] = embeddedDef;
        }
      }
    }

    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Word word) async {
    await DatabaseHelper.instance.toggleFavorite(word.id, false);
    await _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.removedFromFavorites),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noFavoritesYet,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapHeartToSave,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final word = _favorites[index];
                  final translatedDef = _translatedDefinitions[word.id];

                  return Dismissible(
                    key: Key('favorite_${word.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _removeFavorite(word),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (word.hiragana != null &&
                                word.hiragana!.isNotEmpty &&
                                word.hiragana != word.word)
                              Text(
                                word.hiragana!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            Text(
                              translatedDef ?? word.definition,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _removeFavorite(word),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WordDetailScreen(word: word),
                            ),
                          );
                          _loadFavorites();
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
