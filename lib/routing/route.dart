class Route {
  final String method;
  final String path;
  final Function handler;

  late final RegExp _regex;
  late final List<String> _paramNames;

  Route({required this.method, required this.path, required this.handler}) {
    _compile();
  }

  void _compile() {
    final paramNames = <String>[];
    final pattern = path.replaceAllMapped(RegExp(r':(\w+)'), (match) {
      paramNames.add(match.group(1)!);
      return r'([^/]+)';
    });

    _paramNames = paramNames;
    _regex = RegExp('^$pattern\$', caseSensitive: false);
  }

  bool match(String method, String path) {
    if (this.method != '*' &&
        this.method.toUpperCase() != method.toUpperCase()) {
      return false;
    }

    return _regex.hasMatch(path);
  }

  Map<String, String> extractParams(String path) {
    final match = _regex.firstMatch(path);

    if (match == null) return {};

    final params = <String, String>{};

    for (var i = 0; i < _paramNames.length; i++) {
      params[_paramNames[i]] = match.group(i + 1) ?? '';
    }
    return params;
  }
}
