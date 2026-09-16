class CliException implements Exception {
  final String message;
  final int exitCode;

  const CliException(this.message, {this.exitCode = 1});

  @override
  String toString() => message;
}

class UnknownCommandException extends CliException {
  UnknownCommandException(String command)
      : super('Unknown command: $command', exitCode: 1);
}

class InvalidArgumentException extends CliException {
  const InvalidArgumentException(super.message) : super(exitCode: 1);
}

class MissingFlagException extends CliException {
  MissingFlagException(String flag)
      : super('Missing required flag: --$flag', exitCode: 1);
}
