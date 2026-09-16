import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('Route', () {
    test('matches exact path and method', () {
      final route = Route(
        method: 'GET',
        path: '/hello',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/hello'), isTrue);
      expect(route.match('POST', '/hello'), isFalse);
      expect(route.match('GET', '/hello/'), isFalse);
      expect(route.match('GET', '/other'), isFalse);
    });

    test('matches case-insensitive method', () {
      final route = Route(
        method: 'get',
        path: '/test',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/test'), isTrue);
      expect(route.match('get', '/test'), isTrue);
      expect(route.match('Get', '/test'), isTrue);
    });

    test('matches wildcard method (*)', () {
      final route = Route(
        method: '*',
        path: '/any',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/any'), isTrue);
      expect(route.match('POST', '/any'), isTrue);
      expect(route.match('DELETE', '/any'), isTrue);
      expect(route.match('PATCH', '/any'), isTrue);
    });

    test('matches path with single param', () {
      final route = Route(
        method: 'GET',
        path: '/users/:id',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/users/123'), isTrue);
      expect(route.match('GET', '/users/abc'), isTrue);
      expect(route.match('GET', '/users/'), isFalse);
      expect(route.match('GET', '/users/123/extra'), isFalse);
      expect(route.match('GET', '/users'), isFalse);
    });

    test('extracts single param correctly', () {
      final route = Route(
        method: 'GET',
        path: '/users/:id',
        handler: (req, res) async {},
      );

      expect(route.extractParams('/users/123'), equals({'id': '123'}));
      expect(route.extractParams('/users/abc-xyz'), equals({'id': 'abc-xyz'}));
    });

    test('matches and extracts multiple params', () {
      final route = Route(
        method: 'GET',
        path: '/posts/:postId/comments/:commentId',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/posts/10/comments/5'), isTrue);
      expect(
        route.extractParams('/posts/10/comments/5'),
        equals({'postId': '10', 'commentId': '5'}),
      );
    });

    test('returns empty map when no match for extractParams', () {
      final route = Route(
        method: 'GET',
        path: '/users/:id',
        handler: (req, res) async {},
      );

      expect(route.extractParams('/other'), isEmpty);
    });

    test('does not match different method even with correct path', () {
      final route = Route(
        method: 'POST',
        path: '/users/:id',
        handler: (req, res) async {},
      );

      expect(route.match('GET', '/users/1'), isFalse);
      expect(route.match('PUT', '/users/1'), isFalse);
    });
  });

  group('Router', () {
    late Router router;

    setUp(() {
      router = Router();
    });

    test('registers all HTTP methods without error', () {
      router.get('/g', (req, res) async {});
      router.post('/p', (req, res) async {});
      router.put('/u', (req, res) async {});
      router.patch('/pa', (req, res) async {});
      router.delete('/d', (req, res) async {});
      router.all('/a', (req, res) async {});
      expect(true, isTrue);
    });
  });
}
