import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';
import 'package:flutter_tech_task/presentation/viewmodels/comments_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCommentsByPostId extends Mock implements GetCommentsByPostId {}

void main() {
  late CommentsViewModel viewModel;
  late MockGetCommentsByPostId mockGetCommentsByPostId;

  setUpAll(() {
    registerFallbackValue(const GetCommentsByPostIdParams(postId: 0));
  });

  setUp(() {
    mockGetCommentsByPostId = MockGetCommentsByPostId();
    viewModel = CommentsViewModel(getCommentsByPostId: mockGetCommentsByPostId);
  });

  group('loadComments', () {
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
    const tPostId = 1;

    test('should update state with comments when getCommentsByPostId succeeds', () async {
      // Arrange
      when(() => mockGetCommentsByPostId(any()))
          .thenAnswer((_) async => const Right(tComments));

      // Act
      await viewModel.loadComments(tPostId);

      // Assert
      final state = viewModel.state;
      expect(state.hasValue, true);
      expect(state.value, tComments);
      verify(() => mockGetCommentsByPostId(const GetCommentsByPostIdParams(postId: tPostId))).called(1);
    });

    test('should update state with error when getCommentsByPostId fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockGetCommentsByPostId(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      await viewModel.loadComments(tPostId);

      // Assert
      final state = viewModel.state;
      expect(state.isLoading, false);
      expect(state.hasValue, false);
      expect(() => state.value, throwsA(anything));
      verify(() => mockGetCommentsByPostId(const GetCommentsByPostIdParams(postId: tPostId))).called(1);
    });

    test('should set loading state initially', () async {
      // Arrange
      when(() => mockGetCommentsByPostId(any()))
          .thenAnswer((_) async => const Right(tComments));

      // Act
      final future = viewModel.loadComments(tPostId);
      
      // Assert - state should be loading
      expect(viewModel.state.isLoading, true);
      
      // Wait for completion
      await future;
      expect(viewModel.state.hasValue, true);
    });
  });
}

