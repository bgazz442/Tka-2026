import 'package:flutter/material.dart';
import '../services/scoring_service.dart';
import '../services/timer_service.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final warningLevel = TimerService.getWarningLevel(remainingSeconds);

    Color textColor = const Color(0xFF1E293B);
    Color bgColor = const Color(0xFFF8FAFC);
    Color borderColor = const Color(0xFFE2E8F0);
    IconData iconData = Icons.timer_outlined;

    if (warningLevel == 'critical') {
      textColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFFF1F2);
      borderColor = const Color(0xFFFECDD3);
      iconData = Icons.alarm_on_rounded;
    } else if (warningLevel == 'warning') {
      textColor = const Color(0xFFEA580C);
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFFEDD5);
    } else if (warningLevel == 'notice') {
      textColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            ScoringService.formatClock(remainingSeconds),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
