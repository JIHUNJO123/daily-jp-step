import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/generated/app_localizations.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/translation_service.dart';
import '../services/ad_service.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatefulWidget {
  final String? category;
  final String? categoryName;
  final bool isFlashcardMode;

  const WordListScreen({
    super.key,
    this.category,
    this.categoryName,
    this.isFlashcardMode = false,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _words = [];
  bool _isLoading = true;
  int _currentFlashcardIndex = 0;
  late PageController _pageController;
  String _sortOrder = 'alphabetical';
  bool _isBannerAdLoaded = false;
  String _searchQuery = '';

  final ScrollController _listScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Map<int, String> _translatedDefinitions = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadWords();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    final adService = AdService.instance;
    await adService.initialize();

    if (!adService.adsRemoved) {
      await adService.loadBannerAd(
        onLoaded: () {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
      );
    }
  }

  Future<void> _loadWords() async {
    List<Word> words;
    if (widget.category != null) {
      words = await DatabaseHelper.instance.getWordsByCategory(
        widget.category!,
      );
    } else {
      words = await DatabaseHelper.instance.getAllWords();
    }

    // Load translations for all words
    final translationService = TranslationService.instance;
    await translationService.init();

    if (translationService.needsTranslation) {
      for (var word in words) {
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
      _words = words;
      _isLoading = false;
    });
  }

  List<Word> get _filteredWords {
    if (_searchQuery.isEmpty) return _words;
    final query = _searchQuery.toLowerCase();
    return _words.where((w) {
      return w.word.toLowerCase().contains(query) ||
          (w.hiragana?.toLowerCase().contains(query) ?? false) ||
          w.definition.toLowerCase().contains(query) ||
          (_translatedDefinitions[w.id]?.toLowerCase().contains(query) ??
              false);
    }).toList();
  }

  void _sortWords(String order) {
    setState(() {
      _sortOrder = order;
      if (order == 'alphabetical') {
        _words.sort((a, b) => a.word.compareTo(b.word));
      } else if (order == 'random') {
        _words.shuffle();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listScrollController.dispose();
    _searchController.dispose();
    AdService.instance.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayWords = _filteredWords;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName ??
              (widget.isFlashcardMode ? l10n.flashcard : l10n.allWords),
        ),
        actions: [
          if (!widget.isFlashcardMode)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _sortWords,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'alphabetical',
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          color:
                              _sortOrder == 'alphabetical'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.alphabetical),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'random',
                    child: Row(
                      children: [
                        Icon(
                          Icons.shuffle,
                          color:
                              _sortOrder == 'random'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.random),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                children: [
                  Text(
                    'Search: "$_searchQuery" (${displayWords.length} results)',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.isFlashcardMode
                    ? _buildFlashcardView(displayWords)
                    : _buildListView(displayWords),
          ),
          _buildBannerAd(),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.search),
            content: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _searchQuery = _searchController.text);
                  Navigator.pop(context);
                },
                child: Text(l10n.search),
              ),
            ],
          ),
    );
  }

  Widget _buildBannerAd() {
    final adService = AdService.instance;
    if (adService.adsRemoved ||
        !_isBannerAdLoaded ||
        adService.bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: adService.bannerAd!.size.width.toDouble(),
      height: adService.bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: adService.bannerAd!),
    );
  }

  Widget _buildListView(List<Word> words) {
    if (words.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.cannotLoadWords));
    }

    return ListView.builder(
      controller: _listScrollController,
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final translatedDef = _translatedDefinitions[word.id];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              word.word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              icon: Icon(
                word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: word.isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(word),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(word: word),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFlashcardView(List<Word> words) {
    final l10n = AppLocalizations.of(context)!;

    if (words.isEmpty) {
      return Center(child: Text(l10n.cannotLoadWords));
    }

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_currentFlashcardIndex + 1} / ${words.length}',
            style: const TextStyle(fontSize: 16),
          ),
        ),

        // Flashcard
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: words.length,
            onPageChanged: (index) {
              setState(() => _currentFlashcardIndex = index);
            },
            itemBuilder: (context, index) {
              final word = words[index];
              final translatedDef = _translatedDefinitions[word.id];

              return Padding(
                padding: const EdgeInsets.all(24),
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildCardFace(word.word, word.hiragana, true, word),
                  back: _buildCardFace(
                    translatedDef ?? word.definition,
                    word.exampleJp,
                    false,
                    word,
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed:
                    _currentFlashcardIndex > 0
                        ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        : null,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.previous),
              ),
              ElevatedButton.icon(
                onPressed:
                    _currentFlashcardIndex < words.length - 1
                        ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.next),
              ),
            ],
          ),
        ),

        Text(
          l10n.tapToFlip,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCardFace(
    String mainText,
    String? subText,
    bool isFront,
    Word word,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors:
                isFront
                    ? [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ]
                    : [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withOpacity(0.8),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mainText,
              style: TextStyle(
                fontSize: isFront ? 48 : 24,
                fontWeight: FontWeight.bold,
                color:
                    isFront
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subText != null && subText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                subText,
                style: TextStyle(
                  fontSize: 18,
                  color: (isFront
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSecondary)
                      .withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
            IconButton(
              icon: Icon(
                word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    isFront
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSecondary,
                size: 32,
              ),
              onPressed: () => _toggleFavorite(word),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Word word) async {
    await DatabaseHelper.instance.toggleFavorite(word.id, !word.isFavorite);
    setState(() {
      word.isFavorite = !word.isFavorite;
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          word.isFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
