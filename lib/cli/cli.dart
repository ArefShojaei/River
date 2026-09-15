import 'dart:io';

import 'package:river/cli/command.dart';
import 'package:river/cli/console.dart';

class Cli {
  final String name;
  final String version;
  final List<Command> _commands = [];

  Cli({this.name = 'app', this.version = '1.0.0'});

  void command({
    required String name,
    required String description,
    required Function handler,
    List<String> aliases = const [],
  }) {
    _commands.add(
      Command(
        name: name,
        description: description,
        handler: handler,
        aliases: aliases,
      ),
    );
  }

  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      _welcome();

      return;
    }

    if (arguments.contains('--version') || arguments.contains('-v')) {
      Console.log('$name v$version');
      return;
    }

    final cmdName = arguments.first;
    final remaining = arguments.skip(1).toList();

    final command = _findCommand(cmdName);
    if (command == null) {
      Console.error('Unknown command: $cmdName');
      Console.log('Run "$name --help" for available commands.');
      exit(1);
    }

    final (args, flags) = _parseArgs(remaining);

    try {
      await command.handler(args, flags);
    } catch (e, stack) {
      Console.error('Command failed: $e');
      Console.debug(stack.toString());
      exit(1);
    }
  }

  Command? _findCommand(String name) {
    for (final cmd in _commands) {
      if (cmd.name == name || cmd.aliases.contains(name)) {
        return cmd;
      }
    }
    return null;
  }

  (List<String>, Map<String, String>) _parseArgs(List<String> input) {
    final args = <String>[];
    final flags = <String, String>{};

    for (var i = 0; i < input.length; i++) {
      final item = input[i];
      if (item.startsWith('--')) {
        final key = item.substring(2);
        if (i + 1 < input.length && !input[i + 1].startsWith('-')) {
          flags[key] = input[++i];
        } else {
          flags[key] = 'true';
        }
      } else if (item.startsWith('-') && item.length == 2) {
        final key = item.substring(1);
        if (i + 1 < input.length && !input[i + 1].startsWith('-')) {
          flags[key] = input[++i];
        } else {
          flags[key] = 'true';
        }
      } else {
        args.add(item);
      }
    }

    return (args, flags);
  }

  void _welcome() {
    Console.title('$name v$version');
    Console.log('Usage: $name <command> [arguments] [flags]\n');

    Console.log('Available commands:\n');
    for (final cmd in _commands) {
      final aliases =
          cmd.aliases.isNotEmpty ? ' (${cmd.aliases.join(', ')})' : '';
      Console.log('  ${cmd.name.padRight(15)}$aliases');
      Console.log('      ${cmd.description}\n');
    }

    Console.log('Flags:');
    Console.log('  -h, --help       Show help');
    Console.log('  -v, --version    Show version');
  }
}
