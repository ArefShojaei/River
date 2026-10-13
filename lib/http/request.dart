import 'dart:convert';
import 'dart:io';

class Request {
  final HttpRequest raw;
  final Map<String, String> params;
  late final Map<String, String> query;
  dynamic body;

  String? _cachedText;
  bool _bodyRead = false;

  Request(this.raw, {this.params = const {}}) {
    query = raw.uri.queryParameters;
  }

  String get method => raw.method;
  String get path => raw.uri.path;
  String get url => raw.uri.toString();

  String? header(String name) => raw.headers.value(name);

  Future<String> text() async {
    if (_cachedText != null) return _cachedText!;

    if (_bodyRead) return '';

    _bodyRead = true;
    _cachedText = await utf8.decoder.bind(raw).join();
    return _cachedText!;
  }

  Future<dynamic> json() async {
    final content = await text();

    if (content.isEmpty) return null;

    try {
      return jsonDecode(content);
    } catch (e) {
      throw FormatException('Invalid JSON body: $e');
    }
  }
}
