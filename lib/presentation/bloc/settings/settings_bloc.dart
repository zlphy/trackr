import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  SettingsBloc(this._prefs) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<SaveApiKey>(_onSaveApiKey);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final isDark = _prefs.getBool(AppConstants.prefKeyThemeMode) ?? false;
    final apiKey = _prefs.getString(AppConstants.prefKeyApiKey) ?? '';
    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      apiKey: apiKey,
    ));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<SettingsState> emit) async {
    final isDark = state.themeMode == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setBool(AppConstants.prefKeyThemeMode, newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onSaveApiKey(
      SaveApiKey event, Emitter<SettingsState> emit) async {
    await _prefs.setString(AppConstants.prefKeyApiKey, event.apiKey);
    emit(state.copyWith(apiKey: event.apiKey));
  }
}
