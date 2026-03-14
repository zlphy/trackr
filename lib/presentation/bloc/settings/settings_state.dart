part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String apiKey;

  const SettingsState({
    required this.themeMode,
    required this.apiKey,
  });

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.dark,
        apiKey: '',
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? apiKey,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object> get props => [themeMode, apiKey];
}
