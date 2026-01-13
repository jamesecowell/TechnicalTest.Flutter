import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/unsave_post_for_offline.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late UnsavePostForOffline useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = UnsavePostForOffline(mockPostRepository);
  });

  const tPostId = 1;
  const tParams = UnsavePostForOfflineParams(postId: tPostId);

  test('should unsave post for offline from the repository', () async {
    // Arrange
    when(() => mockPostRepository.unsavePostForOffline(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Right(null));
    verify(() => mockPostRepository.unsavePostForOffline(tPostId)).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = CacheFailure('Cache error');
    when(() => mockPostRepository.unsavePostForOffline(any()))
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.unsavePostForOffline(tPostId)).called(1);
  });
}

