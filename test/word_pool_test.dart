import 'dart:convert';
import 'dart:io';

import 'package:cognitive_shuffler/domain/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final language in ['en', 'es']) {
    group('$language word pool', () {
      late WordPool pool;
      late Set<String> denied;

      setUpAll(() {
        final file = File('assets/words/$language.json');
        pool = WordPool.parse(language, file.readAsStringSync());
        final denyJson =
            jsonDecode(File('tool/worddata/denylist.json').readAsStringSync())
                as Map<String, dynamic>;
        denied = <String>{};
        for (final entry in denyJson.entries) {
          if (entry.key == '_comment') continue;
          final value = entry.value as Map<String, dynamic>;
          denied.addAll(
            (value[language] as List<dynamic>? ?? []).map(
              (word) => word as String,
            ),
          );
        }
      });

      test('has a useful number of entries and categories', () {
        expect(pool.words.length, greaterThanOrEqualTo(300));
        expect(
          pool.words.map((word) => word.category).toSet().length,
          greaterThanOrEqualTo(8),
        );
      });

      test('contains no duplicates or malformed words', () {
        final seen = <String>{};
        for (final word in pool.words) {
          expect(seen.add(word.word), isTrue, reason: word.word);
          expect(word.word, word.word.toLowerCase());
          expect(
            word.word,
            matches(
              language == 'en'
                  ? RegExp(r'^[a-z]{3,11}$')
                  : RegExp(r'^[a-záéíóúüñ]{3,12}$'),
            ),
          );
          expect(word.category, isNotEmpty);
        }
      });

      test('does not contain denylisted words', () {
        final found = pool.words
            .map((word) => word.word)
            .where(denied.contains)
            .toList();
        expect(found, isEmpty, reason: found.join(', '));
      });

      test('is stable and contains the expected marker words', () {
        final again = WordPool.parse(
          language,
          File('assets/words/$language.json').readAsStringSync(),
        );
        expect(
          again.words.map((word) => word.word).toList(),
          pool.words.map((word) => word.word).toList(),
        );
        expect(
          pool.words.any(
            (word) => word.word == (language == 'en' ? 'house' : 'casa'),
          ),
          isTrue,
        );
      });
    });
  }
}
