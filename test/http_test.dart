import 'package:test/test.dart';

import 'package:river/river.dart';

void main() {
  group('Http', () {
    test('createServer should return Http instance', () async {
      final app = await Http.createServer(port: 0); // port 0 = random free port
      expect(app, isA<Http>());
    });
  });
}
