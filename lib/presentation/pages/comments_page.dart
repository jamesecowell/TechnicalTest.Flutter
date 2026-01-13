import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/presentation/utils/error_message_extractor.dart';
import 'package:flutter_tech_task/presentation/widgets/comment_list_item.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';

class CommentsPage extends ConsumerStatefulWidget {
  const CommentsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  int? _postId;
  bool _hasRetriedAfterReady = false;

  void _loadCommentsFromArguments() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _postId = args?['postId'] as int?;
    if (_postId != null) {
      ref.read(commentsViewModelProvider.notifier).loadComments(_postId!);
    }
  }

  // Accept state as parameter instead of reading inside (Riverpod best practice)
  void _retryLoadIfNeeded(AsyncValue<List<Comment>> commentsState) {
    if (_postId == null || _hasRetriedAfterReady) return;

    // Only retry if state is still loading (we know getComments is ready from ref.listen)
    if (commentsState.isLoading) {
      _hasRetriedAfterReady = true;
      if (mounted && _postId != null) {
        // ref.read for notifier is acceptable here (triggering action)
        ref.read(commentsViewModelProvider.notifier).loadComments(_postId!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Load comments when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommentsFromArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider);

    // Single retry mechanism: listen for provider transitions
    // Pass state as parameter to avoid ref.read in build lifecycle
    ref.listen<AsyncValue<dynamic>>(
      getCommentsByPostIdProvider,
      (previous, next) {
        // When provider transitions from loading to data, retry if needed
        if (previous?.isLoading == true && next.hasValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Read fresh commentsState in postFrameCallback to ensure it's current
              // This is acceptable because we're in a postFrameCallback, not during build
              final currentCommentsState = ref.read(commentsViewModelProvider);
              _retryLoadIfNeeded(currentCommentsState);
            }
          });
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.comments),
      ),
      body: commentsState.when(
        data: (comments) => ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return CommentListItem(
              comment: comment,
            );
          },
        ),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) {
          return ErrorDisplayWidget(
            message: extractErrorMessage(error),
            onRetry: _loadCommentsFromArguments,
          );
        },
      ),
    );
  }
}
