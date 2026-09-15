class Command {
  final String name;
  final String description;
  final Function handler;
  final List<String> aliases;

  Command({
    required this.name,
    required this.description,
    required this.handler,
    this.aliases = const [],
  });
}
