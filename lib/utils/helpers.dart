class AppHelpers {
  /// Format ISO Date string into Indonesian date text (e.g., "29 Agustus 2026")
  static String formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoString;
    }
  }

  /// Format ISO Date string into date + time (e.g. "29 Agt 2026, 14.30")
  static String formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final m = mPad(dt.minute);
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour}.$m';
    } catch (_) {
      return isoString;
    }
  }

  static String mPad(int n) => n.toString().padLeft(2, '0');
}
