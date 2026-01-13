import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_details_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPostById extends Mock implements GetPostById {}

void main() {
  late PostDetailsViewModel viewModel;
  late MockGetPostById mockGetPostById;

  setUpAll(() {
    registerFallbackValue(const GetPostByIdParams(id: 0));
  });

  setUp(() {
    mockGetPostById = MockGetPostById();
    viewModel = PostDetailsViewModel(getPostById: mockGetPostById);
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

      // Act
      await viewModel.loadPost(tId);

      // Assert
      final state = viewModel.state;
      expect(state.hasValue, true);
      expect(state.value, tPost);
      verify(() => mockGetPostById(const GetPostByIdParams(id: tId))).called(1);
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

      // Act
      final future = viewModel.loadPost(tId);
      
      // Assert - state should be loading
      expect(viewModel.state.isLoading, true);
      
      // Wait for completion
      await future;
      expect(viewModel.state.hasValue, true);
    });
  });
}

