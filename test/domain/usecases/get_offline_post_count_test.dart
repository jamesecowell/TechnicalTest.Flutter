import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_post_count.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late GetOfflinePostCount useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = GetOfflinePostCount(mockPostRepository);
  });

  test('should get offline post count from the repository', () async {
    // Arrange
    const tCount = 5;
    when(() => mockPostRepository.getOfflinePostCount())
        .thenAnswer((_) async => const Right(tCount));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Right(tCount));
    verify(() => mockPostRepository.getOfflinePostCount()).called(1);
  });

  test('should return 0 when no posts are saved', () async {
    // Arrange
    when(() => mockPostRepository.getOfflinePostCount())
        .thenAnswer((_) async => const Right(0));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Right(0));
    verify(() => mockPostRepository.getOfflinePostCount()).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = CacheFailure('Cache error');
    when(() => mockPostRepository.getOfflinePostCount())
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.getOfflinePostCount()).called(1);
  });
}

