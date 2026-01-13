import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late GetCommentsByPostId useCase;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = GetCommentsByPostId(mockPostRepository);
  });

  const tComments = [
    Comment(
      id: 1,
      postId: 1,
      name: 'Test Name 1',
      email: 'test1@example.com',
      body: 'Test Body 1',
    ),
    Comment(
      id: 2,
      postId: 1,
      name: 'Test Name 2',
      email: 'test2@example.com',
      body: 'Test Body 2',
    ),
  ];
  const tPostId = 1;

  test('should get comments by post id from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getCommentsByPostId(tPostId))
        .thenAnswer((_) async => const Right(tComments));

    // Act
    final result = await useCase(const GetCommentsByPostIdParams(postId: tPostId));

    // Assert
    expect(result, const Right(tComments));
    verify(() => mockPostRepository.getCommentsByPostId(tPostId)).called(1);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    const failure = ServerFailure('Server error');
    when(() => mockPostRepository.getCommentsByPostId(tPostId))
        .thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(const GetCommentsByPostIdParams(postId: tPostId));

    // Assert
    expect(result, const Left(failure));
    verify(() => mockPostRepository.getCommentsByPostId(tPostId)).called(1);
  });
}

