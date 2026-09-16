import 'package:river/types.dart';

class Command {
  final String name;
  final String description;
  final CliHandler handler;
  final List<String> aliases;

  Command({
    required this.name,
    required this.description,
    required this.handler,
    this.aliases = const [],
  });
}
