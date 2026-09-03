/// The only thing the router needs to know about authentication.
///
/// Four states, not three. [unknown] exists because a cold launch cannot answer
/// the question synchronously: #6 has to read the Keychain and exchange a
/// refresh token before it knows whether there is a session. Without an
/// explicit "not yet known" the router would treat launch as signed-out and
/// flash the Sign In screen at every returning user.
///
/// [needsProfileSetup] is what "registration" amounts to in this product. There
/// is no separate sign-up: the first Sign in with Apple creates the account,
/// and the user is authenticated but has no username or icon yet.
enum AuthStatus {
  /// Bootstrapping. Show the splash; decide nothing.
  unknown,

  /// No valid session. Only the Sign In screen is reachable.
  signedOut,

  /// Authenticated, but the account has no username/icon. Only Profile Setup
  /// is reachable -- an account in this state cannot use the app.
  needsProfileSetup,

  /// Authenticated with a complete profile. Everything is reachable.
  signedIn,
}
