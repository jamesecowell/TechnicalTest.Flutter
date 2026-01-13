import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_posts.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_list_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPosts extends Mock implements GetPosts {}

void main() {
  late PostListViewModel viewModel;
  late MockGetPosts mockGetPosts;

  setUp(() async {
    mockGetPosts = MockGetPosts();
    // Setup default mock response to handle auto-load in constructor
    when(() => mockGetPosts()).thenAnswer((_) async => const Right(<Post>[]));
    viewModel = PostListViewModel(getPosts: mockGetPosts);
    // Wait for auto-load to complete
    await Future.delayed(const Duration(milliseconds: 50));
    // Clear previous verifications
    reset(mockGetPosts);
    // Re-setup default mock response
    when(() => mockGetPosts()).thenAnswer((_) async => const Right(<Post>[]));
  });

  group('loadPosts', () {
    const tPosts = [
      Post(
        id: 1,
        userId: 1,
        title: 'Test Title 1',
        body: 'Test Body 1',
      ),
      Post(
        id: 2,
        userId: 2,
        title: 'Test Title 2',
        body: 'Test Body 2',
      ),
    ];

    test('should update state with posts when getPosts succeeds', () async {
      // Arrange
      when(() => mockGetPosts()).thenAnswer((_) async => const Right(tPosts));

      // Act
      await viewModel.loadPosts();

      // Assert
      final state = viewModel.state;
      expect(state.hasValue, true);
      expect(state.value, tPosts);
      verify(() => mockGetPosts()).called(1);
    });

    test('should update state with error when getPosts fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockGetPosts()).thenAnswer((_) async => const Left(failure));

      // Act
      await viewModel.loadPosts();

      // Assert
      final state = viewModel.state;
      expect(state.isLoading, false);
      expect(state.hasValue, false);
      // Verify error state by checking it's not loading and has no value
      // (AsyncValue.error will throw if we try to access .value)
      expect(() => state.value, throwsA(anything));
      verify(() => mockGetPosts()).called(1);
    });

    test('should set loading state initially', () async {
      // Arrange
      when(() => mockGetPosts()).thenAnswer((_) async => const Right(tPosts));

      // Act
      final future = viewModel.loadPosts();

      // Assert - state should be loading
      expect(viewModel.state.isLoading, true);

      // Wait for completion
      await future;
      expect(viewModel.state.hasValue, true);
    });
  });
}
