import 'dart:async';

/// Utility class for debouncing rapid function calls
/// Useful for delaying API calls until user stops typing
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Runs the action after the delay period
  /// Cancels previous timer if called again before delay expires
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer
  void dispose() {
    _timer?.cancel();
  }
}
