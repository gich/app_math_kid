import 'package:shared_preferences/shared_preferences.dart';

class PlayerStorage {
  static const _currentKey = 'player_current';
  static const _knownKey = 'player_known';
  static const defaultName = 'unknown';
  static const _maxKnown = 10;
  static const maxNameLength = 20;

  Future<String> getCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentKey) ?? defaultName;
  }

  Future<List<String>> getKnown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_knownKey) ?? const [];
  }

  /// Saves [name] as the current player. Empty / whitespace-only names reset
  /// to the default. Non-empty names are also added to the "known names" list.
  Future<void> setCurrent(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      await prefs.remove(_currentKey);
      return;
    }

    final clipped = trimmed.length > maxNameLength
        ? trimmed.substring(0, maxNameLength)
        : trimmed;

    await prefs.setString(_currentKey, clipped);

    final known = List<String>.from(prefs.getStringList(_knownKey) ?? const []);
    known.remove(clipped); // dedupe
    known.insert(0, clipped); // newest first
    if (known.length > _maxKnown) {
      known.removeRange(_maxKnown, known.length);
    }
    await prefs.setStringList(_knownKey, known);
  }
}
