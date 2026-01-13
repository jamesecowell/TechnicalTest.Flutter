import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void _loadCommentsFromArguments() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final postId = args?['postId'] as int?;
    if (postId != null) {
      ref.read(commentsViewModelProvider.notifier).loadComments(postId);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
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

