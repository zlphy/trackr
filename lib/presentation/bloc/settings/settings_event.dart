part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

class SaveApiKey extends SettingsEvent {
  final String apiKey;

  const SaveApiKey(this.apiKey);

  @override
  List<Object> get props => [apiKey];
}
