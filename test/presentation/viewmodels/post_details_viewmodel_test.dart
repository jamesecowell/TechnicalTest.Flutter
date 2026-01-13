import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:flutter_tech_task/domain/usecases/is_post_saved_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/save_post_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/unsave_post_for_offline.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_details_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPostById extends Mock implements GetPostById {}

class MockIsPostSavedForOffline extends Mock implements IsPostSavedForOffline {}

class MockSavePostForOffline extends Mock implements SavePostForOffline {}

class MockUnsavePostForOffline extends Mock implements UnsavePostForOffline {}

void main() {
  late PostDetailsViewModel viewModel;
  late MockGetPostById mockGetPostById;
  late MockIsPostSavedForOffline mockIsPostSavedForOffline;
  late MockSavePostForOffline mockSavePostForOffline;
  late MockUnsavePostForOffline mockUnsavePostForOffline;

  setUpAll(() {
    registerFallbackValue(const GetPostByIdParams(id: 0));
    registerFallbackValue(const IsPostSavedForOfflineParams(postId: 0));
    registerFallbackValue(const UnsavePostForOfflineParams(postId: 0));
    registerFallbackValue(const Post(
      id: 0,
      userId: 0,
      title: '',
      body: '',
    ));
  });

  setUp(() {
    mockGetPostById = MockGetPostById();
    mockIsPostSavedForOffline = MockIsPostSavedForOffline();
    mockSavePostForOffline = MockSavePostForOffline();
    mockUnsavePostForOffline = MockUnsavePostForOffline();
    viewModel = PostDetailsViewModel(
      getPostById: mockGetPostById,
      isPostSavedForOffline: mockIsPostSavedForOffline,
      savePostForOffline: mockSavePostForOffline,
      unsavePostForOffline: mockUnsavePostForOffline,
    );
  });

  group('loadPost', () {
    const tPost = Post(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );
    const tId = 1;

    test('should update state with post when getPostById succeeds', () async {
      // Arrange
      when(() => mockGetPostById(any()))
          .thenAnswer((_) async => const Right(tPost));
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(false));

      // Act
      await viewModel.loadPost(tId);

      // Assert
      final state = viewModel.state;
      expect(state.hasValue, true);
      expect(state.value, tPost);
      verify(() => mockGetPostById(const GetPostByIdParams(id: tId))).called(1);
      verify(() => mockIsPostSavedForOffline(
          const IsPostSavedForOfflineParams(postId: tId))).called(1);
    });

    test('should update state with error when getPostById fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockGetPostById(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      await viewModel.loadPost(tId);

      // Assert
      final state = viewModel.state;
      expect(state.isLoading, false);
      expect(state.hasValue, false);
      expect(() => state.value, throwsA(anything));
      verify(() => mockGetPostById(const GetPostByIdParams(id: tId))).called(1);
    });

    test('should set loading state initially', () async {
      // Arrange
      when(() => mockGetPostById(any()))
          .thenAnswer((_) async => const Right(tPost));
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(false));

      // Act
      final future = viewModel.loadPost(tId);

      // Assert - state should be loading
      expect(viewModel.state.isLoading, true);

      // Wait for completion
      await future;
      expect(viewModel.state.hasValue, true);
    });
  });

  group('checkSavedStatus', () {
    const tPostId = 1;

    test('should update savedStatus when post is saved', () async {
      // Arrange
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      await viewModel.checkSavedStatus(tPostId);

      // Assert
      expect(viewModel.savedStatus.hasValue, true);
      expect(viewModel.savedStatus.value, true);
      verify(() => mockIsPostSavedForOffline(
          const IsPostSavedForOfflineParams(postId: tPostId))).called(1);
    });

    test('should update savedStatus when post is not saved', () async {
      // Arrange
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(false));

      // Act
      await viewModel.checkSavedStatus(tPostId);

      // Assert
      expect(viewModel.savedStatus.hasValue, true);
      expect(viewModel.savedStatus.value, false);
      verify(() => mockIsPostSavedForOffline(
          const IsPostSavedForOfflineParams(postId: tPostId))).called(1);
    });
  });

  group('toggleSavePost', () {
    const tPost = Post(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should save post when not saved', () async {
      // Arrange
      viewModel.savedStatusNotifier.state = const AsyncValue.data(false);
      when(() => mockSavePostForOffline(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      await viewModel.toggleSavePost(tPost);
      // Wait a bit for the async checkSavedStatus to complete
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      verify(() => mockSavePostForOffline(tPost)).called(1);
      verify(() => mockIsPostSavedForOffline(
          IsPostSavedForOfflineParams(postId: tPost.id))).called(1);
      expect(viewModel.savedStatus.value, true);
    });

    test('should unsave post when saved', () async {
      // Arrange
      viewModel.savedStatusNotifier.state = const AsyncValue.data(true);
      when(() => mockUnsavePostForOffline(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockIsPostSavedForOffline(any()))
          .thenAnswer((_) async => const Right(false));

      // Act
      await viewModel.toggleSavePost(tPost);
      // Wait a bit for the async checkSavedStatus to complete
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      verify(() => mockUnsavePostForOffline(
          UnsavePostForOfflineParams(postId: tPost.id))).called(1);
      verify(() => mockIsPostSavedForOffline(
          IsPostSavedForOfflineParams(postId: tPost.id))).called(1);
      expect(viewModel.savedStatus.value, false);
    });
  });
}
