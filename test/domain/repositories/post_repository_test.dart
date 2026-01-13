import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:mocktail/mocktail.dart';

// Note: Repository interface tests are primarily for documentation.
// Actual testing happens in repository implementation tests.
class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
  });

  group('PostRepository', () {
    const tPost = Post(
      id: 1,
      userId: 1,
      title: 'Test Title',
      body: 'Test Body',
    );
    const tPosts = [tPost];

    test('should return a list of Posts when getPosts is called', () async {
      // Arrange
      when(() => mockPostRepository.getPosts())
          .thenAnswer((_) async => const Right(tPosts));

      // Act
      final result = await mockPostRepository.getPosts();

      // Assert
      expect(result, const Right(tPosts));
      verify(() => mockPostRepository.getPosts()).called(1);
    });

    test('should return a Post when getPostById is called with valid id', () async {
      // Arrange
      when(() => mockPostRepository.getPostById(1))
          .thenAnswer((_) async => const Right(tPost));

      // Act
      final result = await mockPostRepository.getPostById(1);

      // Assert
      expect(result, const Right(tPost));
      verify(() => mockPostRepository.getPostById(1)).called(1);
    });

    test('should return ServerFailure when getPosts fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockPostRepository.getPosts())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await mockPostRepository.getPosts();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockPostRepository.getPosts()).called(1);
    });

    test('should return ServerFailure when getPostById fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(() => mockPostRepository.getPostById(1))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await mockPostRepository.getPostById(1);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockPostRepository.getPostById(1)).called(1);
    });
  });
}

