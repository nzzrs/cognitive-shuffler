# Changelog

## Unreleased

- Settings now owns every default; Home keeps only the start action and the
  session length.
- The full Android wallpaper palette now drives both light and dark themes,
  including surfaces, and refreshes when the app resumes.
- Reopening the app while a session is running returns to that session.
- Ending a session asks for confirmation, and `+15 min` is available on screen.
- Shared choice, slider and settings-section components replace duplicated UI.
- The session stage uses a dynamic dark tonal surface instead of pure black.
- Sleep timer accepts an exact custom duration in addition to presets.
- Voice volume is adjustable in Settings and the live sound sheet.
- OLED mode leaves only a centred word and a dimmed, outlined pause button;
  tap to pause, double tap toggles the controls.
- Double tap in the full session also enters OLED mode.
- System status and navigation bars stay hidden in every screen.
- The session backdrop breathes slowly and respects reduced-motion settings.
- The pause button uses an explicit foreground/background pair for contrast.
- The +15 minute action no longer renders a doubled plus sign.
- Home uses a small info icon for the five-step guide instead of a text button.
- New monochrome sine/cosine app icon for Android and fastlane.

## 1.0.0

- First release.
- English and Spanish cue pools generated from open lexical resources.
- System text-to-speech, independently selectable from the interface language.
- Procedural pink/brown noise with a warmth macro and live mixing.
- Screen-off playback through a foreground media service.
- Sleep timer, fade out, media notification and +15 minute action.
- Material 3 expressive interface with optional wallpaper colour.
- No network permission in release builds.
