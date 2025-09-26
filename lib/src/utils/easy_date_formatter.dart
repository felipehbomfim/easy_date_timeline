import 'package:intl/intl.dart' show DateFormat;

/// A utility class that provides easy access to commonly used date formatting functions in the `EasyDateTimeLine` widget.
abstract final class EasyDateFormatter {
  /// Returns the short name of the day of the given date in the specified locale.
  static String shortDayName(DateTime date, String locale) {
    String raw = DateFormat("E", locale).format(date);

    // Remove ponto no final (ex: "seg." → "seg")
    raw = raw.replaceAll('.', '');

    // Ajusta para primeira maiúscula, resto minúsculo
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  /// Returns the full name of the day of the given date in the specified locale.
  static String fullDayName(DateTime date, String locale) {
    return DateFormat("EEEE", locale).format(date);
  }

  /// Returns the short name of the month of the given date in the specified locale.
  static String shortMonthName(DateTime date, String locale) {
    String raw = DateFormat("MMM", locale).format(date);

    // Remove ponto no final (ex: "seg." → "seg")
    raw = raw.replaceAll('.', '');

    // Ajusta para primeira maiúscula, resto minúsculo
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  /// Returns a custom formatted string representing the given date in the specified locale.
  static String customFormat(String format, DateTime date, String locale) {
    return DateFormat(format, locale).format(date);
  }

  /// Returns the full name of the month of the given date in the specified locale.
  static String fullMonthName(DateTime date, String locale) {
    return DateFormat("MMMM", locale).format(date);
  }

  /// Returns the full date of the given date in the "dd/MM/yyyy" format and the specified locale.
  static String fullDateDMY(DateTime date, String locale) {
    return DateFormat("dd/MM/yyyy", locale).format(date);
  }
}
