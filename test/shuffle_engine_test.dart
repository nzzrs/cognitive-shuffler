import 'package:cognitive_shuffler/domain/shuffle_engine.dart';
import 'package:cognitive_shuffler/domain/word.dart';
import 'package:flutter_test/flutter_test.dart';

WordPool _pool() {
  const categories = [
    'furniture',
    'food',
    'animal',
    'plant',
    'building',
    'water',
    'weather',
    'clothing',
    'vehicle',
    'tool',
  ];
  final words = <CueWord>[];
  for (var index = 0; index < 300; index++) {
    words.add(
      CueWord(
        word: '${String.fromCharCode(97 + index % 26)}$index',
        category: categories[index % categories.length],
      ),
    );
  }
  return WordPool.parse(
    'en',
    '{"words":[${words.map((word) => '{"w":"${word.word}","c":"${word.category}"}').join(',')}]}',
  );
}

void main() {
  test('is deterministic for a seed', () {
    final first = ShuffleEngine(
      seed: 42,
    ).generate(pool: _pool(), count: 80, intervalMs: 8000);
    final second = ShuffleEngine(
      seed: 42,
    ).generate(pool: _pool(), count: 80, intervalMs: 8000);
    expect(
      first.map((cue) => cue.word.word).toList(),
      second.map((cue) => cue.word.word).toList(),
    );
    expect(
      first.map((cue) => cue.atMs).toList(),
      second.map((cue) => cue.atMs).toList(),
    );
    final third = ShuffleEngine(
      seed: 43,
    ).generate(pool: _pool(), count: 80, intervalMs: 8000);
    expect(
      first.map((cue) => cue.word.word).toList(),
      isNot(third.map((cue) => cue.word.word).toList()),
    );
  });

  test('does not repeat a word before the pool is exhausted', () {
    final cues = ShuffleEngine(
      seed: 7,
    ).generate(pool: _pool(), count: 300, intervalMs: 6000);
    final words = cues.map((cue) => cue.word.word).toList();
    expect(words.toSet().length, 300);
  });

  test('keeps recent categories and initials apart when possible', () {
    final cues = ShuffleEngine(
      seed: 9,
    ).generate(pool: _pool(), count: 298, intervalMs: 5000);
    for (var index = 3; index < cues.length; index++) {
      final recent = cues
          .sublist(index - 3, index)
          .map((cue) => cue.word.category)
          .toSet();
      expect(
        recent.contains(cues[index].word.category),
        isFalse,
        reason: 'category repeated at $index',
      );
      expect(
        cues[index - 1].word.word[0],
        isNot(cues[index].word.word[0]),
        reason: 'initial repeated at $index',
      );
    }
  });

  test('spaces cues with bounded jitter and a short lead-in', () {
    final cues = ShuffleEngine(
      seed: 3,
    ).generate(pool: _pool(), count: 40, intervalMs: 8000, jitter: 0.15);
    expect(cues.first.atMs, 1500);
    for (var index = 1; index < cues.length; index++) {
      final gap = cues[index].atMs - cues[index - 1].atMs;
      expect(gap, greaterThanOrEqualTo(6800));
      expect(gap, lessThanOrEqualTo(9200));
    }
  });

  test('refills the pool for long sessions', () {
    final cues = ShuffleEngine(
      seed: 12,
    ).generate(pool: _pool(), count: 650, intervalMs: 4000);
    expect(cues.length, 650);
    expect(cues.map((cue) => cue.word.word).toSet().length, 300);
  });

  test('rejects invalid parameters', () {
    expect(
      () => ShuffleEngine().generate(pool: _pool(), count: 0, intervalMs: 8000),
      throwsArgumentError,
    );
    expect(
      () => ShuffleEngine().generate(pool: _pool(), count: 10, intervalMs: 10),
      throwsArgumentError,
    );
  });
}
