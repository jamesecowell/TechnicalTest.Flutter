import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:flutter_tech_task/domain/usecases/is_post_saved_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/save_post_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/unsave_post_for_offline.dart';

// Simple StateNotifier for saved status
class SavedStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  SavedStatusNotifier() : super(const AsyncValue.data(false));
}

class PostDetailsViewModel extends StateNotifier<AsyncValue<Post>> {
  final GetPostById getPostById;
  final IsPostSavedForOffline isPostSavedForOffline;
  final SavePostForOffline savePostForOffline;
  final UnsavePostForOffline unsavePostForOffline;

  // Separate StateNotifier for saved status so Riverpod can observe changes
  final SavedStatusNotifier savedStatusNotifier;
  AsyncValue<bool> get savedStatus => savedStatusNotifier.state;

  static const int _maxRetryAttempts = 10;
  int _loadPostRetryCount = 0;
  int _checkSavedStatusRetryCount = 0;

  PostDetailsViewModel({
    required this.getPostById,
    required this.isPostSavedForOffline,
    required this.savePostForOffline,
    required this.unsavePostForOffline,
  }) : savedStatusNotifier = SavedStatusNotifier(),
        super(const AsyncValue.loading());

  Future<void> loadPost(int id) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final result = await getPostById(GetPostByIdParams(id: id));
      result.fold(
        (failure) {
          if (mounted) {
            // Reset retry count on failure (non-retryable)
            _loadPostRetryCount = 0;
            state = AsyncValue.error(failure, StackTrace.current);
          }
        },
        (post) {
          if (mounted) {
            // Reset retry count on success
            _loadPostRetryCount = 0;
            state = AsyncValue.data(post);
            checkSavedStatus(id);
          }
        },
      );
    } catch (e, stackTrace) {
      // If repository not ready yet, wait and retry (with max attempts)
      if (e is UnimplementedError && (e.message?.contains('not initialized') ?? false)) {
        _loadPostRetryCount++;
        if (_loadPostRetryCount >= _maxRetryAttempts) {
          // Max retries reached, show error
          if (mounted) {
            state = AsyncValue.error(
              Exception('Failed to initialize repository after $_maxRetryAttempts attempts'),
              stackTrace,
            );
          }
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          loadPost(id);
        }
        return;
      }
      // Reset retry count for non-retryable errors
      _loadPostRetryCount = 0;
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> checkSavedStatus(int postId) async {
    if (!mounted) return;
    savedStatusNotifier.state = const AsyncValue.loading();
    try {
      final result = await isPostSavedForOffline(IsPostSavedForOfflineParams(postId: postId));
      if (!mounted) return;
      // Reset retry count on success
      _checkSavedStatusRetryCount = 0;
      result.fold(
        (failure) => savedStatusNotifier.state = AsyncValue.error(failure, StackTrace.current),
        (isSaved) => savedStatusNotifier.state = AsyncValue.data(isSaved),
      );
    } catch (e, stackTrace) {
      if (e is UnimplementedError && (e.message?.contains('not initialized') ?? false)) {
        _checkSavedStatusRetryCount++;
        if (_checkSavedStatusRetryCount >= _maxRetryAttempts) {
          // Max retries reached, show error
          if (mounted) {
            savedStatusNotifier.state = AsyncValue.error(
              Exception('Failed to initialize repository after $_maxRetryAttempts attempts'),
              stackTrace,
            );
          }
          return;
        }
        // Wait and retry
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          checkSavedStatus(postId);
        }
        return;
      }
      // Reset retry count for non-retryable errors
      _checkSavedStatusRetryCount = 0;
      if (mounted) {
        savedStatusNotifier.state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> toggleSavePost(Post post) async {
    final currentSavedStatus = savedStatusNotifier.state.value ?? false;
    final previousState = savedStatusNotifier.state;
    
    // Optimistically update the UI immediately
    savedStatusNotifier.state = AsyncValue.data(!currentSavedStatus);
    
    try {
      if (currentSavedStatus) {
        // Unsave the post
        final result = await unsavePostForOffline(UnsavePostForOfflineParams(postId: post.id));
        result.fold(
          (failure) {
            // Revert to previous state on failure
            savedStatusNotifier.state = previousState;
            // Optionally show error message - but keep the previous state
            // savedStatusNotifier.state = AsyncValue.error(failure, StackTrace.current);
          },
          (_) => checkSavedStatus(post.id),
        );
      } else {
        // Save the post
        final result = await savePostForOffline(post);
        result.fold(
          (failure) {
            // Revert to previous state on failure
            savedStatusNotifier.state = previousState;
            // Optionally show error message - but keep the previous state
            // savedStatusNotifier.state = AsyncValue.error(failure, StackTrace.current);
          },
          (_) => checkSavedStatus(post.id),
        );
      }
    } catch (e) {
      // Revert to previous state on exception
      savedStatusNotifier.state = previousState;
    }
  }
}

