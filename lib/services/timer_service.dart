class TimerService {
  /// Calculate remaining seconds based on absolute end DateTime
  static int getRemainingSeconds(DateTime endDateTime) {
    final now = DateTime.now();
    final difference = endDateTime.difference(now).inSeconds;
    return difference > 0 ? difference : 0;
  }

  /// Calculate elapsed seconds based on start DateTime
  static int getElapsedSeconds(DateTime startDateTime) {
    final now = DateTime.now();
    final difference = now.difference(startDateTime).inSeconds;
    return difference > 0 ? difference : 0;
  }

  /// Warning levels for timer display
  static String? getWarningLevel(int remainingSeconds) {
    if (remainingSeconds <= 60) return 'critical'; // 1 minute
    if (remainingSeconds <= 300) return 'warning'; // 5 minutes
    if (remainingSeconds <= 600) return 'notice'; // 10 minutes
    return null;
  }
}
