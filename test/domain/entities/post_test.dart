import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';

void main() {
  group('Post', () {
    test('should be a subclass of Equatable', () {
      // Arrange
      const post = Post(
        id: 1,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(post, isA<Post>());
    });

    test('should create a Post with all properties', () {
      // Arrange
      const post = Post(
        id: 1,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(post.id, 1);
      expect(post.userId, 1);
      expect(post.title, 'Test Title');
      expect(post.body, 'Test Body');
    });

    test('should support value equality', () {
      // Arrange
      const post1 = Post(
        id: 1,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );
      const post2 = Post(
        id: 1,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(post1, equals(post2));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      const post1 = Post(
        id: 1,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );
      const post2 = Post(
        id: 2,
        userId: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(post1, isNot(equals(post2)));
    });
  });
}

