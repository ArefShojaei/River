import 'dart:convert';
import 'dart:io';

class Response {
  final HttpResponse _raw;
  bool _ended = false;

  Response(this._raw);

  bool get ended => _ended;

  Response status(int code) {
    _raw.statusCode = code;

    return this;
  }

  Response setHeader(String name, String value) {
    _raw.headers.set(name, value);

    return this;
  }

  void json(Object? data, {int? statusCode}) {
    if (_ended) return;

    if (statusCode != null) {
      _raw.statusCode = statusCode;
    }

    _raw.headers.contentType = ContentType.json;

    _raw.write(jsonEncode(data));

    end();
  }

  void send(Object? data, {int? statusCode}) {
    if (_ended) return;

    if (statusCode != null) {
      _raw.statusCode = statusCode;
    }

    if (data is String) {
      _raw.headers.contentType ??= ContentType.text;
      _raw.write(data);
    } else {
      _raw.headers.contentType = ContentType.json;
      _raw.write(jsonEncode(data));
    }

    end();
  }

  void end([String? data]) {
    if (_ended) return;

    if (data != null) {
      _raw.write(data);
    }

    _raw.close();

    _ended = true;
  }
}
