import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final bool favoritesOnly;

  const WordListScreen({
    super.key,
    this.category,
    this.categoryName,
    this.isFlashcardMode = false,
    this.favoritesOnly = false,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _words = [];
  bool _isLoading = true;
  int _currentFlashcardIndex = 0;
  PageController _pageController = PageController();
  String _sortOrder = 'alphabetical';
  String _searchQuery = '';
  bool _showCategoryBadge = true; // 카테고리 뱃지 표시 여부

  final ScrollController _listScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Map<int, String> _translatedDefinitions = {};

  // 스크롤/플래시카드 위치 저장용 키
  String get _scrollPositionKey =>
      'scroll_position_${widget.category ?? "all"}_${widget.isFlashcardMode}';
  String get _flashcardPositionKey =>
      'flashcard_position_${widget.category ?? "all"}';

  @override
  void initState() {
    super.initState();
    _initFlashcardPosition();
    _listScrollController.addListener(_onScroll);
    _loadWords();
    _loadUnlockStatus();
    AdService.instance.loadRewardedAd();
    _loadSettings();
  }

  Future<void> _initFlashcardPosition() async {
    // 플래시카드 모드에서 저장된 위치 복원
    if (widget.isFlashcardMode) {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_flashcardPositionKey) ?? 0;
      if (mounted) {
        setState(() {
          _currentFlashcardIndex = savedIndex;
          _pageController = PageController(initialPage: savedIndex);
        });
      }
    }
  }

  // 스크롤 이벤트 핸들러 - 실시간으로 위치 저장
  void _onScroll() {
    _saveScrollPosition();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCategoryBadge = prefs.getBool('showCategoryBadge') ?? true;
    });
  }

  Future<void> _restoreScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getDouble(_scrollPositionKey);
    if (savedPosition != null && savedPosition > 0) {
      // 스크롤 위치 복원을 위해 약간의 지연 추가
      await Future.delayed(const Duration(milliseconds: 100));
      if (_listScrollController.hasClients && mounted) {
        _listScrollController.jumpTo(savedPosition);
      }
    }
  }

  Future<void> _saveScrollPosition() async {
    if (_listScrollController.hasClients) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_scrollPositionKey, _listScrollController.offset);
    }
  }

  Future<void> _saveFlashcardPosition(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_flashcardPositionKey, index);
  }

  Future<void> _loadUnlockStatus() async {
    await AdService.instance.loadUnlockStatus();
    if (mounted) setState(() {});
  }

  // 잠긴 단어인지 확인 (짝수 인덱스 = 2, 4, 6...)
  bool _isWordLocked(int index) {
    // 홀수 단어는 무료, 짝수 단어(2, 4, 6...)는 잠김
    if (index % 2 == 0) return false; // 0, 2, 4... -> 1번, 3번, 5번 단어 (무료)
    return !AdService.instance.isUnlocked; // 1, 3, 5... -> 2번, 4번, 6번 단어 (잠김)
  }

  // 광고 시청 다이얼로그 표시
  void _showUnlockDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.lock, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.lockedContent)),
              ],
            ),
            content: Text(l10n.watchAdToUnlock),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _watchAdToUnlock();
                },
                icon: const Icon(Icons.play_circle_outline),
                label: Text(l10n.watchAd),
              ),
            ],
          ),
    );
  }

  // 광고 시청하여 잠금 해제
  Future<void> _watchAdToUnlock() async {
    final l10n = AppLocalizations.of(context)!;
    final adService = AdService.instance;

    if (!adService.isAdReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      adService.loadRewardedAd();
      return;
    }

    await adService.showRewardedAd(
      onRewarded: () async {
        await adService.unlockUntilMidnight();
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.unlockedUntilMidnight)));
        }
      },
    );
  }

  Future<void> _loadWords() async {
    List<Word> words;
    if (widget.favoritesOnly) {
      words = await DatabaseHelper.instance.getFavorites();
    } else if (widget.category != null) {
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

    // 스크롤 위치 복원 (리스트뷰 모드에서만)
    if (!widget.isFlashcardMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    }
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
    _listScrollController.removeListener(_onScroll);
    _pageController.dispose();
    _listScrollController.dispose();
    _searchController.dispose();
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
          // 카테고리 뱃지 토글 (전체 단어 보기 또는 플래시카드 모드에서만)
          if (widget.category == null)
            IconButton(
              icon: Icon(
                _showCategoryBadge ? Icons.label : Icons.label_off,
                color:
                    _showCategoryBadge
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              tooltip: 'Toggle category badge',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  _showCategoryBadge = !_showCategoryBadge;
                });
                await prefs.setBool('showCategoryBadge', _showCategoryBadge);
              },
            ),
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
          // 잠금 해제 안내 배너 (잠긴 상태일 때만 표시)
          if (!AdService.instance.isUnlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
                ),
              ),
              child: InkWell(
                onTap: _showUnlockDialog,
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.watchAdToUnlock,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            color: Colors.deepOrange.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.watchAd,
                            style: TextStyle(
                              color: Colors.deepOrange.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildListView(List<Word> words) {
    if (words.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.cannotLoadWords));
    }

    return ListView.builder(
      controller: _listScrollController,
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isLocked = _isWordLocked(index);
        final translatedDef = _translatedDefinitions[word.id];
        final definition =
            isLocked ? '🔒 ••••••••••••••' : (translatedDef ?? word.definition);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Row(
              children: [
                if (isLocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock, size: 16, color: Colors.orange),
                  ),
                Expanded(
                  child: Text(
                    isLocked ? '${word.word.substring(0, 1)}••••' : word.word,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                ),
                // 카테고리 뱃지 (전체 단어 보기에서만 표시)
                if (widget.category == null && _showCategoryBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(word.category),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.hiragana != null &&
                    word.hiragana!.isNotEmpty &&
                    word.hiragana != word.word)
                  Text(
                    isLocked ? '••••' : word.hiragana!,
                    style: TextStyle(
                      color:
                          isLocked
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                Text(
                  definition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isLocked ? Colors.grey : null),
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
            onTap: () async {
              // 잠긴 단어면 광고 다이얼로그 표시
              if (isLocked) {
                _showUnlockDialog();
                return;
              }
              final result = await Navigator.push<int>(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WordDetailScreen(
                        word: word,
                        wordList: List<Word>.from(words),
                        currentIndex: index,
                      ),
                ),
              );
              if (result != null && mounted) {
                // 반환된 위치로 스크롤하고 저장
                final targetOffset = result * 80.0;
                if (_listScrollController.hasClients) {
                  _listScrollController.jumpTo(targetOffset);
                  _saveScrollPosition();
                }
                if (result != index && _listScrollController.hasClients) {
                  _listScrollController.animateTo(
                    targetOffset,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
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
              _saveFlashcardPosition(index);
            },
            itemBuilder: (context, index) {
              final word = words[index];
              final translatedDef = _translatedDefinitions[word.id];

              // 히라가나가 단어와 같거나 비어있으면 표시하지 않음
              final showHiragana =
                  word.hiragana != null &&
                  word.hiragana!.isNotEmpty &&
                  word.hiragana != word.word;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildCardFace(
                    word.word,
                    showHiragana ? word.hiragana : null,
                    true,
                    word,
                  ),
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
            // 카테고리 뱃지 (앞면에서만, 전체 단어 보기에서만)
            if (isFront && widget.category == null && _showCategoryBadge) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getCategoryName(word.category),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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

  /// 카테고리 ID를 현재 언어로 번역된 이름으로 변환
  String _getCategoryName(String categoryId) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryId) {
      case 'greeting':
        return l10n.greeting;
      case 'restaurant':
        return l10n.restaurant;
      case 'shopping':
        return l10n.shopping;
      case 'transport':
        return l10n.transport;
      case 'hotel':
        return l10n.hotel;
      case 'emergency':
        return l10n.emergency;
      case 'daily':
        return l10n.daily;
      case 'emotion':
        return l10n.emotion;
      case 'hospital':
        return l10n.hospital;
      case 'school':
        return l10n.school;
      case 'business':
        return l10n.business;
      case 'bank':
        return l10n.bank;
      case 'salon':
        return l10n.salon;
      case 'home':
        return l10n.home;
      case 'weather':
        return l10n.weather;
      case 'party':
        return l10n.party;
      default:
        return categoryId;
    }
  }
}
