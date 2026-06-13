class Constants {
  // RAWG API key support via --dart-define. Example:
  // flutter run --dart-define=RAWG_API_KEY=your_key_here
  // If not provided, the placeholder will disable RAWG calls.
  static const rawgApiKey = String.fromEnvironment('RAWG_API_KEY', defaultValue: '<RAWG_API_KEY_PLACEHOLDER>');
}
