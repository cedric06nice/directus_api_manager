import 'dart:typed_data';

import 'dart:convert';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:http/http.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class MockHTTPClient implements Client {
  final List<dynamic> _responses = [];

  dynamic _nextResponse() {
    if (_responses.isEmpty) {
      return Response("", 200);
    }
    return _responses.removeLast();
  }

  addStreamResponse({required String body, int statusCode = 200}) {
    _responses
        .add(StreamedResponse(Stream.value(utf8.encode(body)), statusCode));
  }

  @override
  void close() {}

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _nextResponse();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    return _nextResponse();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) async {
    return _nextResponse();
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _nextResponse();
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _nextResponse();
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _nextResponse();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    return _nextResponse();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    return _nextResponse();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return _nextResponse();
  }
}

main() {
  test('Empty manager does not have a logged in user', () async {
    final sut = DirectusApiManager(
        baseURL: "http://api.com", httpClient: MockHTTPClient());
    expect(await sut.hasLoggedInUser(), false);
  });

  test('Manager with logged in user', () async {
    final mockClient = MockHTTPClient();
    const successLoginResponse = """
    {"data":{"access_token":"ABCD.1234.ABCD","expires":900000,"refresh_token":"REFRESH.TOKEN.5678"}}
    """;
    mockClient.addStreamResponse(body: successLoginResponse);
    final sut =
        DirectusApiManager(baseURL: "http://api.com", httpClient: mockClient);
    await sut.loginDirectusUser("l", "p");
    expect(await sut.hasLoggedInUser(), true);
  });

  test('Empty manager with successfull refresh token load', () async {
    final mockClient = MockHTTPClient();
    final sut = DirectusApiManager(
      baseURL: "http://api.com",
      httpClient: mockClient,
      loadRefreshTokenCallback: () =>
          Future.delayed(Duration(milliseconds: 100), () => "SAVED.TOKEN"),
    );
    expect(await sut.hasLoggedInUser(), true);
  });

  test('Empty manager with NOT successfull refresh token load', () async {
    final mockClient = MockHTTPClient();
    final sut = DirectusApiManager(
      baseURL: "http://api.com",
      httpClient: mockClient,
      loadRefreshTokenCallback: () =>
          Future.delayed(Duration(milliseconds: 100), () => null),
    );
    expect(await sut.hasLoggedInUser(), false);
  });
}