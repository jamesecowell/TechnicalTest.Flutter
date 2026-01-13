import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/data/models/comment_model.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';
import 'package:flutter_tech_task/data/repositories/post_repository_impl.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostRemoteDataSource();
    repository = PostRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getPosts', () {
    final tPostModels = [
      const PostModel(
        id: 1,
        userId: 1,
        title: 'Test Title 1',
        body: 'Test Body 1',
      ),
      const PostModel(
        id: 2,
        userId: 2,
        title: 'Test Title 2',
        body: 'Test Body 2',
      ),
    ];

    test('should return remote data when the call to remote data source is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getPosts())
          .thenAnswer((_) async => tPostModels);

      // Act
      final result = await repository.getPosts();

      // Assert
      verify(() => mockRemoteDataSource.getPosts()).called(1);
      expect(result, isA<Right<Failure, List<Post>>>());
      final posts = result.fold((l) => <Post>[], (r) => r);
      expect(posts.length, 2);
      expect(posts[0].id, 1);
      expect(posts[1].id, 2);
    });

    test('should return ServerFailure when the call to remote data source is unsuccessful', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockRemoteDataSource.getPosts())
          .thenThrow(failure);

      // Act
      final result = await repository.getPosts();

      // Assert
      verify(() => mockRemoteDataSource.getPosts()).called(1);
      expect(result, isA<Left<Failure, List<Post>>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      when(() => mockRemoteDataSource.getPosts())
          .thenThrow(failure);

      // Act
      final result = await repository.getPosts();

      // Assert
      verify(() => mockRemoteDataSource.getPosts()).called(1);
      expect(result, isA<Left<Failure, List<Post>>>());
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('getPostById', () {
    const tPostModel = PostModel(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );
    const tId = 1;

    test('should return Post when the call to remote data source is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getPostById(tId))
          .thenAnswer((_) async => tPostModel);

      // Act
      final result = await repository.getPostById(tId);

      // Assert
      verify(() => mockRemoteDataSource.getPostById(tId)).called(1);
      expect(result, isA<Right<Failure, Post>>());
      final post = result.fold((l) => throw Exception('should not be Left'), (r) => r);
      expect(post.id, tId);
      expect(post.title, 'Test Title');
    });

    test('should return ServerFailure when the call to remote data source is unsuccessful', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockRemoteDataSource.getPostById(tId))
          .thenThrow(failure);

      // Act
      final result = await repository.getPostById(tId);

      // Assert
      verify(() => mockRemoteDataSource.getPostById(tId)).called(1);
      expect(result, isA<Left<Failure, Post>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      when(() => mockRemoteDataSource.getPostById(tId))
          .thenThrow(failure);

      // Act
      final result = await repository.getPostById(tId);

      // Assert
      verify(() => mockRemoteDataSource.getPostById(tId)).called(1);
      expect(result, isA<Left<Failure, Post>>());
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('getCommentsByPostId', () {
    final tCommentModels = [
      const CommentModel(
        id: 1,
        postId: 1,
        name: 'Test Name 1',
        email: 'test1@example.com',
        body: 'Test Body 1',
      ),
      const CommentModel(
        id: 2,
        postId: 1,
        name: 'Test Name 2',
        email: 'test2@example.com',
        body: 'Test Body 2',
      ),
    ];
    const tPostId = 1;

    test('should return remote data when the call to remote data source is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCommentsByPostId(tPostId))
          .thenAnswer((_) async => tCommentModels);

      // Act
      final result = await repository.getCommentsByPostId(tPostId);

      // Assert
      verify(() => mockRemoteDataSource.getCommentsByPostId(tPostId)).called(1);
      expect(result, isA<Right<Failure, List<Comment>>>());
      final comments = result.fold((l) => <Comment>[], (r) => r);
      expect(comments.length, 2);
      expect(comments[0].id, 1);
      expect(comments[1].id, 2);
    });

    test('should return ServerFailure when the call to remote data source is unsuccessful', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockRemoteDataSource.getCommentsByPostId(tPostId))
          .thenThrow(failure);

      // Act
      final result = await repository.getCommentsByPostId(tPostId);

      // Assert
      verify(() => mockRemoteDataSource.getCommentsByPostId(tPostId)).called(1);
      expect(result, isA<Left<Failure, List<Comment>>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      when(() => mockRemoteDataSource.getCommentsByPostId(tPostId))
          .thenThrow(failure);

      // Act
      final result = await repository.getCommentsByPostId(tPostId);

      // Assert
      verify(() => mockRemoteDataSource.getCommentsByPostId(tPostId)).called(1);
      expect(result, isA<Left<Failure, List<Comment>>>());
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });
}

