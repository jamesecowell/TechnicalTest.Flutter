import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';

void main() {
  group('Comment', () {
    test('should be a subclass of Equatable', () {
      // Arrange
      const comment = Comment(
        id: 1,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );

      // Assert
      expect(comment, isA<Comment>());
    });

    test('should create a Comment with all properties', () {
      // Arrange
      const comment = Comment(
        id: 1,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );

      // Assert
      expect(comment.id, 1);
      expect(comment.postId, 1);
      expect(comment.name, 'Test Name');
      expect(comment.email, 'test@example.com');
      expect(comment.body, 'Test Body');
    });

    test('should support value equality', () {
      // Arrange
      const comment1 = Comment(
        id: 1,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );
      const comment2 = Comment(
        id: 1,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );

      // Assert
      expect(comment1, equals(comment2));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      const comment1 = Comment(
        id: 1,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );
      const comment2 = Comment(
        id: 2,
        postId: 1,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );

      // Assert
      expect(comment1, isNot(equals(comment2)));
    });
  });
}

