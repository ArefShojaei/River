import 'dart:io';

class Console {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _magenta = '\x1B[35m';
  static const _cyan = '\x1B[36m';
  static const _bold = '\x1B[1m';

  static void log(Object? message) {
    stdout.writeln('$message');
  }

  static void info(Object? message) {
    stdout.writeln('$_cyan[INFO] $message$_reset');
  }

  static void success(Object? message) {
    stdout.writeln('$_green[SUCCESS] $message$_reset');
  }

  static void warn(Object? message) {
    stdout.writeln('$_yellow[WARN] $message$_reset');
  }

  static void error(Object? message) {
    stderr.writeln('$_red[ERROR] $message$_reset');
  }

  static void debug(Object? message) {
    stdout.writeln('$_magenta[DEBUG] $message$_reset');
  }

  static void title(String text) {
    stdout.writeln('\n$_bold$_blue$text$_reset\n');
  }
}
