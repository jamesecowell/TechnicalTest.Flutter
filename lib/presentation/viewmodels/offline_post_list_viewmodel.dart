import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_posts.dart';

class OfflinePostListViewModel extends StateNotifier<AsyncValue<List<Post>>> {
  final GetOfflinePosts getOfflinePosts;
  static const int _maxRetryAttempts = 10;
  int _retryCount = 0;

  OfflinePostListViewModel({required this.getOfflinePosts})
      : super(const AsyncValue.loading()) {
    // Auto-load when ViewModel is created with real repository
    Future.microtask(() {
      if (mounted) {
        loadOfflinePosts();
      }
    });
  }

  Future<void> loadOfflinePosts() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final result = await getOfflinePosts();
      if (!mounted) return;
      // Reset retry count on success
      _retryCount = 0;
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (posts) => state = AsyncValue.data(posts),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (e is UnimplementedError && (e.message?.contains('not initialized') ?? false)) {
        _retryCount++;
        if (_retryCount >= _maxRetryAttempts) {
          // Max retries reached, show error
          state = AsyncValue.error(
            Exception('Failed to initialize repository after $_maxRetryAttempts attempts'),
            stackTrace,
          );
          return;
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          loadOfflinePosts();
        }
        return;
      }
      // Reset retry count for non-retryable errors
      _retryCount = 0;
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

