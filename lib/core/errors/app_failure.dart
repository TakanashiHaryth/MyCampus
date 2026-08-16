class AppFailure implements Exception {
  const AppFailure(this.message, {this.code = 'unknown'});

  final String code;
  final String message;

  @override
  String toString() => 'AppFailure($code)';
}
