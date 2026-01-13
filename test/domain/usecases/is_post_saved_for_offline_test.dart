import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/is_post_saved_for_offline.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late IsPostSavedForOffline useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = IsPostSavedForOffline(mockPostRepository);
  });

  const tPostId = 1;
  const tParams = IsPostSavedForOfflineParams(postId: tPostId);

  test('should return true when post is saved for offline', () async {
    // Arrange
    when(() => mockPostRepository.isPostSavedForOffline(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Right(true));
    verify(() => mockPostRepository.isPostSavedForOffline(tPostId)).called(1);
  });

  test('should return false when post is not saved for offline', () async {
    // Arrange
    when(() => mockPostRepository.isPostSavedForOffline(any()))
        .thenAnswer((_) async => const Right(false));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Right(false));
    verify(() => mockPostRepository.isPostSavedForOffline(tPostId)).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = CacheFailure('Cache error');
    when(() => mockPostRepository.isPostSavedForOffline(any()))
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.isPostSavedForOffline(tPostId)).called(1);
  });
}

