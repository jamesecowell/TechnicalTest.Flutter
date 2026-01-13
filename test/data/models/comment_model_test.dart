import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/data/models/comment_model.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';

void main() {
  group('CommentModel', () {
    const tCommentModel = CommentModel(
      id: 1,
      postId: 1,
      name: 'Test Name',
      email: 'test@example.com',
      body: 'Test Body',
    );

    const tCommentJson = {
      'id': 1,
      'postId': 1,
      'name': 'Test Name',
      'email': 'test@example.com',
      'body': 'Test Body',
    };

    test('should be a subclass of Comment entity', () {
      // Assert
      expect(tCommentModel, isA<Comment>());
    });

    test('should create a CommentModel from JSON', () {
      // Act
      final result = CommentModel.fromJson(tCommentJson);

      // Assert
      expect(result, isA<CommentModel>());
      expect(result.id, 1);
      expect(result.postId, 1);
      expect(result.name, 'Test Name');
      expect(result.email, 'test@example.com');
      expect(result.body, 'Test Body');
    });

    test('should convert CommentModel to JSON', () {
      // Act
      final result = tCommentModel.toJson();

      // Assert
      expect(result, tCommentJson);
    });

    test('should convert CommentModel to Comment entity', () {
      // Act
      final result = tCommentModel.toEntity();

      // Assert
      expect(result, isA<Comment>());
      expect(result.id, 1);
      expect(result.postId, 1);
      expect(result.name, 'Test Name');
      expect(result.email, 'test@example.com');
      expect(result.body, 'Test Body');
    });
  });
}

