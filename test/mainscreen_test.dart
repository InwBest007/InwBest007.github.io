import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp_recipe/Screen/mainscreen.dart';

// Mock Client ลองทดสอบโดยไม่ได้ใช้ api จริง
class MockClient extends http.BaseClient {
  final http.Client _inner;
  MockClient(this._inner);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.toString().contains('spoonacular.com/recipes/random')) {
      // mock response เมื่อเรียกใช้ API
      final response = http.Response(
        jsonEncode({
          "recipes": [
            {
              "id": 1,
              "title": "Mock Recipe",
              "image": "test"
            }
          ]
        }),
        200,
      );
      return http.StreamedResponse(
          Stream.fromIterable([response.bodyBytes]), 200);
    }
    return http.StreamedResponse(
        Stream.fromIterable([]), 404); // ไม่เจอ resource
  }
}
void main() {
  group('fetchRecipes', () {
    test('returns a list of recipes if the http call completes successfully', () async {
      final client = MockClient(http.Client());

      // ทดสอบ fetchRecipes ด้วย category 'recommended'
      final recipes = await fetchRecipes('recommended', client: client);
      expect(recipes, isA<List<Map<String, dynamic>>>());
      // มี item ในรายการไหม
      expect(recipes.length, greaterThan(0));
      // ตรวจสอบค่าที่ได้
      expect(recipes[0]['title'], 'Mock Recipe');
    });
    test('throws an exception if the http call completes with an error', () async {
      final client = MockClient(http.Client());
      // กรณีเรียกฟังก์ชันด้วย category ที่ไม่รู้จัก
      expect(() async => await fetchRecipes('unknown_category', client: client),
          throwsA(isA<Exception>()));
    });
  });
}

