# Privacy

Cognitive Shuffler has no network permission in release builds.

- No accounts, sign-in, telemetry, analytics or crash reporting.
- No advertising.
- Settings are stored locally with Android `SharedPreferences`.
- Word pools are bundled in the APK.
- Text-to-speech is performed by the speech engine installed on the phone.
- The foreground service only plays audio and shows a media notification.

The debug build adds Android's `INTERNET` permission for Flutter's development
tooling (hot reload). It is absent from release builds; verify with:

```sh
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```
