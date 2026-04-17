import 'package:intl/intl.dart';

/// 金额一律用「分」存储，避免浮点误差（见 OpenSpec design）。
int yuanToCents(int yuan) => yuan * 100;

int? tryParseYuanToCents(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final normalized = trimmed.replaceAll(',', '');
  final value = double.tryParse(normalized);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

String formatCentsToYuan(int cents) {
  final fmt = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );
  return fmt.format(cents / 100.0);
}
