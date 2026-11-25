## Package review

- `shared_preferences` is published by verified publisher `flutter.dev`, last released version 2.5.6 in October 2026, supports Android, iOS, Linux, macOS, Web and Windows, scores 160/160 pub points, has 16 open issues and a recent commit on November 11, 2026, depends on Flutter and its platform plugins, and uses the BSD-3-Clause license.
- `flutter_secure_storage` is published by verified publisher `steenbakker.dev`, released 11.2.0 in September 2026, supports Android, iOS, Linux, macOS, Web and Windows, scores 160/160, has 12 open issues and a November 1 commit, depends on Flutter, `meta` and platform plugins, and uses BSD-3-Clause.
- `path_provider` is published by verified publisher `flutter.dev`, released 2.1.6 in June 2026, supports Android, iOS, Linux, macOS and Windows, scores 160/160, has 22 open issues and a November 11 commit, depends on Flutter and platform plugins, and uses BSD-3-Clause.
- `image_picker` is published by verified publisher `flutter.dev`, released 1.2.4 in October 2026, supports Android, iOS, Linux, macOS, Web and Windows, scores 160/160, has 87 open issues and a November 11 commit, depends on Flutter and platform plugins, and uses Apache-2.0 and BSD-3-Clause licenses.
- `permission_handler` is published by verified publisher `baseflow.com`, released 13.0.2 in September 2026, supports Android, iOS, Web and Windows, scores 160/160, has 130 open issues and a November 6 commit, depends on Flutter, `meta` and platform plugins, and uses MIT.
- `url_launcher` is published by verified publisher `flutter.dev`, released 6.3.3 in October 2026, supports Android, iOS, Linux, macOS, Web and Windows, scores 160/160, has 34 open issues and a November 11 commit, depends on Flutter and platform plugins, and uses BSD-3-Clause.
## Dependency versions

- After adding the packages, `pubspec.lock` recorded `http` at version `1.6.0`.
- `^1.2.0` allows versions from `1.2.0` up to, but excluding, `2.0.0`. It rejects `1.1.9` and `2.0.0`.
- We commit `pubspec.lock` so everyone working on the app installs the same resolved dependency versions.
- Pinning `http` to `1.2.0` failed because it and `permission_handler` require incompatible versions of `web`. Restoring `http: ^1.6.0` allows dependency resolution again.
- `cupertino_icons` resolved to `1.0.9`. Version `2.0.0` is available, but it falls outside the current `1.x` constraint.

- The app uses `permission_handler 12.0.3` because version `13.0.2` requires Android SDK 37, while this project compiles against SDK 36.

## Secure token storage

- Ordinary preferences store values without encrypting them. Classic Android SharedPreferences uses XML, and iOS UserDefaults uses a plist. This app's SharedPreferencesAsync uses Preferences DataStore by default on Android. Depending on the device and configuration, backups, root access, or USB debugging on a debug build can expose preference data.
- iOS Keychain entries can survive app uninstall and reinstall. On Android, Keystore keys that require user authentication can become invalid if the secure screen lock is removed.

## Camera and photo permissions

- On iOS, one denial of camera access results in `permanentlyDenied`. The user can change the permission in Settings.
- The iOS Photos status `limited` means the app can access only the photos and videos the user selected.
