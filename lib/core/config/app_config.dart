/// Compile-time environment configuration.
///
/// Values arrive via `--dart-define` so that no environment data is committed
/// and a build is pinned to exactly one backend. The defaults point at a local
/// Go server, which is what a developer running the API on their machine gets
/// for free.
///
/// ```sh
/// flutter run \
///   --dart-define=API_BASE_URL=https://mate-api.fly.dev \
///   --dart-define=WS_BASE_URL=wss://mate-api.fly.dev
/// ```
///
/// `String.fromEnvironment` only reads a define when it is evaluated in a const
/// context, hence the `static const` fields below. Reading them any other way
/// silently yields the default in release builds.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.wsBaseUrl});

  /// Reads the ambient `--dart-define` values, falling back to local dev.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: Uri.parse(_apiBaseUrl),
      wsBaseUrl: Uri.parse(_wsBaseUrl),
    );
  }

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String _wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8080',
  );

  /// Base URL of the Go HTTP API, without a trailing slash.
  final Uri apiBaseUrl;

  /// Base URL used for the game WebSocket. Separate from [apiBaseUrl] because
  /// the scheme differs (`ws`/`wss`) and the two may diverge behind a proxy.
  final Uri wsBaseUrl;

  /// True when pointed at a local backend, which lets debug affordances key off
  /// the target rather than off the build mode.
  bool get isLocal =>
      apiBaseUrl.host == 'localhost' || apiBaseUrl.host == '127.0.0.1';

  @override
  String toString() => 'AppConfig(api: $apiBaseUrl, ws: $wsBaseUrl)';
}
