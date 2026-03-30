import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_provider.dart';

const _noPreferenceChange = Object();

class PreferencesState {
  final ThemeMode themeMode;
  final String nickname;
  final int avatarIndex;
  final String? avatarImageData;
  final String? profileBackgroundImageData;
  final bool isLoaded;

  const PreferencesState({
    this.themeMode = ThemeMode.dark,
    this.nickname = '',
    this.avatarIndex = 0,
    this.avatarImageData,
    this.profileBackgroundImageData,
    this.isLoaded = false,
  });

  PreferencesState copyWith({
    ThemeMode? themeMode,
    String? nickname,
    int? avatarIndex,
    Object? avatarImageData = _noPreferenceChange,
    Object? profileBackgroundImageData = _noPreferenceChange,
    bool? isLoaded,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      nickname: nickname ?? this.nickname,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarImageData: avatarImageData == _noPreferenceChange
          ? this.avatarImageData
          : avatarImageData as String?,
      profileBackgroundImageData:
          profileBackgroundImageData == _noPreferenceChange
          ? this.profileBackgroundImageData
          : profileBackgroundImageData as String?,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier(this._ref) : super(const PreferencesState()) {
    _load();
  }

  final Ref _ref;
  static const _storage = FlutterSecureStorage();
  static const _themeModeKey = 'pref_theme_mode';
  static const _nicknameKey = 'pref_nickname';
  static const _avatarIndexKey = 'pref_avatar_index';
  static const _avatarImageKey = 'pref_avatar_image';
  static const _profileBackgroundImageKey = 'pref_profile_background_image';
  static const _legacyUserPrefsMigratedKey = 'pref_user_scoped_migrated';

  Future<void> _load() async {
    await _loadForUser(_ref.read(authProvider).user?.id);
  }

  Future<void> handleAuthChanged(AuthState? previous, AuthState next) async {
    final previousUserId = previous?.user?.id;
    final nextUserId = next.user?.id;
    final signedOut =
        previous?.status != AuthStatus.unauthenticated &&
        next.status == AuthStatus.unauthenticated;

    if (!signedOut && previousUserId == nextUserId) return;

    await _loadForUser(nextUserId);
  }

  Future<void> _loadForUser(String? userId) async {
    state = const PreferencesState(isLoaded: false);

    if (userId == null || userId.isEmpty) {
      state = const PreferencesState(isLoaded: true);
      return;
    }

    await _migrateLegacyPreferencesIfNeeded(userId);

    final themeModeValue = await _storage.read(key: _scopedKey(userId, _themeModeKey));
    final nicknameValue = await _storage.read(key: _scopedKey(userId, _nicknameKey));
    final avatarValue = await _storage.read(key: _scopedKey(userId, _avatarIndexKey));
    final avatarImageValue = await _storage.read(
      key: _scopedKey(userId, _avatarImageKey),
    );
    final profileBackgroundImageValue = await _storage.read(
      key: _scopedKey(userId, _profileBackgroundImageKey),
    );

    state = PreferencesState(
      themeMode: _decodeThemeMode(themeModeValue),
      nickname: nicknameValue ?? '',
      avatarIndex: int.tryParse(avatarValue ?? '') ?? 0,
      avatarImageData: avatarImageValue,
      profileBackgroundImageData: profileBackgroundImageValue,
      isLoaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _writeScopedValue(_themeModeKey, _encodeThemeMode(themeMode));
  }

  Future<void> setNickname(String nickname) async {
    final trimmed = nickname.trim();
    state = state.copyWith(nickname: trimmed);
    await _writeScopedValue(_nicknameKey, trimmed);
  }

  Future<void> setAvatarIndex(int avatarIndex) async {
    state = state.copyWith(avatarIndex: avatarIndex, avatarImageData: null);
    await _writeScopedValue(_avatarIndexKey, '$avatarIndex');
    await _deleteScopedValue(_avatarImageKey);
  }

  Future<void> setAvatarImageData(String avatarImageData) async {
    state = state.copyWith(avatarImageData: avatarImageData);
    await _writeScopedValue(_avatarImageKey, avatarImageData);
  }

  Future<void> clearAvatarImageData() async {
    state = state.copyWith(avatarImageData: null);
    await _deleteScopedValue(_avatarImageKey);
  }

  Future<void> setProfileBackgroundImageData(
    String profileBackgroundImageData,
  ) async {
    state = state.copyWith(
      profileBackgroundImageData: profileBackgroundImageData,
    );
    await _writeScopedValue(
      _profileBackgroundImageKey,
      profileBackgroundImageData,
    );
  }

  Future<void> clearProfileBackgroundImageData() async {
    state = state.copyWith(profileBackgroundImageData: null);
    await _deleteScopedValue(_profileBackgroundImageKey);
  }

  String _scopedKey(String userId, String key) => '${key}_$userId';

  String? _currentUserId() => _ref.read(authProvider).user?.id;

  Future<void> _writeScopedValue(String key, String value) async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) return;
    await _storage.write(key: _scopedKey(userId, key), value: value);
  }

  Future<void> _deleteScopedValue(String key) async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) return;
    await _storage.delete(key: _scopedKey(userId, key));
  }

  Future<void> _migrateLegacyPreferencesIfNeeded(String userId) async {
    final migrated = await _storage.read(key: _legacyUserPrefsMigratedKey);
    if (migrated == 'true') return;

    final existingScopedValues = await Future.wait([
      _storage.read(key: _scopedKey(userId, _themeModeKey)),
      _storage.read(key: _scopedKey(userId, _nicknameKey)),
      _storage.read(key: _scopedKey(userId, _avatarIndexKey)),
      _storage.read(key: _scopedKey(userId, _avatarImageKey)),
      _storage.read(key: _scopedKey(userId, _profileBackgroundImageKey)),
    ]);
    final hasScopedPrefs = existingScopedValues.any(
      (value) => value != null && value.isNotEmpty,
    );
    if (hasScopedPrefs) {
      await _storage.write(key: _legacyUserPrefsMigratedKey, value: 'true');
      return;
    }

    final themeModeValue = await _storage.read(key: _themeModeKey);
    final nicknameValue = await _storage.read(key: _nicknameKey);
    final avatarValue = await _storage.read(key: _avatarIndexKey);
    final avatarImageValue = await _storage.read(key: _avatarImageKey);
    final profileBackgroundImageValue = await _storage.read(
      key: _profileBackgroundImageKey,
    );

    final hasLegacyUserPrefs =
        (themeModeValue?.isNotEmpty ?? false) ||
        (nicknameValue?.isNotEmpty ?? false) ||
        (avatarValue?.isNotEmpty ?? false) ||
        (avatarImageValue?.isNotEmpty ?? false) ||
        (profileBackgroundImageValue?.isNotEmpty ?? false);

    if (!hasLegacyUserPrefs) {
      await _storage.write(key: _legacyUserPrefsMigratedKey, value: 'true');
      return;
    }

    if (themeModeValue != null && themeModeValue.isNotEmpty) {
      await _storage.write(
        key: _scopedKey(userId, _themeModeKey),
        value: themeModeValue,
      );
    }
    await _storage.write(
      key: _scopedKey(userId, _nicknameKey),
      value: nicknameValue ?? '',
    );
    await _storage.write(
      key: _scopedKey(userId, _avatarIndexKey),
      value: avatarValue ?? '0',
    );
    if (avatarImageValue != null && avatarImageValue.isNotEmpty) {
      await _storage.write(
        key: _scopedKey(userId, _avatarImageKey),
        value: avatarImageValue,
      );
    }
    if (profileBackgroundImageValue != null &&
        profileBackgroundImageValue.isNotEmpty) {
      await _storage.write(
        key: _scopedKey(userId, _profileBackgroundImageKey),
        value: profileBackgroundImageValue,
      );
    }

    await _storage.delete(key: _themeModeKey);
    await _storage.delete(key: _nicknameKey);
    await _storage.delete(key: _avatarIndexKey);
    await _storage.delete(key: _avatarImageKey);
    await _storage.delete(key: _profileBackgroundImageKey);
    await _storage.write(key: _legacyUserPrefsMigratedKey, value: 'true');
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
      final notifier = PreferencesNotifier(ref);
      ref.listen<AuthState>(authProvider, (previous, next) {
        notifier.handleAuthChanged(previous, next);
      });
      return notifier;
    });
