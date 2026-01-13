import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/presentation/widgets/comment_list_item.dart';

void main() {
  const tComment = Comment(
    id: 1,
    postId: 1,
    name: 'Test Name',
    email: 'test@example.com',
    body: 'Test Body',
  );

  testWidgets('should display comment name and body',
      (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CommentListItem(
            comment: tComment,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Name'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Test Body'), findsOneWidget);
  });
}
