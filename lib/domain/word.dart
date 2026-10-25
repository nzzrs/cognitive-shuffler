import 'dart:convert';

import 'package:flutter/services.dart';

class CueWord {
  const CueWord({required this.word, required this.category});

  final String word;
  final String category;

  factory CueWord.fromJson(Map<String, dynamic> json) {
    final word = json['w'];
    final category = json['c'];
    if (word is! String || word.isEmpty) {
      throw const FormatException('word is missing');
    }
    if (category is! String || category.isEmpty) {
      throw const FormatException('category is missing');
    }
    return CueWord(word: word, category: category);
  }
}

class WordPool {
  WordPool._({required this.language, required this.words});

  final String language;
  final List<CueWord> words;

  static final Map<String, WordPool> _cache = {};

  static Future<WordPool> loadAsset(String language) async {
    final cached = _cache[language];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/words/$language.json');
    final pool = parse(language, raw);
    _cache[language] = pool;
    return pool;
  }

  static WordPool parse(String language, String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('word pool must be an object');
    }
    final entries = decoded['words'];
    if (entries is! List) {
      throw const FormatException('words must be a list');
    }
    final words = <CueWord>[];
    final seen = <String>{};
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('word entry must be an object');
      }
      final word = CueWord.fromJson(entry);
      if (!seen.add(word.word)) {
        throw FormatException('duplicate word: ${word.word}');
      }
      words.add(word);
    }
    if (words.length < 300) {
      throw FormatException('pool is too small: ${words.length}');
    }
    return WordPool._(language: language, words: List.unmodifiable(words));
  }
}
