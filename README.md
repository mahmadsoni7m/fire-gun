# SONI: OPEN WORLD — Godot 4 Android prototype

A small, asset-free third-person shooter prototype. It generates the world procedurally, so the project does not need external models or textures.

## Included
- Third-person player and follow camera
- Keyboard controls for desktop testing
- Android touch joystick, look-drag, fire, and jump controls
- Procedural village, trees, ground, and six chasing enemies
- Hitscan shooting and enemy health
- GitHub Actions workflow to export an Android APK

## Controls
- Keyboard: WASD / arrow keys to move, Space to jump, left mouse button to fire.
- Mouse: hold right mouse button and move to look around.
- Android: left side joystick to move, drag on right side to look, FIRE to shoot, JUMP to jump.

## Build APK on GitHub (phone-only workflow)
1. Create a new GitHub repository.
2. Upload all files from this folder, including `.github/workflows/build-android.yml`.
3. Commit to the `main` branch.
4. Open the repository's **Actions** tab.
5. Select **Build Godot Android APK** and open the latest run.
6. When it finishes, download the `SONI-Open-World-APK` artifact and extract the ZIP to get the APK.

The workflow depends on the Android export templates and SDK packaged in the selected Godot CI image. If the image version changes or export reports a missing Android template/SDK, check the workflow log and adjust the image version to a compatible Godot 4 CI image.

## Important prototype notes
- This is a first playable prototype, not a finished commercial game.
- Enemy AI is intentionally simple and does not yet include ranged attacks, animations, sound, save data, or missions.
- The Android APK export must be verified in GitHub Actions. APK signing is not configured; use a proper release keystore before publishing to a store.
- Uses Godot 4 with the Compatibility renderer for wider mobile support.
