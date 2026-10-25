import 'dart:math';

import 'word.dart';

class Cue {
  const Cue({required this.word, required this.atMs});

  final CueWord word;
  final int atMs;
}

/// Produces a deterministic sequence of spaced cue words.
///
/// The rules are intentionally simple and testable:
///  * one word at a time, with slightly irregular spacing;
///  * a word is not repeated until the whole pool has been used;
///  * recent semantic categories and the previous initial letter are avoided
///    whenever the remaining pool allows it.
class ShuffleEngine {
  ShuffleEngine({int? seed}) : _random = Random(seed);

  final Random _random;

  List<Cue> generate({
    required WordPool pool,
    required int count,
    required int intervalMs,
    int firstDelayMs = 1500,
    double jitter = 0.15,
  }) {
    if (count <= 0 || intervalMs < 1000) {
      throw ArgumentError('count and intervalMs must be positive');
    }
    final cues = <Cue>[];
    var remaining = List<CueWord>.of(pool.words);
    final recentCategories = <String>[];
    String? lastWord;
    String? lastInitial;
    var atMs = firstDelayMs;

    for (var index = 0; index < count; index++) {
      if (remaining.isEmpty) {
        remaining = List<CueWord>.of(pool.words);
        if (remaining.length > 1 && remaining.first.word == lastWord) {
          final first = remaining.removeAt(0);
          remaining.add(first);
        }
      }

      final choice = _pick(
        remaining: remaining,
        recentCategories: recentCategories,
        lastInitial: lastInitial,
      );
      remaining.remove(choice);

      cues.add(Cue(word: choice, atMs: atMs));

      lastWord = choice.word;
      lastInitial = choice.word.substring(0, 1).toLowerCase();
      recentCategories.add(choice.category);
      if (recentCategories.length > 3) {
        recentCategories.removeAt(0);
      }

      final factor = 1 + jitter * (_random.nextDouble() * 2 - 1);
      atMs += max(1000, (intervalMs * factor).round());
    }
    return cues;
  }

  CueWord _pick({
    required List<CueWord> remaining,
    required List<String> recentCategories,
    required String? lastInitial,
  }) {
    for (var strictness = 0; strictness < 3; strictness++) {
      final candidates = remaining
          .where((candidate) {
            final sameCategory = recentCategories.contains(candidate.category);
            final sameInitial =
                lastInitial != null && candidate.word.startsWith(lastInitial);
            return switch (strictness) {
              0 => !sameCategory && !sameInitial,
              1 => !sameCategory,
              _ => !sameInitial,
            };
          })
          .toList(growable: false);
      if (candidates.isNotEmpty) {
        return candidates[_random.nextInt(candidates.length)];
      }
    }
    return remaining[_random.nextInt(remaining.length)];
  }
}
