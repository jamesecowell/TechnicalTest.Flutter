import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_local_data_source_impl.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';

void main() {
  late PostLocalDataSourceImpl dataSource;
  late sqflite_ffi.Database database;

  setUpAll(() {
    // Initialize sqflite for testing
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
  });

  setUp(() async {
    // Create in-memory database for each test
    database = await sqflite_ffi.openDatabase(
      sqflite_ffi.inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY,
            userId INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL
          )
        ''');
      },
    );
    dataSource = PostLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('savePost', () {
    const tPost = PostModel(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should save post to database', () async {
      // Act
      await dataSource.savePost(tPost);

      // Assert
      final savedPosts = await dataSource.getOfflinePosts();
      expect(savedPosts.length, 1);
      expect(savedPosts[0].id, tPost.id);
      expect(savedPosts[0].title, tPost.title);
      expect(savedPosts[0].body, tPost.body);
    });

    test('should update post if it already exists', () async {
      // Arrange
      await dataSource.savePost(tPost);
      const updatedPost = PostModel(
        id: 1,
        userId: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );

      // Act
      await dataSource.savePost(updatedPost);

      // Assert
      final savedPosts = await dataSource.getOfflinePosts();
      expect(savedPosts.length, 1);
      expect(savedPosts[0].title, 'Updated Title');
      expect(savedPosts[0].body, 'Updated Body');
    });

    test('should throw CacheFailure when database operation fails', () async {
      // Arrange - close database to cause failure
      await database.close();

      // Act & Assert
      expect(
        () => dataSource.savePost(tPost),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('deletePost', () {
    const tPost = PostModel(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should delete post from database', () async {
      // Arrange
      await dataSource.savePost(tPost);

      // Act
      await dataSource.deletePost(tPost.id);

      // Assert
      final savedPosts = await dataSource.getOfflinePosts();
      expect(savedPosts.length, 0);
      final isSaved = await dataSource.isPostSaved(tPost.id);
      expect(isSaved, false);
    });

    test('should not throw error when deleting non-existent post', () async {
      // Act & Assert - should not throw
      await dataSource.deletePost(999);
      final savedPosts = await dataSource.getOfflinePosts();
      expect(savedPosts.length, 0);
    });

    test('should throw CacheFailure when database operation fails', () async {
      // Arrange - close database to cause failure
      await database.close();

      // Act & Assert
      expect(
        () => dataSource.deletePost(1),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('isPostSaved', () {
    const tPost = PostModel(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should return true when post is saved', () async {
      // Arrange
      await dataSource.savePost(tPost);

      // Act
      final result = await dataSource.isPostSaved(tPost.id);

      // Assert
      expect(result, true);
    });

    test('should return false when post is not saved', () async {
      // Act
      final result = await dataSource.isPostSaved(999);

      // Assert
      expect(result, false);
    });

    test('should throw CacheFailure when database operation fails', () async {
      // Arrange - close database to cause failure
      await database.close();

      // Act & Assert
      expect(
        () => dataSource.isPostSaved(1),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('getOfflinePosts', () {
    const tPosts = [
      PostModel(
        id: 1,
        userId: 1,
        title: 'Test Title 1',
        body: 'Test Body 1',
      ),
      PostModel(
        id: 2,
        userId: 2,
        title: 'Test Title 2',
        body: 'Test Body 2',
      ),
    ];

    test('should return list of saved posts', () async {
      // Arrange
      await dataSource.savePost(tPosts[0]);
      await dataSource.savePost(tPosts[1]);

      // Act
      final result = await dataSource.getOfflinePosts();

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 2);
      expect(result[0].id, tPosts[0].id);
      expect(result[1].id, tPosts[1].id);
    });

    test('should return empty list when no posts are saved', () async {
      // Act
      final result = await dataSource.getOfflinePosts();

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 0);
    });

    test('should throw CacheFailure when database operation fails', () async {
      // Arrange - close database to cause failure
      await database.close();

      // Act & Assert
      expect(
        () => dataSource.getOfflinePosts(),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('getOfflinePostCount', () {
    const tPosts = [
      PostModel(
        id: 1,
        userId: 1,
        title: 'Test Title 1',
        body: 'Test Body 1',
      ),
      PostModel(
        id: 2,
        userId: 2,
        title: 'Test Title 2',
        body: 'Test Body 2',
      ),
    ];

    test('should return correct count of saved posts', () async {
      // Arrange
      await dataSource.savePost(tPosts[0]);
      await dataSource.savePost(tPosts[1]);

      // Act
      final result = await dataSource.getOfflinePostCount();

      // Assert
      expect(result, 2);
    });

    test('should return 0 when no posts are saved', () async {
      // Act
      final result = await dataSource.getOfflinePostCount();

      // Assert
      expect(result, 0);
    });

    test('should throw CacheFailure when database operation fails', () async {
      // Arrange - close database to cause failure
      await database.close();

      // Act & Assert
      expect(
        () => dataSource.getOfflinePostCount(),
        throwsA(isA<CacheFailure>()),
      );
    });
  });
}

