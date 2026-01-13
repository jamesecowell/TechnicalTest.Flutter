import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/save_post_for_offline.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late SavePostForOffline useCase;

  setUpAll(() {
    registerFallbackValue(const Post(
      id: 0,
      userId: 0,
      title: '',
      body: '',
    ));
  });

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = SavePostForOffline(mockPostRepository);
  });

  const tPost = Post(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  test('should save post for offline from the repository', () async {
    // Arrange
    when(() => mockPostRepository.savePostForOffline(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase(tPost);

    // Assert
    expect(result, const Right(null));
    verify(() => mockPostRepository.savePostForOffline(tPost)).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = CacheFailure('Cache error');
    when(() => mockPostRepository.savePostForOffline(any()))
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(tPost);

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.savePostForOffline(tPost)).called(1);
  });
}

