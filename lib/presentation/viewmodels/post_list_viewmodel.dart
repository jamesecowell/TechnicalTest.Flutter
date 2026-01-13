import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_posts.dart';

class PostListViewModel extends StateNotifier<AsyncValue<List<Post>>> {
  final GetPosts getPosts;
  static const int _maxRetryAttempts = 10;
  int _retryCount = 0;

  PostListViewModel({required this.getPosts})
      : super(const AsyncValue.loading()) {
    // Auto-load when ViewModel is created with real repository
    // Delay slightly to ensure ViewModel is fully initialized
    Future.microtask(() {
      if (mounted) {
        loadPosts();
      }
    });
  }

  Future<void> loadPosts() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final result = await getPosts();
      if (!mounted) return;
      // Reset retry count on success
      _retryCount = 0;
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (posts) => state = AsyncValue.data(posts),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      // If repository not ready yet, wait and retry (with max attempts)
      if (e is UnimplementedError &&
          (e.message?.contains('not initialized') ?? false)) {
        _retryCount++;
        if (_retryCount >= _maxRetryAttempts) {
          // Max retries reached, show error
          state = AsyncValue.error(
            Exception(
                'Failed to initialize repository after $_maxRetryAttempts attempts'),
            stackTrace,
          );
          return;
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          loadPosts();
        }
        return;
      }
      // Reset retry count for non-retryable errors
      _retryCount = 0;
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
