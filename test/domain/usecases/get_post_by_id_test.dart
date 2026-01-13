import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late GetPostById useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = GetPostById(mockPostRepository);
  });

  const tPost = Post(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );
  const tId = 1;

  test('should get post by id from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getPostById(tId))
        .thenAnswer((_) async => const Right(tPost));

    // Act
    final result = await useCase(const GetPostByIdParams(id: tId));

    // Assert
    expect(result, const Right(tPost));
    verify(() => mockPostRepository.getPostById(tId)).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = ServerFailure('Server error');
    when(() => mockPostRepository.getPostById(tId))
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(const GetPostByIdParams(id: tId));

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.getPostById(tId)).called(1);
  });
}
