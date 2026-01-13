import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tech_task/core/constants/api_constants.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/data/models/comment_model.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PostRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = PostRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getPosts', () {
    const tPostsJson = [
      {
        'id': 1,
        'userId': 1,
        'title': 'Test Title 1',
        'body': 'Test Body 1',
      },
      {
        'id': 2,
        'userId': 2,
        'title': 'Test Title 2',
        'body': 'Test Body 2',
      },
    ];

    test(
        'should return list of PostModels when the call to remote API is successful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(tPostsJson), 200));

      // Act
      final result = await dataSource.getPosts();

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getPostsUrl()),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test(
        'should throw ServerFailure when the call to remote API is unsuccessful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      // Act
      final call = dataSource.getPosts;

      // Assert
      expect(() => call(), throwsA(isA<ServerFailure>()));
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getPostsUrl()),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should throw NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('No Internet'));

      // Act
      final call = dataSource.getPosts;

      // Assert
      expect(() => call(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('getPostById', () {
    const tPostJson = {
      'id': 1,
      'userId': 1,
      'title': 'Test Title',
      'body': 'Test Body',
    };
    const tId = 1;

    test('should return PostModel when the call to remote API is successful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(tPostJson), 200));

      // Act
      final result = await dataSource.getPostById(tId);

      // Assert
      expect(result, isA<PostModel>());
      expect(result.id, tId);
      expect(result.title, 'Test Title');
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getPostByIdUrl(tId)),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test(
        'should throw ServerFailure when the call to remote API is unsuccessful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      Future<PostModel> call() => dataSource.getPostById(tId);
      expect(call, throwsA(isA<ServerFailure>()));
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getPostByIdUrl(tId)),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should throw NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('No Internet'));

      // Act & Assert
      Future<PostModel> call() => dataSource.getPostById(tId);
      expect(call, throwsA(isA<NetworkFailure>()));
    });
  });

  group('getCommentsByPostId', () {
    const tCommentsJson = [
      {
        'id': 1,
        'postId': 1,
        'name': 'Test Name 1',
        'email': 'test1@example.com',
        'body': 'Test Body 1',
      },
      {
        'id': 2,
        'postId': 1,
        'name': 'Test Name 2',
        'email': 'test2@example.com',
        'body': 'Test Body 2',
      },
    ];
    const tPostId = 1;

    test(
        'should return list of CommentModels when the call to remote API is successful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(tCommentsJson), 200));

      // Act
      final result = await dataSource.getCommentsByPostId(tPostId);

      // Assert
      expect(result, isA<List<CommentModel>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getCommentsByPostIdUrl(tPostId)),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test(
        'should throw ServerFailure when the call to remote API is unsuccessful',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      Future<List<CommentModel>> call() =>
          dataSource.getCommentsByPostId(tPostId);
      expect(call, throwsA(isA<ServerFailure>()));
      verify(() => mockHttpClient.get(
            Uri.parse(ApiConstants.getCommentsByPostIdUrl(tPostId)),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should throw NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('No Internet'));

      // Act & Assert
      Future<List<CommentModel>> call() =>
          dataSource.getCommentsByPostId(tPostId);
      expect(call, throwsA(isA<NetworkFailure>()));
    });
  });
}
