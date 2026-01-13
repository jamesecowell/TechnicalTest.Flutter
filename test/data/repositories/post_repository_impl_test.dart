import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_local_data_source.dart';
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/data/models/comment_model.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';
import 'package:flutter_tech_task/data/repositories/post_repository_impl.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockPostLocalDataSource extends Mock implements PostLocalDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemoteDataSource;
  late MockPostLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(const PostModel(
      id: 0,
      userId: 0,
      title: '',
      body: '',
    ));
  });

  setUp(() {
    mockRemoteDataSource = MockPostRemoteDataSource();
    mockLocalDataSource = MockPostLocalDataSource();
    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
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

  group('savePostForOffline', () {
    const tPost = Post(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );
    const tPostModel = PostModel(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should save post to local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.savePost(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.savePostForOffline(tPost);

      // Assert
      verify(() => mockLocalDataSource.savePost(tPostModel)).called(1);
      expect(result, isA<Right<Failure, void>>());
    });

    test('should return CacheFailure when local data source fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockLocalDataSource.savePost(any())).thenThrow(failure);

      // Act
      final result = await repository.savePostForOffline(tPost);

      // Assert
      verify(() => mockLocalDataSource.savePost(tPostModel)).called(1);
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('unsavePostForOffline', () {
    const tPostId = 1;

    test('should delete post from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.deletePost(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.unsavePostForOffline(tPostId);

      // Assert
      verify(() => mockLocalDataSource.deletePost(tPostId)).called(1);
      expect(result, isA<Right<Failure, void>>());
    });

    test('should return CacheFailure when local data source fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockLocalDataSource.deletePost(any())).thenThrow(failure);

      // Act
      final result = await repository.unsavePostForOffline(tPostId);

      // Assert
      verify(() => mockLocalDataSource.deletePost(tPostId)).called(1);
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('isPostSavedForOffline', () {
    const tPostId = 1;

    test('should return true when post is saved', () async {
      // Arrange
      when(() => mockLocalDataSource.isPostSaved(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.isPostSavedForOffline(tPostId);

      // Assert
      verify(() => mockLocalDataSource.isPostSaved(tPostId)).called(1);
      expect(result, isA<Right<Failure, bool>>());
      final isSaved = result.fold((l) => throw Exception('should not be Left'), (r) => r);
      expect(isSaved, true);
    });

    test('should return false when post is not saved', () async {
      // Arrange
      when(() => mockLocalDataSource.isPostSaved(any()))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isPostSavedForOffline(tPostId);

      // Assert
      verify(() => mockLocalDataSource.isPostSaved(tPostId)).called(1);
      expect(result, isA<Right<Failure, bool>>());
      final isSaved = result.fold((l) => throw Exception('should not be Left'), (r) => r);
      expect(isSaved, false);
    });

    test('should return CacheFailure when local data source fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockLocalDataSource.isPostSaved(any())).thenThrow(failure);

      // Act
      final result = await repository.isPostSavedForOffline(tPostId);

      // Assert
      verify(() => mockLocalDataSource.isPostSaved(tPostId)).called(1);
      expect(result, isA<Left<Failure, bool>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('getOfflinePosts', () {
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

    test('should return list of offline posts from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getOfflinePosts())
          .thenAnswer((_) async => tPostModels);

      // Act
      final result = await repository.getOfflinePosts();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePosts()).called(1);
      expect(result, isA<Right<Failure, List<Post>>>());
      final posts = result.fold((l) => <Post>[], (r) => r);
      expect(posts.length, 2);
      expect(posts[0].id, 1);
      expect(posts[1].id, 2);
    });

    test('should return empty list when no posts are saved', () async {
      // Arrange
      when(() => mockLocalDataSource.getOfflinePosts())
          .thenAnswer((_) async => <PostModel>[]);

      // Act
      final result = await repository.getOfflinePosts();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePosts()).called(1);
      expect(result, isA<Right<Failure, List<Post>>>());
      final posts = result.fold((l) => <Post>[], (r) => r);
      expect(posts.length, 0);
    });

    test('should return CacheFailure when local data source fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockLocalDataSource.getOfflinePosts()).thenThrow(failure);

      // Act
      final result = await repository.getOfflinePosts();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePosts()).called(1);
      expect(result, isA<Left<Failure, List<Post>>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });

  group('getOfflinePostCount', () {
    test('should return count of offline posts from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getOfflinePostCount())
          .thenAnswer((_) async => 5);

      // Act
      final result = await repository.getOfflinePostCount();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePostCount()).called(1);
      expect(result, isA<Right<Failure, int>>());
      final count = result.fold((l) => throw Exception('should not be Left'), (r) => r);
      expect(count, 5);
    });

    test('should return 0 when no posts are saved', () async {
      // Arrange
      when(() => mockLocalDataSource.getOfflinePostCount())
          .thenAnswer((_) async => 0);

      // Act
      final result = await repository.getOfflinePostCount();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePostCount()).called(1);
      expect(result, isA<Right<Failure, int>>());
      final count = result.fold((l) => throw Exception('should not be Left'), (r) => r);
      expect(count, 0);
    });

    test('should return CacheFailure when local data source fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockLocalDataSource.getOfflinePostCount()).thenThrow(failure);

      // Act
      final result = await repository.getOfflinePostCount();

      // Assert
      verify(() => mockLocalDataSource.getOfflinePostCount()).called(1);
      expect(result, isA<Left<Failure, int>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('should have returned Left<Failure>'),
      );
    });
  });
}

