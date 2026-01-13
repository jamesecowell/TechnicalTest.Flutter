import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_posts.dart';
import 'package:flutter_tech_task/presentation/viewmodels/offline_post_list_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOfflinePosts extends Mock implements GetOfflinePosts {}

void main() {
  late OfflinePostListViewModel viewModel;
  late MockGetOfflinePosts mockGetOfflinePosts;

  setUp(() async {
    mockGetOfflinePosts = MockGetOfflinePosts();
    // Setup default mock response to handle auto-load in constructor
    when(() => mockGetOfflinePosts()).thenAnswer((_) async => const Right(<Post>[]));
    viewModel = OfflinePostListViewModel(getOfflinePosts: mockGetOfflinePosts);
    // Wait for auto-load to complete
    await Future.delayed(const Duration(milliseconds: 50));
    // Clear previous verifications
    reset(mockGetOfflinePosts);
    // Re-setup default mock response
    when(() => mockGetOfflinePosts()).thenAnswer((_) async => const Right(<Post>[]));
  });

  group('loadOfflinePosts', () {
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

    test('should update state with posts when getOfflinePosts succeeds', () async {
      // Arrange
      when(() => mockGetOfflinePosts())
          .thenAnswer((_) async => const Right(tPosts));

      // Act
      await viewModel.loadOfflinePosts();

      // Assert
      final state = viewModel.state;
      expect(state.hasValue, true);
      expect(state.value, tPosts);
      verify(() => mockGetOfflinePosts()).called(1);
    });

    test('should update state with error when getOfflinePosts fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockGetOfflinePosts())
          .thenAnswer((_) async => const Left(failure));

      // Act
      await viewModel.loadOfflinePosts();

      // Assert
      final state = viewModel.state;
      expect(state.isLoading, false);
      expect(state.hasValue, false);
      expect(() => state.value, throwsA(anything));
      verify(() => mockGetOfflinePosts()).called(1);
    });

    test('should set loading state initially', () async {
      // Arrange
      when(() => mockGetOfflinePosts())
          .thenAnswer((_) async => const Right(tPosts));

      // Act
      final future = viewModel.loadOfflinePosts();
      
      // Assert - state should be loading
      expect(viewModel.state.isLoading, true);
      
      // Wait for completion
      await future;
      expect(viewModel.state.hasValue, true);
    });
  });
}

