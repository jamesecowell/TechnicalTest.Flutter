import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';

void main() {
  const tPostModel = PostModel(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  const tPostJson = {
    'id': 1,
    'userId': 1,
    'title': 'Test Title',
    'body': 'Test Body',
  };

  group('PostModel', () {
    test('should be a subclass of Post entity', () {
      // Assert
      expect(tPostModel, isA<Post>());
    });

    test('should create a PostModel from JSON', () {
      // Act
      final result = PostModel.fromJson(tPostJson);

      // Assert
      expect(result, tPostModel);
    });

    test('should convert a PostModel to JSON', () {
      // Act
      final result = tPostModel.toJson();

      // Assert
      expect(result, tPostJson);
    });

    test('should create a PostModel from JSON with different values', () {
      // Arrange
      const json = {
        'id': 2,
        'userId': 3,
        'title': 'Another Title',
        'body': 'Another Body',
      };

      // Act
      final result = PostModel.fromJson(json);

      // Assert
      expect(result.id, 2);
      expect(result.userId, 3);
      expect(result.title, 'Another Title');
      expect(result.body, 'Another Body');
    });

    test('should convert PostModel to Post entity', () {
      // Act
      final post = tPostModel.toEntity();

      // Assert
      expect(post, isA<Post>());
      expect(post.id, tPostModel.id);
      expect(post.userId, tPostModel.userId);
      expect(post.title, tPostModel.title);
      expect(post.body, tPostModel.body);
    });
  });
}

