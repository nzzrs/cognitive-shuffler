<p align="center">
  <img src="assets/icon/icon_512.png" width="128" height="128" alt="Cognitive Shuffler app icon">
</p>

<h1 align="center">Cognitive Shuffler</h1>

<p align="center">
  <strong>Drift off with calm, concrete words.</strong><br>
  An offline Android sleep aid with optional pink or brown noise.
</p>

<p align="center">
  <a href="https://github.com/nzzrs/cognitive-shuffler/releases/latest"><strong>Download APK</strong></a>
  &nbsp;·&nbsp;
  <a href="#how-it-works">How it works</a>
  &nbsp;·&nbsp;
  <a href="#privacy">Privacy</a>
  &nbsp;·&nbsp;
  <a href="#development">Build from source</a>
</p>

<p align="center">
  <a href="https://github.com/nzzrs/cognitive-shuffler/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/nzzrs/cognitive-shuffler?style=flat-square"></a>
  <img alt="Android 8.0 or newer" src="https://img.shields.io/badge/Android-8.0%2B-3DDC84?style=flat-square&logo=android&logoColor=white">
  <a href="LICENSE"><img alt="License: GPL-3.0-or-later" src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue?style=flat-square"></a>
</p>

Cognitive Shuffler speaks a slow stream of ordinary, concrete nouns — one small
scene at a time — while an optional procedural noise bed plays underneath. There
is no feed, no streak, no account and no network permission in release builds.

Put the phone down. The words keep going.

## Install

Download the latest APK from
[Releases](https://github.com/nzzrs/cognitive-shuffler/releases/latest) and open
it on an **Android 8.0 (API 26) or newer** device. Allow installation from your
browser or file manager if prompted.

The app is distributed as a direct APK. It is not on Google Play.

## How it works

Cognitive shuffling gives a busy mind unrelated, concrete images to settle on
instead of a train of thought.

1. Choose a sleep timer and a cue language.
2. Start the session and put the phone down.
3. Each word is spoken, with slightly irregular spacing. Picture it briefly,
   then let it go.
4. Optional pink/brown noise masks the room. The session fades out when the
   timer ends.

There is nothing to count, learn or achieve. The screen can stay dark, and
playback continues with the display off.

## Features

- **English and Spanish cue pools**, selected independently from the interface
  language.
- **System text-to-speech** with adjustable speed and volume. No large model or
  proprietary engine is bundled.
- **Procedural pink ↔ brown noise** with volume, colour and warmth controls.
- **Screen-off playback** through an Android foreground media service, with a
  media notification and Bluetooth/headset play/pause.
- **Sleep timer** from presets or any exact minute, with a gentle 60-second fade
  out and a live **+15 min** action.
- **OLED session mode**: a black screen with only the word and an outlined pause
  button. Tap to pause; double tap for the full controls.
- **Material 3 Expressive** design with wallpaper-derived colour, expressive
  shapes and a slowly breathing session backdrop.
- **In-app guide** with a five-step method and the cognitive-shuffle study
  reference.
- **No accounts, analytics, ads or tracking.**

## Privacy

Release builds have **no `INTERNET` permission**. The app cannot send your data
anywhere.

- Settings stay on the device in Android `SharedPreferences`.
- Word pools are bundled in the APK.
- Speech is produced by the TTS engine installed on the phone.
- The foreground service only plays audio and shows the media notification.

The debug build adds Android's `INTERNET` permission for Flutter development
tooling; it is absent from release builds. Details are in [PRIVACY.md](PRIVACY.md).

## Development

Requirements:

- Flutter **3.38.8** (Dart 3.10), pinned in `.tool-versions`
- JDK 17
- Android SDK platform 36 and build-tools 36

```sh
git clone https://github.com/nzzrs/cognitive-shuffler.git
cd cognitive-shuffler
flutter pub get
flutter analyze
flutter test
flutter run
```

Build a release APK with:

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

<details>
<summary><strong>Release signing</strong></summary>

Release builds use a project keystore when `android/key.properties` exists and
fall back to the Flutter template debug key when it does not. Create the file
locally with:

```properties
storeFile=/absolute/path/to/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`key.properties` and all `*.jks` / `*.keystore` files are git-ignored. Never
commit them. The debug-key fallback keeps local and CI builds working without
the keystore; distribution builds should always use the project key.

</details>

<details>
<summary><strong>Offline builds</strong></summary>

Flutter's release engine artifacts normally come from
`storage.googleapis.com/download.flutter.io`. On a machine where that host is
unreachable, mirror the Maven layout locally and point Flutter at it:

```sh
FLUTTER_STORAGE_BASE_URL=file:///path/to/flutter-mirror flutter build apk --release
```

The mirror must contain the `io.flutter:flutter_embedding_release` and
`io.flutter:<abi>_release` artifacts for the pinned engine version.

Android Gradle dependencies can be served from a local Maven mirror by adding
the repository path to `android/local.properties`:

```properties
local.maven=/path/to/android-maven-mirror
```

`android/local.properties` is git-ignored as well.

</details>

## Word data

There are no hand-written cue words in the Dart or Kotlin code. The current
assets contain **558 English** and **368 Spanish** words, generated from open
lexical resources and filtered for concreteness, frequency, noun dominance and
a reviewed denylist.

The pipeline in [`tool/worddata/`](tool/worddata/) is deterministic. The
generated `assets/words/*.json` files are committed, so normal and offline
builds never need network access.

```sh
python3 -m pip install -r tool/worddata/requirements.txt
python3 tool/worddata/fetch_sources.py
python3 tool/worddata/build_db.py
python3 tool/worddata/build_words.py
```

See [`tool/worddata/README.md`](tool/worddata/README.md) and
[`LICENSES.md`](LICENSES.md) for sources and terms.

## Project layout

```text
lib/domain/          word pool, shuffle engine and cue timing
lib/playback/        session controller and native channel wrapper
lib/core/            persisted settings and app metadata
lib/ui/              Material 3 screens, shared widgets and theme
l10n/                English and Spanish ARB resources
android/.../kotlin/  foreground service, TTS, procedural noise, media session
assets/words/        generated English and Spanish cue pools
fastlane/metadata/   store listing, changelogs and icons
tool/worddata/       reproducible word-pool pipeline
test/                engine, data, settings and widget tests
```

## Known limitations

- Voice quality depends on the installed Android speech engine. Spanish needs
  an engine with a Spanish voice; some minimal systems, such as GrapheneOS
  Speech Services, are English-only.
- The cue plan covers up to 12 hours. After the pool is exhausted, words repeat
  in a fresh shuffled order with wide spacing.
- Android apps cannot physically turn off the display. Playback continues when
  you press the power button; the media notification stays available.
- Some OEM battery managers stop background audio. The app uses a foreground
  service and a partial wake lock, but a battery-optimisation exception may be
  required.

## Contributing

Issues and pull requests are welcome. Run `flutter analyze` and `flutter test`
before opening a pull request, and keep generated or signing files out of
commits.

## License

App code: **GNU GPL v3.0 or later**. Cue-pool data: **CC BY-SA 4.0**. See
[`LICENSES.md`](LICENSES.md) for every upstream source.

This is a sleep aid, not a medical treatment.
