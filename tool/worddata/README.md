# Cue-pool pipeline

This directory turns open lexical resources into the two JSON assets used by
the app. The app itself contains no cue words.

## Run it

```sh
python3 -m pip install -r requirements.txt
python3 fetch_sources.py     # downloads and caches upstream data
python3 build_db.py          # compiles MultiWordNet SQL dumps into SQLite
python3 build_words.py       # writes assets/words/en.json and es.json
```

Everything downloaded goes to `cache/` and is git-ignored. The generated
`assets/words/*.json` and `report.md` are committed, so normal app builds and
F-Droid builds never touch the network.

## Selection

For English:

1. A word must be a WordNet noun whose first sense is under `physical entity`.
2. The Brysbaert ratings must mark it as noun-dominant, concrete and familiar.
3. Its frequency must be in the middle band of the OpenSubtitles list.
4. Brown-corpus noun usage must not be a minority usage.
5. It must survive `denylist.json`.

For Spanish:

1. The word must be a MultiWordNet noun and map to a concrete WordNet concept.
2. MEGAHit concreteness and imageability must both be high.
3. CESS-ESP noun usage must not be a minority usage.
4. Its frequency must be in the middle band of the Spanish OpenSubtitles list.
5. It must survive `denylist.json`.
6. A plural form is dropped when the singular also made the selection.

The denylist is not the cue list. It only removes concepts that are not calm,
concrete or mundane enough for a sleep session: people, violence, medical and
death terms, sex and body terms, alcohol and drugs, religion and the occult,
screens and work, money and commerce, scary animals, disasters and generic
abstract nouns. Every excluded word is visible and reviewable in
`denylist.json`; reasons are grouped at the top level.

Short English words that are regular plurals are skipped when their singular is
also a WordNet lemma. The engine also keeps a word out of the sequence until the
entire pool has been used, so a 30–60 minute session normally hears each word
once.

## Output

`build_words.py` writes:

- `assets/words/en.json`
- `assets/words/es.json`
- `report.md` with counts, category distribution, samples and source notes

Each word entry is `{"w": "...", "c": "category", "z": zipf}`. The category is
derived from a small curated set of WordNet ancestors and is used only to keep
semantically similar cues apart. The engine does not show or speak categories.

## Determinism

`build_words.py` uses no randomness except a fixed sample seed for the report.
The output ordering is alphabetical. Re-running the same versions of the cached
sources yields the same words; the generation date in the JSON header changes.

`fetch_sources.py` uses jsDelivr mirrors for the WordNet/NLTK data, PyPI for
MultiWordNet, Hugging Face for the ratings, and `remotezip` for the 172 MB
MEGAHit archive so only the Spanish and English entries are fetched.
