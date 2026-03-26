import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesState {
  final ThemeMode themeMode;
  final String nickname;
  final int avatarIndex;
  final bool isLoaded;

  const PreferencesState({
    this.themeMode = ThemeMode.dark,
    this.nickname = '',
    this.avatarIndex = 0,
    this.isLoaded = false,
  });

  PreferencesState copyWith({
    ThemeMode? themeMode,
    String? nickname,
    int? avatarIndex,
    bool? isLoaded,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      nickname: nickname ?? this.nickname,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState()) {
    _load();
  }

  static const _storage = FlutterSecureStorage();
  static const _themeModeKey = 'pref_theme_mode';
  static const _nicknameKey = 'pref_nickname';
  static const _avatarIndexKey = 'pref_avatar_index';

  Future<void> _load() async {
    final themeModeValue = await _storage.read(key: _themeModeKey);
    final nicknameValue = await _storage.read(key: _nicknameKey);
    final avatarValue = await _storage.read(key: _avatarIndexKey);

    state = state.copyWith(
      themeMode: _decodeThemeMode(themeModeValue),
      nickname: nicknameValue ?? '',
      avatarIndex: int.tryParse(avatarValue ?? '') ?? 0,
      isLoaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _storage.write(
      key: _themeModeKey,
      value: _encodeThemeMode(themeMode),
    );
  }

  Future<void> setNickname(String nickname) async {
    final trimmed = nickname.trim();
    state = state.copyWith(nickname: trimmed);
    await _storage.write(key: _nicknameKey, value: trimmed);
  }

  Future<void> setAvatarIndex(int avatarIndex) async {
    state = state.copyWith(avatarIndex: avatarIndex);
    await _storage.write(key: _avatarIndexKey, value: '$avatarIndex');
  }

  String _encodeThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _decodeThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
      return PreferencesNotifier();
    });
