import 'package:flutter/widgets.dart';

class AntiCheatService extends WidgetsBindingObserver {
  static const int maxViolations = 5;

  final Function(int count) onViolation;
  final VoidCallback onMaxViolationExceeded;

  int _currentCount = 0;
  DateTime? _lastViolationTime;
  bool _isListening = false;

  AntiCheatService({
    required this.onViolation,
    required this.onMaxViolationExceeded,
    int initialCount = 0,
  }) {
    _currentCount = initialCount;
  }

  int get currentCount => _currentCount;

  void startListening() {
    if (!_isListening) {
      _isListening = true;
      WidgetsBinding.instance.addObserver(this);
    }
  }

  void stopListening() {
    if (_isListening) {
      _isListening = false;
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isListening) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final now = DateTime.now();
      // Debounce threshold (2 seconds) to avoid duplicate counts during rapid transitions
      if (_lastViolationTime != null &&
          now.difference(_lastViolationTime!).inSeconds < 2) {
        return;
      }

      _lastViolationTime = now;
      _currentCount++;

      if (_currentCount > maxViolations) {
        onMaxViolationExceeded();
      } else {
        onViolation(_currentCount);
      }
    }
  }
}
