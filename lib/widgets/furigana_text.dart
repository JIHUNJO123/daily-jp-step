import 'package:flutter/material.dart';

/// HTML Ruby 스타일의 후리가나 표시 위젯
/// 한자 위에 작은 글씨로 읽기(히라가나)를 표시
class FuriganaText extends StatelessWidget {
  final String kanji;
  final String reading;
  final double mainFontSize;
  final double furiganaFontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const FuriganaText({
    super.key,
    required this.kanji,
    required this.reading,
    this.mainFontSize = 32,
    this.furiganaFontSize = 12,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (kanji.isEmpty || kanji == reading) {
      return Text(
        reading.isNotEmpty ? reading : kanji,
        style: TextStyle(
          fontSize: mainFontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      );
    }

    final parts = _parseFurigana(kanji, reading);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: parts.map((part) => _buildPart(part)).toList(),
    );
  }

  Widget _buildPart(_FuriganaPart part) {
    if (part.reading == null || part.text == part.reading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: furiganaFontSize + 2),
            Text(
              part.text,
              style: TextStyle(
                fontSize: mainFontSize,
                color: color,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          part.reading!,
          style: TextStyle(
            fontSize: furiganaFontSize,
            color: color ?? Colors.grey[600],
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          part.text,
          style: TextStyle(
            fontSize: mainFontSize,
            color: color,
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<_FuriganaPart> _parseFurigana(String word, String reading) {
    final parts = <_FuriganaPart>[];

    if (!_containsKanji(word)) {
      return [_FuriganaPart(word, null)];
    }

    int wordIdx = 0;
    int readIdx = 0;

    while (wordIdx < word.length) {
      final char = word[wordIdx];

      if (_isKanji(char)) {
        int kanjiStart = wordIdx;
        while (wordIdx < word.length && _isKanji(word[wordIdx])) {
          wordIdx++;
        }
        String kanjiPart = word.substring(kanjiStart, wordIdx);

        String? nextHiraganaInWord;
        if (wordIdx < word.length) {
          int hiraganaStart = wordIdx;
          while (wordIdx < word.length && !_isKanji(word[wordIdx])) {
            wordIdx++;
          }
          nextHiraganaInWord = word.substring(hiraganaStart, wordIdx);
          wordIdx = hiraganaStart;
        }

        if (nextHiraganaInWord != null && nextHiraganaInWord.isNotEmpty) {
          int nextHiraganaPos = reading.indexOf(nextHiraganaInWord, readIdx);
          if (nextHiraganaPos > readIdx) {
            String kanjiReading = reading.substring(readIdx, nextHiraganaPos);
            parts.add(_FuriganaPart(kanjiPart, kanjiReading));
            readIdx = nextHiraganaPos;
          } else {
            parts.add(_FuriganaPart(kanjiPart, reading.substring(readIdx)));
            readIdx = reading.length;
          }
        } else {
          String kanjiReading = reading.substring(readIdx);
          parts.add(_FuriganaPart(kanjiPart, kanjiReading));
          readIdx = reading.length;
        }
      } else {
        int kanaStart = wordIdx;
        while (wordIdx < word.length && !_isKanji(word[wordIdx])) {
          wordIdx++;
        }
        String kanaPart = word.substring(kanaStart, wordIdx);
        parts.add(_FuriganaPart(kanaPart, null));

        if (reading.length > readIdx &&
            reading.substring(readIdx).startsWith(kanaPart)) {
          readIdx += kanaPart.length;
        }
      }
    }

    return parts;
  }

  bool _containsKanji(String text) {
    for (int i = 0; i < text.length; i++) {
      if (_isKanji(text[i])) return true;
    }
    return false;
  }

  bool _isKanji(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF);
  }
}

class _FuriganaPart {
  final String text;
  final String? reading;

  _FuriganaPart(this.text, [this.reading]);
}
