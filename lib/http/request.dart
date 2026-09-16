import 'dart:convert';
import 'dart:io';

class Request {
  final HttpRequest raw;
  final Map<String, String> params;
  late final Map<String, String> query;
  dynamic body;

  Request(this.raw, {this.params = const {}}) {
    query = raw.uri.queryParameters;
  }

  String get method => raw.method;
  String get path => raw.uri.path;
  String get url => raw.uri.toString();

  String? header(String name) => raw.headers.value(name);

  Future<String> text() async {
    return await utf8.decoder.bind(raw).join();
  }

  Future<dynamic> json() async {
    final content = await text();

    if (content.isEmpty) return null;

    return jsonDecode(content);
  }
}
