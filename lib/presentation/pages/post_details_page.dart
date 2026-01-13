import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/utils/error_message_extractor.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';

class PostDetailsPage extends ConsumerStatefulWidget {
  const PostDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
  int? _postId;
  bool _hasRetriedAfterReady = false;

  void _loadPostFromArguments() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _postId = args?['id'] as int?;
    if (_postId != null) {
      ref.read(postDetailsViewModelProvider.notifier).loadPost(_postId!);
    }
  }

  void _retryLoadIfNeeded() {
    if (_postId == null || _hasRetriedAfterReady) return;

    final postState = ref.read(postDetailsViewModelProvider);
    final getPostByIdAsync = ref.read(getPostByIdProvider);

    // Only retry if use case is ready and state is still loading
    if (getPostByIdAsync.hasValue && postState.isLoading) {
      _hasRetriedAfterReady = true;
      Future.microtask(() {
        if (mounted && _postId != null) {
          final currentState = ref.read(postDetailsViewModelProvider);
          // Only retry if still loading (might be a new ViewModel instance)
          if (currentState.isLoading) {
            ref.read(postDetailsViewModelProvider.notifier).loadPost(_postId!);
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load post when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostFromArguments();
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
    final postState = ref.watch(postDetailsViewModelProvider);
    final viewModel = ref.watch(postDetailsViewModelProvider.notifier);
    final savedStatus = ref.watch(postDetailsSavedStatusProvider);

    // Watch the use case provider to trigger didChangeDependencies when it changes
    ref.watch(getPostByIdProvider);

    // Listen for when the use case provider becomes ready and retry if needed
    // Note: ref.listen is called in build but is the Riverpod pattern for side effects
    ref.listen<AsyncValue<dynamic>>(
      getPostByIdProvider,
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
        title: const Text('Post details'),
        actions: [
          postState.when(
            data: (post) => savedStatus.when(
              data: (isSaved) => IconButton(
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () async {
                  await viewModel.toggleSavePost(post);
                  // Refresh offline post list to update badge count
                  ref
                      .read(offlinePostListViewModelProvider.notifier)
                      .loadOfflinePosts();
                },
                tooltip: isSaved ? 'Remove from offline' : 'Save for offline',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () async {
                  final post = postState.value;
                  if (post != null) {
                    await viewModel.toggleSavePost(post);
                    // Refresh offline post list to update badge count
                    ref
                        .read(offlinePostListViewModelProvider.notifier)
                        .loadOfflinePosts();
                  }
                },
                tooltip: 'Save for offline',
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: postState.when(
        data: (post) => Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post.body,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      'comments/',
                      arguments: {'postId': post.id},
                    );
                  },
                  child: const Text('View Comments'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) {
          return ErrorDisplayWidget(
            message: extractErrorMessage(error),
            onRetry: _loadPostFromArguments,
          );
        },
      ),
    );
  }
}
