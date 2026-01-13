import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_posts.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late GetOfflinePosts useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = GetOfflinePosts(mockPostRepository);
  });

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

  test('should get offline posts from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getOfflinePosts())
        .thenAnswer((_) async => const Right(tPosts));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Right(tPosts));
    verify(() => mockPostRepository.getOfflinePosts()).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = CacheFailure('Cache error');
    when(() => mockPostRepository.getOfflinePosts())
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.getOfflinePosts()).called(1);
  });
}

