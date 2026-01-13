import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';

class CommentsViewModel extends StateNotifier<AsyncValue<List<Comment>>> {
  final GetCommentsByPostId getCommentsByPostId;

  CommentsViewModel({required this.getCommentsByPostId}) : super(const AsyncValue.loading());

  Future<void> loadComments(int postId) async {
    state = const AsyncValue.loading();
    try {
      final result = await getCommentsByPostId(GetCommentsByPostIdParams(postId: postId));
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (comments) => state = AsyncValue.data(comments),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

