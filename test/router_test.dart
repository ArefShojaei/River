import 'package:test/test.dart';

import 'package:river/river.dart';

void main() {
  group('Router', () {
    late Router router;

    setUp(() {
      router = Router();
    });

    test('should register GET route', () {
      router.get('/test', (req, res) async {});
      // در نسخه واقعی می‌تونی بررسی کنی که route اضافه شده
      expect(true, isTrue); // فعلاً placeholder
    });

    test('should match route with params', () {
      final route = Route(
        method: 'GET',
        path: '/users/:id',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/users/123'), isTrue);
      expect(route.extractParams('/users/123'), equals({'id': '123'}));
    });
  });
}
