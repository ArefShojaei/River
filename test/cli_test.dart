import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('Cli', () {
    test('should create Cli instance with defaults', () {
      final cli = Cli();
      expect(cli.name, equals('app'));
      expect(cli.version, equals('1.0.0'));
    });

    test('should create Cli instance with custom name and version', () {
      final cli = Cli(name: 'myapp', version: '2.3.4');
      expect(cli.name, equals('myapp'));
      expect(cli.version, equals('2.3.4'));
    });

    test('registers command and runs handler', () async {
      final cli = Cli(name: 'testcli', version: '1.0.0');
      var called = false;
      List<String>? receivedArgs;
      Map<String, String>? receivedFlags;

      cli.command(
        name: 'greet',
        description: 'Say hello',
        handler: (List<String> args, Map<String, String> flags) async {
          called = true;
          receivedArgs = args;
          receivedFlags = flags;
        },
      );

      await cli.run(['greet', 'world', '--name', 'Aref', '--force']);

      expect(called, isTrue);
      expect(receivedArgs, equals(['world']));
      expect(receivedFlags, containsPair('name', 'Aref'));
      expect(receivedFlags!['force'], equals('true'));
    });

    test('runs command via alias', () async {
      final cli = Cli();
      var called = false;

      cli.command(
        name: 'serve',
        description: 'Start server',
        aliases: ['s', 'start'],
        handler: (args, flags) async {
          called = true;
        },
      );

      await cli.run(['s']);
      expect(called, isTrue);

      called = false;
      await cli.run(['start']);
      expect(called, isTrue);
    });

    test('parses flags with and without values', () async {
      final cli = Cli();
      Map<String, String>? flags;

      cli.command(
        name: 'run',
        description: 'Run something',
        handler: (args, f) async {
          flags = f;
        },
      );

      await cli.run([
        'run',
        '--port',
        '3000',
        '--verbose',
        '-h',
        'localhost',
        '--force',
      ]);

      expect(flags, isNotNull);
      expect(flags!['port'], equals('3000'));
      expect(flags!['verbose'], equals('true'));
      expect(flags!['h'], equals('localhost'));
      expect(flags!['force'], equals('true'));
    });

    test('parses positional args correctly', () async {
      final cli = Cli();
      List<String>? args;

      cli.command(
        name: 'echo',
        description: 'Echo args',
        handler: (a, f) async {
          args = a;
        },
      );

      await cli.run(['echo', 'one', 'two', 'three']);
      expect(args, equals(['one', 'two', 'three']));
    });

    test('--version does not run command', () async {
      final cli = Cli(name: 'mycli', version: '9.8.7');
      var commandCalled = false;

      cli.command(
        name: 'dummy',
        description: 'dummy',
        handler: (a, f) async {
          commandCalled = true;
        },
      );

      await cli.run(['--version']);
      expect(commandCalled, isFalse);

      await cli.run(['-v']);
      expect(commandCalled, isFalse);
    });

    test('empty arguments shows welcome (no throw)', () async {
      final cli = Cli(name: 'demo', version: '1.0.0');
      cli.command(
        name: 'help',
        description: 'Show help',
        handler: (a, f) async {},
      );

      await cli.run([]);
    });
  });

  group('Command', () {
    test('stores name, description, handler and aliases', () {
      final cmd = Command(
        name: 'build',
        description: 'Build the project',
        handler: (a, f) {},
        aliases: ['b'],
      );

      expect(cmd.name, equals('build'));
      expect(cmd.description, equals('Build the project'));
      expect(cmd.aliases, equals(['b']));
      expect(cmd.handler, isNotNull);
    });
  });

  group('Console', () {
    test('log, info, success, warn, error, debug, title do not throw', () {
      Console.log('plain message');
      Console.info('info message');
      Console.success('success message');
      Console.warn('warn message');
      Console.error('error message');
      Console.debug('debug message');
      Console.title('Title');
    });
  });
}
