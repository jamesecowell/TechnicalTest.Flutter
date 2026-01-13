import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';

class CommentsViewModel extends StateNotifier<AsyncValue<List<Comment>>> {
  final GetCommentsByPostId getCommentsByPostId;
  static const int _maxRetryAttempts = 10;
  int _retryCount = 0;

  CommentsViewModel({required this.getCommentsByPostId}) : super(const AsyncValue.loading());

  Future<void> loadComments(int postId) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final result = await getCommentsByPostId(GetCommentsByPostIdParams(postId: postId));
      if (!mounted) return;
      // Reset retry count on success
      _retryCount = 0;
      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (comments) {
          state = AsyncValue.data(comments);
        },
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      // If repository not ready yet, wait and retry (with max attempts)
      if (e is UnimplementedError && (e.message?.contains('not initialized') ?? false)) {
        _retryCount++;
        if (_retryCount >= _maxRetryAttempts) {
          // Max retries reached, show error
          if (mounted) {
            state = AsyncValue.error(
              Exception('Failed to initialize repository after $_maxRetryAttempts attempts'),
              stackTrace,
            );
          }
          return;
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await loadComments(postId);
        }
        return;
      }
      // Reset retry count for non-retryable errors
      _retryCount = 0;
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }
}

