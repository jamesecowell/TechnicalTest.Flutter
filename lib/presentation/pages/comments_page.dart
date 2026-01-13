import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
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

  void _retryLoadIfNeeded() {
    if (_postId == null || _hasRetriedAfterReady) return;

    final commentsState = ref.read(commentsViewModelProvider);
    final getCommentsAsync = ref.read(getCommentsByPostIdProvider);

    // Only retry if use case is ready and state is still loading
    if (getCommentsAsync.hasValue && commentsState.isLoading) {
      _hasRetriedAfterReady = true;
      Future.microtask(() {
        if (mounted && _postId != null) {
          final currentState = ref.read(commentsViewModelProvider);
          // Only retry if still loading (might be a new ViewModel instance)
          if (currentState.isLoading) {
            ref.read(commentsViewModelProvider.notifier).loadComments(_postId!);
          }
        }
      });
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to retry loading when dependencies change (e.g., when providers become ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryLoadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider);

    // Watch the use case provider to trigger didChangeDependencies when it changes
    ref.watch(getCommentsByPostIdProvider);

    // Listen for when the use case provider becomes ready and retry if needed
    // Note: ref.listen is called in build but is the Riverpod pattern for side effects
    ref.listen<AsyncValue<dynamic>>(
      getCommentsByPostIdProvider,
      (previous, next) {
        // When provider transitions from loading to data, schedule retry check
        if (previous?.isLoading == true && next.hasValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _retryLoadIfNeeded();
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
