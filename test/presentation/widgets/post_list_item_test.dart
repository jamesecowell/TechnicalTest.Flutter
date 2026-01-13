import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/presentation/widgets/post_list_item.dart';

void main() {
  const tPost = Post(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  testWidgets('should display post title and body',
      (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostListItem(
            post: tPost,
            onTap: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Body'), findsOneWidget);
  });

  testWidgets('should call onTap when tapped', (WidgetTester tester) async {
    // Arrange
    bool tapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostListItem(
            post: tPost,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    // Assert
    expect(tapped, true);
  });
}
