import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';
import 'package:flutter_tech_task/presentation/pages/comments_page.dart';
import 'package:flutter_tech_task/presentation/viewmodels/comments_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCommentsByPostId extends Mock implements GetCommentsByPostId {}

void main() {
  late MockGetCommentsByPostId mockGetCommentsByPostId;

  setUpAll(() {
    registerFallbackValue(const GetCommentsByPostIdParams(postId: 0));
  });

  setUp(() {
    mockGetCommentsByPostId = MockGetCommentsByPostId();
  });

  testWidgets('should display loading widget initially', (WidgetTester tester) async {
    // Arrange
    when(() => mockGetCommentsByPostId(any()))
        .thenAnswer((_) async => const Right(<Comment>[]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          commentsViewModelProvider.overrideWith(
            (ref) => CommentsViewModel(getCommentsByPostId: mockGetCommentsByPostId),
          ),
        ],
        child: MaterialApp(
          routes: {
            'comments/': (context) => const CommentsPage(),
          },
          initialRoute: 'comments/',
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should display comments when loaded', (WidgetTester tester) async {
    // Arrange
    const tComments = [
      Comment(
        id: 1,
        postId: 1,
        name: 'Test Name 1',
        email: 'test1@example.com',
        body: 'Test Body 1',
      ),
      Comment(
        id: 2,
        postId: 1,
        name: 'Test Name 2',
        email: 'test2@example.com',
        body: 'Test Body 2',
      ),
    ];
    when(() => mockGetCommentsByPostId(any()))
        .thenAnswer((_) async => const Right(tComments));

    final viewModel = CommentsViewModel(getCommentsByPostId: mockGetCommentsByPostId);
    await viewModel.loadComments(1);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          commentsViewModelProvider.overrideWith(
            (ref) => viewModel,
          ),
        ],
        child: MaterialApp(
          routes: {
            'comments/': (context) => const CommentsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == 'comments/') {
              return MaterialPageRoute(
                builder: (context) => const CommentsPage(),
                settings: const RouteSettings(
                  name: 'comments/',
                  arguments: {'postId': 1},
                ),
              );
            }
            return null;
          },
          initialRoute: 'comments/',
        ),
      ),
    );

    await tester.pump();

    // Assert
    expect(find.text('Test Name 1'), findsOneWidget);
    expect(find.text('Test Body 1'), findsOneWidget);
    expect(find.text('Test Name 2'), findsOneWidget);
    expect(find.text('Test Body 2'), findsOneWidget);
  });

  testWidgets('should display error widget when loading fails', (WidgetTester tester) async {
    // Arrange
    const failure = ServerFailure('Server error');
    when(() => mockGetCommentsByPostId(any()))
        .thenAnswer((_) async => const Left(failure));

    final viewModel = CommentsViewModel(getCommentsByPostId: mockGetCommentsByPostId);
    await viewModel.loadComments(1);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          commentsViewModelProvider.overrideWith(
            (ref) => viewModel,
          ),
        ],
        child: MaterialApp(
          routes: {
            'comments/': (context) => const CommentsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == 'comments/') {
              return MaterialPageRoute(
                builder: (context) => const CommentsPage(),
                settings: const RouteSettings(
                  name: 'comments/',
                  arguments: {'postId': 1},
                ),
              );
            }
            return null;
          },
          initialRoute: 'comments/',
        ),
      ),
    );

    await tester.pump();

    // Assert
    expect(find.text('Server error'), findsOneWidget);
  });
}

